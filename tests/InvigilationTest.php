<?php

declare(strict_types=1);

define('BASE_PATH', dirname(__DIR__));
require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function (string $class): void {
    if (str_starts_with($class, 'App\\')) require BASE_PATH.'/app/'.str_replace('\\', '/', substr($class, 4)).'.php';
});

function dutyCheck(bool $condition, string $message): void
{
    if (!$condition) throw new RuntimeException($message);
}
function dutyReject(callable $action, string $message): void
{
    try {
        $action();
    } catch (App\Faculty\PortalException $error) {
        dutyCheck(str_contains($error->getMessage(), $message), $error->getMessage());
        return;
    }
    throw new RuntimeException('Expected rejection: '.$message);
}

$config = require BASE_PATH.'/config/database.php';
$dsn = "mysql:host={$config['host']};port={$config['port']};charset=utf8mb4";
$options = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES => false];
if (($argv[1] ?? '') === 'worker') {
    $pdo = new PDO($dsn.';dbname='.$argv[2], $config['username'], $config['password'], $options);
    echo (new App\Faculty\InvigilationService($pdo))->allocate((int)$argv[3], 1);
    exit;
}
$db = 'gbu_invigilation_'.bin2hex(random_bytes(4));
$server = new PDO($dsn, $config['username'], $config['password'], $options);
try {
    $server->exec(str_replace('gbu_exam_operations', $db, file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo = new PDO($dsn.';dbname='.$db, $config['username'], $config['password'], $options);
    App\Faculty\FacultyPortalMigration::apply($pdo);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'),('viewer','Viewer');
        INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'admin','Admin','unused'),(2,'viewer','Viewer','unused');
        INSERT INTO schools(code,name) VALUES('ICT','ICT');
        INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','CS','undergraduate',8);
        INSERT INTO students(programme_id,roll_no_original,normalized_roll_no,name,semester,parsing_status)
        VALUES(1,'TEST001','TEST001','Student One',1,'verified'),(1,'TEST002','TEST002','Student Two',1,'verified');
        INSERT INTO courses(code,name) VALUES('TEST','Test Paper');
        INSERT INTO rooms(school_id,code,building,rows_count,columns_count,physical_capacity,usable_capacity)
        VALUES(1,'R1','Test',1,1,1,1),(1,'R2','Test',1,1,1,1);
        INSERT INTO faculty(school_id,employee_id,name,email) VALUES
        (1,'F1','Faculty One','f1@example.test'),(1,'F2','Faculty Two','f2@example.test'),
        (1,'F3','Faculty Three','f3@example.test'),(1,'F4','Faculty Four','f4@example.test'),
        (1,'F5','Faculty Five','f5@example.test'),(1,'F6','Faculty Six','f6@example.test'),
        (1,'F7','Faculty Seven','f7@example.test'),(1,'F8','Faculty Eight','f8@example.test')");
    foreach ([1,2] as $room) (new App\Rooms\RoomSeatGenerator($pdo))->regenerate($room,1,1,'row_major',[]);
    $makeSession = function (string $date, string $start = '09:00', string $end = '12:00') use ($pdo): array {
        $pdo->prepare("INSERT INTO exam_cycles(name,academic_year,exam_type,start_date,end_date,default_duration_minutes,created_by)
            VALUES('Test Cycle','2026-27','mid_sem',?,DATE_ADD(?,INTERVAL 2 DAY),180,1)")->execute([$date,$date]);
        $cycle = (int)$pdo->lastInsertId();
        $pdo->prepare("INSERT INTO exam_shifts(cycle_id,name,start_time,end_time,duration_minutes,sequence_no)
            VALUES(?,'Morning',?,?,180,1)")->execute([$cycle,$start,$end]);
        $shift = (int)$pdo->lastInsertId();
        $pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,status) VALUES(?,?,1,?,'published')")
            ->execute([$cycle,$shift,$date]);
        $exam = (int)$pdo->lastInsertId();
        $pdo->prepare("INSERT INTO seating_allocations(cycle_id,exam_date,shift_id,version_no,seed_value,rule_profile,status,generated_by,generated_at)
            VALUES(?,?,?,1,'test','{}','published',1,NOW())")->execute([$cycle,$date,$shift]);
        $allocation = (int)$pdo->lastInsertId();
        $insert = $pdo->prepare('INSERT INTO seating_assignments(allocation_id,examination_id,student_id,room_id,seat_id)
            SELECT ?,?,?,?,id FROM room_seats WHERE room_id=?');
        foreach ([1,2] as $room) $insert->execute([$allocation,$exam,$room,$room,$room]);
        return ['allocation'=>$allocation,'cycle'=>$cycle,'shift'=>$shift,'date'=>$date];
    };
    $service = new App\Faculty\InvigilationService($pdo);
    $first = $makeSession('2026-11-20');
    dutyReject(fn()=>$service->allocate($first['allocation'],2),'authorized');
    dutyCheck($service->allocate($first['allocation'],1)===4,'Initial allocation failed');
    $before = $pdo->query('SELECT id,faculty_id,room_id FROM invigilation_allocations ORDER BY id')->fetchAll();
    dutyCheck($service->allocate($first['allocation'],1)===0,'Retry added duties');
    dutyCheck($before===$pdo->query('SELECT id,faculty_id,room_id FROM invigilation_allocations ORDER BY id')->fetchAll(),'Retry changed assignments');
    $original = $before[0];
    $pdo->exec('UPDATE invigilation_allocations SET duty_status=\'cancelled\' WHERE id='.$original['id']);
    dutyCheck($service->allocate($first['allocation'],1)===1,'Partial coverage did not fill only the missing room');
    dutyCheck((int)$pdo->query("SELECT COUNT(*) FROM invigilation_allocations WHERE duty_status='assigned'")->fetchColumn()===4,'Wrong room coverage');

    $overlap = $makeSession('2026-11-20','11:00','13:00');
    $free=(int)$pdo->query("SELECT id FROM faculty WHERE id NOT IN
        (SELECT faculty_id FROM invigilation_allocations WHERE duty_status='assigned') LIMIT 1")->fetchColumn();
    $service->saveAvailability(1,$free,$overlap['date'],$overlap['shift'],'unavailable','Test shortage');
    $countsBefore = $pdo->query('SELECT id,duty_count FROM faculty ORDER BY id')->fetchAll();
    dutyReject(fn()=>$service->allocate($overlap['allocation'],1),'Not enough');
    dutyCheck((int)$pdo->query('SELECT COUNT(*) FROM invigilation_allocations WHERE cycle_id='.$overlap['cycle'])->fetchColumn()===0,'Failed allocation wrote partial duties');
    dutyCheck($countsBefore===$pdo->query('SELECT id,duty_count FROM faculty ORDER BY id')->fetchAll(),'Failed allocation changed fairness counters');
    $service->saveAvailability(1,$free,$overlap['date'],$overlap['shift'],'available','Test shortage resolved');
    $touching = $makeSession('2026-11-20','12:00','15:00');
    dutyCheck($service->allocate($touching['allocation'],1)===4,'Adjacent nonoverlapping sessions were blocked');

    $night = $makeSession('2026-11-21','23:00','02:00');
    dutyCheck($service->allocate($night['allocation'],1)===4,'Night allocation failed');
    $nextDay = $makeSession('2026-11-22','01:00','03:00');
    dutyCheck($service->allocate($nextDay['allocation'],1)===4,'Next-day allocation failed');
    $nightFaculty = $pdo->query('SELECT faculty_id FROM invigilation_allocations WHERE cycle_id='.$night['cycle'])->fetchAll(PDO::FETCH_COLUMN);
    $nextFaculty = $pdo->query('SELECT faculty_id FROM invigilation_allocations WHERE cycle_id='.$nextDay['cycle'])->fetchAll(PDO::FETCH_COLUMN);
    dutyCheck(!array_intersect($nightFaculty,$nextFaculty),'Overnight conflict escaped');
    dutyReject(fn()=>$service->saveAvailability(1,(int)$nightFaculty[0],$nextDay['date'],$nextDay['shift'],'unavailable','Test'),'overlapping duty');

    $blocked = $makeSession('2026-11-23');
    $otherShift = $makeSession('2026-11-23','10:00','11:00');
    foreach (range(1,8) as $faculty) $service->saveAvailability(1,$faculty,$otherShift['date'],$otherShift['shift'],'unavailable','Test');
    dutyReject(fn()=>$service->allocate($blocked['allocation'],1),'only 0 faculty');
    dutyReject(fn()=>$service->saveAvailability(1,1,'2026-11-31',$otherShift['shift'],'unavailable','Test'),'valid date');
    dutyReject(fn()=>$service->saveAvailability(1,1,'2026-12-30',$otherShift['shift'],'unavailable','Test'),'selected date');
    dutyReject(fn()=>$service->saveAvailability(1,1,$otherShift['date'],$otherShift['shift'],'unavailable',str_repeat('x',256)),'255 characters');

    // Replacement and availability approvals share the same cross-cycle checks.
    $portal = new App\Faculty\FacultyPortalService($pdo);
    $newDuty = $pdo->query('SELECT * FROM invigilation_allocations WHERE cycle_id='.$night['cycle'].' LIMIT 1')->fetch();
    $pdo->prepare("INSERT INTO replacement_requests(duty_id,requested_by,reason,replacement_faculty_id,status) VALUES(?,1,'Test',?,'pending')")
        ->execute([$newDuty['id'],$nextFaculty[0]]);
    $nightReplacement = (int)$pdo->lastInsertId();
    dutyReject(fn()=>$portal->review(1,'replacement',$nightReplacement,true),'overlapping duty');
    dutyCheck($pdo->query('SELECT duty_status FROM invigilation_allocations WHERE id='.$newDuty['id'])->fetchColumn()==='assigned','Rejected replacement cancelled the original');
    $pdo->prepare("INSERT INTO faculty_availability_requests(faculty_id,requested_by,exam_date,shift_id,availability,reason,created_at)
        VALUES(?,1,?,?,'unavailable','Test',NOW())")->execute([$nightFaculty[0],$nextDay['date'],$nextDay['shift']]);
    $request = (int)$pdo->lastInsertId();
    dutyReject(fn()=>$portal->review(1,'availability',$request,true),'Reassign');
    $pdo->prepare("UPDATE faculty_availability_requests SET availability='available',reason=? WHERE id=?")->execute([str_repeat('x',500),$request]);
    $portal->review(1,'availability',$request,true);
    dutyCheck((int)$pdo->query('SELECT CHAR_LENGTH(reason) FROM faculty_availability_requests WHERE id='.$request)->fetchColumn()===500,'Approval lost the full request explanation');
    dutyReject(fn()=>$portal->coordinatorReplacement(1,(int)$newDuty['id'],'Another request is blocked',null),'already pending');
    dutyReject(fn()=>$portal->coordinatorReplacement(1,99999,'Invalid duty',null),'active duty');
    dutyReject(fn()=>$portal->coordinatorReplacement(1,(int)$newDuty['id'],'',null),'reason');

    // Separate PHP processes exercise actual concurrent requests.
    $race = $makeSession('2026-11-25');
    $workers = [];
    for ($index=0; $index<2; $index++) {
        $pipes = [];
        $process = proc_open([PHP_BINARY,__FILE__,'worker',$db,(string)$race['allocation']], [1=>['pipe','w'],2=>['pipe','w']], $pipes);
        dutyCheck(is_resource($process),'Could not start concurrent worker');
        $workers[] = [$process,$pipes];
    }
    $results = [];
    foreach ($workers as [$process,$pipes]) {
        $result=stream_get_contents($pipes[1]);$error=stream_get_contents($pipes[2]);
        fclose($pipes[1]);fclose($pipes[2]);
        dutyCheck(proc_close($process)===0,'Concurrent allocation failed: '.$error);
        $results[]=(int)$result;
    }
    sort($results);
    dutyCheck($results===[0,4],'Concurrent requests duplicated assignments');
    dutyCheck((int)$pdo->query('SELECT COUNT(*) FROM invigilation_allocations WHERE cycle_id='.$race['cycle'])->fetchColumn()===4,'Race created extra duties');
    $crossRace=[$makeSession('2026-11-26'),$makeSession('2026-11-26','10:00','13:00')];
    $workers=[];
    foreach($crossRace as $raceSession){
        $pipes=[];
        $process=proc_open([PHP_BINARY,__FILE__,'worker',$db,(string)$raceSession['allocation']],[1=>['pipe','w'],2=>['pipe','w']],$pipes);
        dutyCheck(is_resource($process),'Could not start cross-cycle worker');
        $workers[]=[$process,$pipes];
    }
    foreach($workers as [$process,$pipes]){
        $result=stream_get_contents($pipes[1]);$error=stream_get_contents($pipes[2]);
        fclose($pipes[1]);fclose($pipes[2]);
        dutyCheck(proc_close($process)===0 && (int)$result===4,'Concurrent cross-cycle allocation failed: '.$error);
    }
    $crossCycles=implode(',',array_column($crossRace,'cycle'));
    dutyCheck((int)$pdo->query('SELECT COUNT(DISTINCT faculty_id) FROM invigilation_allocations WHERE cycle_id IN ('.$crossCycles.')')->fetchColumn()===8,'Concurrent cycles assigned overlapping duties to the same faculty');

    // Previously allocated sessions with one teacher per room need exactly two additions.
    $legacy=$makeSession('2026-11-28');
    $manual=$pdo->prepare("INSERT INTO invigilation_allocations(cycle_id,exam_date,shift_id,room_id,faculty_id,assigned_by) VALUES(?,?,?,?,?,1)");
    foreach([1,2] as $room)$manual->execute([$legacy['cycle'],$legacy['date'],$legacy['shift'],$room,$room]);
    $legacyIds=$pdo->query('SELECT id FROM invigilation_allocations WHERE cycle_id='.$legacy['cycle'])->fetchAll(PDO::FETCH_COLUMN);
    $app = new App\Foundation\Application(BASE_PATH);$app->boot();
    $database = new App\Foundation\Database(array_merge($config,['database'=>$db]));
    (new ReflectionProperty($database,'connection'))->setValue($database,$pdo);
    (new ReflectionProperty($app,'database'))->setValue($app,$database);
    (new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));
    $app->session()->put('user',['id'=>1,'username'=>'admin','name'=>'Admin','role_code'=>'admin','role_name'=>'Admin']);
    $call = function (string $path,array $post=[]) use ($app) {
        $_POST=$post;$_GET=[];$_SERVER['REQUEST_METHOD']=$post?'POST':'GET';
        $_SERVER['REQUEST_URI']=$path;$_SERVER['SCRIPT_NAME']='/index.php';
        return $app->handle(App\Http\Request::capture());
    };
    $data=(new ReflectionMethod($app,'invigilationData'))->invoke($app);
    $coverage=array_column($data['sessions'],'covered_rooms','id');
    dutyCheck((int)$coverage[$race['allocation']]===2 && (int)$coverage[$blocked['allocation']]===0,'Coverage query is incorrect');
    dutyCheck((int)$coverage[$legacy['allocation']]===0,'Single-teacher rooms were incorrectly reported as covered');
    dutyCheck($service->allocate($legacy['allocation'],1)===2,'Existing single-teacher rooms were not topped up');
    dutyCheck($service->allocate($legacy['allocation'],1)===0,'Two-teacher room retry added extra teachers');
    $perRoom=$pdo->query("SELECT COUNT(DISTINCT faculty_id) FROM invigilation_allocations WHERE cycle_id=".$legacy['cycle']." AND duty_status='assigned' GROUP BY room_id")->fetchAll(PDO::FETCH_COLUMN);
    dutyCheck(array_map('intval',$perRoom)===[2,2],'Each room must have two distinct invigilators');
    dutyCheck((int)$pdo->query('SELECT COUNT(*) FROM invigilation_allocations WHERE id IN ('.implode(',',$legacyIds).") AND duty_status='assigned'")->fetchColumn()===2,'Top-up changed existing teachers');


    // Same room may have multiple teachers, but coverage must count distinct rooms.
    $pdo->exec("UPDATE invigilation_allocations SET duty_role='observer' WHERE cycle_id=".$race['cycle'].' AND room_id=2');
    $data=(new ReflectionMethod($app,'invigilationData'))->invoke($app);
    $coverage=array_column($data['sessions'],'covered_rooms','id');
    dutyCheck((int)$coverage[$race['allocation']]===1,'Observer incorrectly satisfies invigilator coverage');
    $call('/invigilation/allocate/'.$race['allocation'],['_token'=>'invalid']);
    dutyCheck((int)$pdo->query('SELECT COUNT(*) FROM invigilation_allocations WHERE cycle_id='.$race['cycle'])->fetchColumn()===4,'Invalid CSRF allocated a duty');
    $call('/invigilation/allocate/'.$race['allocation'],['_token'=>$app->session()->csrfToken()]);
    dutyCheck((int)$pdo->query('SELECT COUNT(*) FROM invigilation_allocations WHERE cycle_id='.$race['cycle'])->fetchColumn()===6,'Real allocation route did not fill missing room');
    $replaceDuty=$pdo->query('SELECT * FROM invigilation_allocations WHERE cycle_id='.$first['cycle']." AND duty_status='assigned' LIMIT 1")->fetch();
    $replacementFaculty=(int)$pdo->query('SELECT faculty_id FROM invigilation_allocations WHERE cycle_id='.$touching['cycle'].
        " AND faculty_id NOT IN (SELECT faculty_id FROM invigilation_allocations WHERE cycle_id=".$first['cycle']." AND duty_status='assigned') LIMIT 1" )->fetchColumn();
    $call('/replacements',['_token'=>$app->session()->csrfToken(),'duty_id'=>$replaceDuty['id'],'reason'=>'Test replacement without a suggestion']);
    $replaceRequest=(int)$pdo->query('SELECT id FROM replacement_requests WHERE duty_id='.$replaceDuty['id'])->fetchColumn();
    dutyCheck($replaceRequest>0,'Coordinator request route failed');
    $call('/replacements/'.$replaceRequest.'/approve',['_token'=>$app->session()->csrfToken(),'replacement_faculty_id'=>$replaceDuty['faculty_id']]);
    dutyCheck($pdo->query('SELECT status FROM replacement_requests WHERE id='.$replaceRequest)->fetchColumn()==='pending','Invalid replacement was approved');
    $call('/replacements/'.$replaceRequest.'/approve',['_token'=>$app->session()->csrfToken(),'replacement_faculty_id'=>$replacementFaculty]);
    dutyCheck($pdo->query('SELECT status FROM replacement_requests WHERE id='.$replaceRequest)->fetchColumn()==='approved','Replacement selection route failed');
    dutyCheck($pdo->query('SELECT duty_status FROM invigilation_allocations WHERE id='.$replaceDuty['id'])->fetchColumn()==='cancelled','Original duty was not cancelled');
    $response=$call('/invigilation');
    dutyCheck((new ReflectionProperty($response,'status'))->getValue($response)===200,'Invigilation page failed');
    $out=BASE_PATH.'/outputs/invigilation';if(!is_dir($out))mkdir($out,0770,true);
    file_put_contents($out.'/index.html',(new ReflectionProperty($response,'content'))->getValue($response));
    $response=$call('/replacements');
    dutyCheck((new ReflectionProperty($response,'status'))->getValue($response)===200,'Replacement page failed');
    file_put_contents($out.'/replacements.html',(new ReflectionProperty($response,'content'))->getValue($response));
    $app->session()->put('user',['id'=>2,'username'=>'viewer','name'=>'Viewer','role_code'=>'viewer','role_name'=>'Viewer']);
    $forbidden=$call('/invigilation');
    dutyCheck((new ReflectionProperty($forbidden,'status'))->getValue($forbidden)===403,'Viewer accessed allocation');
    echo "Invigilation: PASS (coverage, retries, partial repair, rollback, cross-cycle and overnight conflicts, availability, replacement approvals, concurrent requests, routes, CSRF and permissions)\n";
} finally {
    if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();
    $server->exec("DROP DATABASE IF EXISTS `$db`");
}
