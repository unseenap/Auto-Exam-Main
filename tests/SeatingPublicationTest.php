<?php

declare(strict_types=1);

define('BASE_PATH', dirname(__DIR__));
require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class): void {
    if(str_starts_with($class,'App\\')) require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';
});
function seatingCheck(bool $condition,string $message): void
{
    if(!$condition)throw new RuntimeException($message);
}
function seatingReject(callable $action,string $message): void
{
    try{$action();}catch(RuntimeException $error){
        seatingCheck(str_contains($error->getMessage(),$message),$error->getMessage());
        return;
    }
    throw new RuntimeException('Expected rejection: '.$message);
}
$config=require BASE_PATH.'/config/database.php';
$db='gbu_seating_publication_'.bin2hex(random_bytes(4));
$dsn="mysql:host={$config['host']};port={$config['port']};charset=utf8mb4";
$options=[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false];
$server=new PDO($dsn,$config['username'],$config['password'],$options);
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO($dsn.';dbname='.$db,$config['username'],$config['password'],$options);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'),('faculty','Faculty');
        INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'admin','Admin','unused');
        INSERT INTO schools(code,name) VALUES('ICT','School of ICT');
        INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','Computer Science','undergraduate',8);
        INSERT INTO courses(code,name) VALUES('TEST','Test paper');
        INSERT INTO rooms(school_id,code,building,rows_count,columns_count,physical_capacity,usable_capacity,status)
        VALUES(1,'R1','Test',1,2,2,2,'active'),(1,'R2','Test',2,2,4,4,'maintenance'),(1,'R3','Test',2,2,4,4,'maintenance')");
    $insert=$pdo->prepare("INSERT INTO students(programme_id,roll_no_original,normalized_roll_no,name,semester,parsing_status) VALUES(1,?,?,?,1,'verified')");
    for($number=1;$number<=6;$number++)$insert->execute(['TEST00'.$number,'TEST00'.$number,'Student '.$number]);
    (new App\Rooms\RoomSeatGenerator($pdo))->regenerate(1,1,2,'row_major',[]);
    foreach([2,3] as $room)(new App\Rooms\RoomSeatGenerator($pdo))->regenerate($room,2,2,'row_major',[]);
    $cycle=(new App\Exams\ExamService($pdo))->createCycle([
        'name'=>'Partial publication','academic_year'=>'2026-27','exam_type'=>'mid_sem',
        'start_date'=>'2026-11-20','end_date'=>'2026-11-20','duration'=>180,
        'shifts'=>[['name'=>'Morning','start'=>'09:00','end'=>'12:00','duration'=>180]]
    ],1);
    $shift=(int)$pdo->query('SELECT id FROM exam_shifts LIMIT 1')->fetchColumn();
    $pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,status) VALUES(?,?,1,'2026-11-20','published')")->execute([$cycle,$shift]);
    $exam=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO exam_eligibility(examination_id,student_id,eligibility_status) SELECT $exam,id,'eligible' FROM students");
    $allocator=new App\Seating\SeatingAllocator($pdo);
    $result=$allocator->generate($cycle,'2026-11-20',$shift,[1],1,'partial');
    $id=$result['allocation_id'];
    seatingCheck($result['assigned']===2&&$result['unallocated']===4,'Partial fixture incorrect');
    seatingCheck(!$allocator->validate($id)['valid']&&App\Seating\SeatingAllocator::publishable($allocator->validate($id)),'Remaining students should not block publication');
    $publisher=new App\Seating\SeatingPublicationService($pdo);
    seatingCheck($publisher->publish($id,1)===4,'Partial publication lost pending count');
    seatingCheck($pdo->query('SELECT status FROM seating_allocations WHERE id='.$id)->fetchColumn()==='published','Plan did not publish');
    seatingCheck((int)$pdo->query('SELECT COUNT(*) FROM attendance WHERE allocation_id='.$id)->fetchColumn()===2,'Attendance includes unseated students');
    seatingCheck($publisher->publish($id,1)===4,'Publication retry failed');
    seatingCheck((int)$pdo->query('SELECT COUNT(*) FROM attendance WHERE allocation_id='.$id)->fetchColumn()===2,'Publication retry duplicated attendance');

    // The real pages and routes use the same publication and remaining-allocation services.
    $app=new App\Foundation\Application(BASE_PATH);$app->boot();
    $database=new App\Foundation\Database(array_merge($config,['database'=>$db]));
    (new ReflectionProperty($database,'connection'))->setValue($database,$pdo);
    (new ReflectionProperty($app,'database'))->setValue($app,$database);
    (new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));
    $app->session()->put('user',['id'=>1,'username'=>'admin','name'=>'Admin','role_code'=>'admin','role_name'=>'Admin']);
    $call=function(string $path,array $post=[])use($app){
        $_POST=$post;$_GET=[];$_SERVER['REQUEST_METHOD']=$post?'POST':'GET';
        $_SERVER['REQUEST_URI']=$path;$_SERVER['SCRIPT_NAME']='/index.php';
        return $app->handle(App\Http\Request::capture());
    };
    $out=BASE_PATH.'/outputs/seating-publication';if(!is_dir($out))mkdir($out,0770,true);
    $response=$call('/seating/'.$id);
    file_put_contents($out.'/published.html',(new ReflectionProperty($response,'content'))->getValue($response));
    seatingReject(fn()=>$publisher->allocateRemaining($id,1),'No unused rooms');
    seatingCheck((int)$pdo->query('SELECT COUNT(*) FROM seating_unallocated WHERE allocation_id='.$id.' AND resolved_at IS NULL')->fetchColumn()===4,'Failed retry lost the remaining queue');
    $before=$pdo->query('SELECT * FROM seating_assignments WHERE allocation_id='.$id.' ORDER BY id')->fetchAll();
    $pdo->exec("UPDATE attendance SET status='present',marked_by=1,marked_at=NOW() WHERE allocation_id=$id;
        INSERT INTO faculty_room_sessions(allocation_id,room_id,status,revision,submitted_by,submitted_at) VALUES($id,1,'submitted',3,1,NOW())");
    $attendance=$pdo->query('SELECT * FROM attendance WHERE allocation_id='.$id.' ORDER BY id')->fetchAll();
    $pdo->exec("UPDATE rooms SET status='active' WHERE id=2");
    $call('/seating/'.$id.'/allocate-remaining',['_token'=>'invalid']);
    seatingCheck((int)$pdo->query('SELECT COUNT(*) FROM seating_assignments WHERE allocation_id='.$id)->fetchColumn()===2,'Invalid CSRF added seats');
    $call('/seating/'.$id.'/allocate-remaining',['_token'=>$app->session()->csrfToken()]);
    $remaining=(int)$pdo->query('SELECT COUNT(*) FROM seating_unallocated WHERE allocation_id='.$id.' AND resolved_at IS NULL')->fetchColumn();
    seatingCheck($remaining===2,'First remaining round should keep the capacity shortage pending');
    seatingCheck($before===$pdo->query('SELECT * FROM seating_assignments WHERE allocation_id='.$id.' AND room_id=1 ORDER BY id')->fetchAll(),'Published seats changed');
    seatingCheck($attendance===$pdo->query('SELECT * FROM attendance WHERE allocation_id='.$id.' AND room_id=1 ORDER BY id')->fetchAll(),'Recorded attendance changed');
    seatingCheck((int)$pdo->query('SELECT revision FROM faculty_room_sessions WHERE allocation_id='.$id.' AND room_id=1')->fetchColumn()===3,'Submitted room state changed');
    $pdo->exec("UPDATE rooms SET status='active' WHERE id=3");
    seatingCheck($publisher->allocateRemaining($id,1)===['assigned'=>2,'remaining'=>0],'Second remaining round failed');
    seatingCheck($publisher->allocateRemaining($id,1)===['assigned'=>0,'remaining'=>0],'Remaining allocation retry created duplicates');
    seatingCheck((int)$pdo->query('SELECT COUNT(*) FROM attendance WHERE allocation_id='.$id)->fetchColumn()===6,'New room attendance missing');
    seatingCheck($allocator->validate($id)['valid'],'Completed seating fails validation');

    // Other physical errors must continue to block publishing.
    $draft=$allocator->generate($cycle,'2026-11-20',$shift,[1],1,'new-draft')['allocation_id'];
    $pdo->exec("UPDATE room_seats SET is_blocked=1 WHERE room_id=1");
    seatingReject(fn()=>$publisher->publish($draft,1),'validation issues');
    $pdo->exec("UPDATE room_seats SET is_blocked=0 WHERE room_id=1");
    seatingReject(fn()=>$publisher->publish($draft,1),'recorded attendance');
    seatingCheck($pdo->query('SELECT status FROM seating_allocations WHERE id='.$id)->fetchColumn()==='published','Failed replacement superseded the active plan');
    $response=$call('/seating/'.$draft);
    file_put_contents($out.'/draft.html',(new ReflectionProperty($response,'content'))->getValue($response));

    // Supplementary seats must satisfy both legacy manual-pair and automatic-pair rules.
    $pdo->exec("UPDATE rooms SET status='maintenance' WHERE id IN (2,3)");
    foreach(['manual_rooms','automatic_pairs'] as $mode){
        $key='1:0:1';
        $rules=['mode'=>'paired_cohorts','allocation_mode'=>$mode,'pairings'=>[['left'=>$key,'right'=>$key,'room_ids'=>[1]]],
            'cohorts'=>App\Seating\SeatingRoster::groups((new App\Seating\SeatingRoster($pdo))->eligible($cycle,'2026-11-20',$shift)),
            'student_groups'=>[1=>$key,2=>$key],'room_columns'=>[1=>[1=>$key,2=>$key]],'seat_groups'=>[]];
        $paired=$allocator->generate($cycle,'2026-11-20',$shift,[1],1,$mode)['allocation_id'];
        foreach($pdo->query('SELECT student_id,seat_id FROM seating_assignments WHERE allocation_id='.$paired) as $seat)$rules['seat_groups'][$seat['seat_id']]=$key;
        $pdo->prepare('UPDATE seating_allocations SET rule_profile=? WHERE id=?')->execute([json_encode($rules,JSON_THROW_ON_ERROR),$paired]);
        $pdo->exec("UPDATE rooms SET status='active' WHERE id=2");
        seatingCheck($publisher->allocateRemaining($paired,1)===['assigned'=>2,'remaining'=>2],$mode.' remaining allocation failed');
        seatingCheck(App\Seating\SeatingAllocator::publishable($allocator->validate($paired)),$mode.' merged pairing rules are invalid');
        $pdo->exec("UPDATE rooms SET status='maintenance' WHERE id=2");
    }
    echo "Partial seating publication: PASS (pending queue, idempotency, attendance preservation, successive remaining rounds, capacity shortages, manual/automatic pairings, physical validation, CSRF and real routes)\n";
}finally{
    if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();
    $server->exec("DROP DATABASE IF EXISTS `$db`");
}
