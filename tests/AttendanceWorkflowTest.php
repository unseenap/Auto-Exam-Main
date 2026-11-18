<?php

declare(strict_types=1);

define('BASE_PATH',dirname(__DIR__));
require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{
    if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';
});
function attendanceCheck(bool $condition,string $message):void
{
    if(!$condition)throw new RuntimeException($message);
}
function attendanceReject(callable $action,string $message):void
{
    try{$action();}catch(App\Faculty\PortalException $error){
        attendanceCheck(str_contains($error->getMessage(),$message),$error->getMessage());
        return;
    }
    throw new RuntimeException('Expected rejection: '.$message);
}
$config=require BASE_PATH.'/config/database.php';
$db='gbu_attendance_workflow_'.bin2hex(random_bytes(4));
$dsn="mysql:host={$config['host']};port={$config['port']};charset=utf8mb4";
$options=[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false];
$server=new PDO($dsn,$config['username'],$config['password'],$options);
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO($dsn.';dbname='.$db,$config['username'],$config['password'],$options);
    App\Faculty\FacultyPortalMigration::apply($pdo);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'),('faculty','Faculty'),('viewer','Viewer');
        INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'admin','Admin','unused'),
        (2,'teacher1','Teacher One','unused'),(2,'teacher2','Teacher Two','unused'),
        (2,'teacher3','Teacher Three','unused'),(2,'teacher4','Teacher Four','unused'),(3,'viewer','Viewer','unused');
        INSERT INTO schools(code,name) VALUES('ICT','School of ICT');
        INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','Computer Science','undergraduate',8);
        INSERT INTO courses(code,name) VALUES('CS101','Computer Science');
        INSERT INTO faculty(school_id,employee_id,name,email) VALUES(1,'F1','Teacher One','t1@example.test'),
        (1,'F2','Teacher Two','t2@example.test'),(1,'F3','Teacher Three','t3@example.test'),(1,'F4','Teacher Four','t4@example.test');
        INSERT INTO faculty_user_links(user_id,faculty_id) VALUES(2,1),(3,2),(4,3),(5,4);
        INSERT INTO rooms(school_id,code,building,rows_count,columns_count,physical_capacity,usable_capacity)
        VALUES(1,'R1','Test',1,2,2,2),(1,'R2','Test',1,2,2,2)");
    foreach([1,2] as $room)(new App\Rooms\RoomSeatGenerator($pdo))->regenerate($room,1,2,'row_major',[]);
    $insert=$pdo->prepare("INSERT INTO students(programme_id,roll_no_original,normalized_roll_no,name,semester,parsing_status) VALUES(1,?,?,?,1,'verified')");
    for($i=1;$i<=4;$i++)$insert->execute(['TEST00'.$i,'TEST00'.$i,'Student '.$i]);
    $cycle=(new App\Exams\ExamService($pdo))->createCycle([
        'name'=>'Attendance workflow','academic_year'=>'2026-27','exam_type'=>'mid_sem',
        'start_date'=>'2026-12-01','end_date'=>'2026-12-02','duration'=>180,
        'shifts'=>[['name'=>'Morning','start'=>'09:00','end'=>'12:00','duration'=>180]]
    ],1);
    $shift=(int)$pdo->query('SELECT id FROM exam_shifts LIMIT 1')->fetchColumn();
    $pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,status) VALUES(?,?,1,'2026-12-01','published')")->execute([$cycle,$shift]);
    $exam=(int)$pdo->lastInsertId();
    $pdo->prepare("INSERT INTO seating_allocations(cycle_id,exam_date,shift_id,version_no,seed_value,rule_profile,status,generated_by,generated_at)
        VALUES(?,'2026-12-01',?,1,'test','{}','published',1,NOW())")->execute([$cycle,$shift]);
    $allocation=(int)$pdo->lastInsertId();
    foreach([1,2,3,4] as $student){
        $room=$student<=2?1:2;
        $seat=(int)$pdo->query('SELECT id FROM room_seats WHERE room_id='.$room.' ORDER BY sequence_no LIMIT 1 OFFSET '.(($student-1)%2))->fetchColumn();
        $pdo->prepare('INSERT INTO seating_assignments(allocation_id,examination_id,student_id,room_id,seat_id) VALUES(?,?,?,?,?)')
            ->execute([$allocation,$exam,$student,$room,$seat]);
        $pdo->prepare('INSERT INTO attendance(allocation_id,examination_id,student_id,room_id) VALUES(?,?,?,?)')->execute([$allocation,$exam,$student,$room]);
    }
    foreach([1,2,3,4] as $faculty)$pdo->prepare("INSERT INTO invigilation_allocations(cycle_id,exam_date,shift_id,room_id,faculty_id,assigned_by)
        VALUES(?,'2026-12-01',?,?,?,1)")->execute([$cycle,$shift,$faculty<=2?1:2,$faculty]);
    $clock=static fn(string $time)=>new DateTimeImmutable($time,new DateTimeZone('Asia/Kolkata'));
    $service=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-01 10:00:00'));
    $pdo->exec("UPDATE faculty_portal_settings SET attendance_before_minutes=120,attendance_after_minutes=120 WHERE id=1");
    $beforeStart=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-01 08:59:59'));
    attendanceReject(fn()=>$beforeStart->mark(2,1,1,'present','',0),'saved time');
    $pdo->prepare("UPDATE exam_shifts SET start_time='20:30:00',end_time='23:30:00' WHERE id=?")->execute([$shift]);
    $customTime=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-01 21:00:00'));
    $customWindow=$customTime->window($customTime->duty(2,1));
    attendanceCheck($customWindow['allowed']&&$customWindow['open']==='01 Dec 2026, 20:30'&&$customWindow['close']==='01 Dec 2026, 23:30','Attendance did not follow the entered evening times');
    $beforeCustomStart=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-01 20:29:59'));
    attendanceReject(fn()=>$beforeCustomStart->mark(2,1,1,'present','',0),'saved time');
    $pdo->prepare("UPDATE exam_shifts SET start_time='09:00:00',end_time='12:00:00' WHERE id=?")->execute([$shift]);
    attendanceReject(fn()=>$service->room(2,3),'not assigned');
    attendanceReject(fn()=>$service->mark(4,3,1,'present','',0),'outside your assigned room');
    $service->mark(2,1,1,'present','',0);
    $service->mark(3,2,2,'unfair_means','Unauthorized notes',1,['first_copy_serial'=>'00123','second_copy_serial'=>'00456']);

    $app=new App\Foundation\Application(BASE_PATH);$app->boot();
    $database=new App\Foundation\Database(array_merge($config,['database'=>$db]));
    (new ReflectionProperty($database,'connection'))->setValue($database,$pdo);
    (new ReflectionProperty($app,'database'))->setValue($app,$database);
    (new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));
    $login=function(int $user,string $role)use($app){
        $app->session()->put('user',['id'=>$user,'username'=>$user===1?'admin':($user===6?'viewer':'teacher'.($user-1)),
            'name'=>$user===1?'Admin':'Teacher','role_code'=>$role,'role_name'=>$role]);
    };
    $call=function(string $path,array $post=[])use($app){
        $_POST=$post;$_GET=[];$_SERVER['REQUEST_METHOD']=$post?'POST':'GET';
        $_SERVER['REQUEST_URI']=$path;$_SERVER['SCRIPT_NAME']='/index.php';
        return $app->handle(App\Http\Request::capture());
    };
    $out=BASE_PATH.'/outputs/attendance-workflow';if(!is_dir($out))mkdir($out,0770,true);
    $login(2,'faculty');
    $_SERVER['REQUEST_URI']='/faculty-panel/duties/1';
    $data=$service->room(2,1);
    file_put_contents($out.'/teacher-open.html',App\View\View::render('faculty-panel/room',$data+['faculty'=>$service->faculty(2),'success'=>null,'error'=>null]));
    file_put_contents($out.'/teacher-open.json',json_encode(['revision'=>$data['state']['revision'],'state'=>$data['state'],'records'=>$data['records'],'window'=>$data['window']],JSON_THROW_ON_ERROR));
    $service->submit(3,2,2);
    attendanceReject(fn()=>$service->mark(2,1,1,'absent','',3),'locked');
    $manual=$service->room(2,1);
    attendanceCheck($manual['state']['lock_reason']==='manual'&&(int)$manual['state']['submitted_by']===3,'Co-invigilator lock was not shared');
    $beforeEnd=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-01 11:59:59'));
    $beforeEnd->mark(4,3,3,'present','',0);
    $atEnd=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-01 12:00:00'));
    attendanceReject(fn()=>$atEnd->mark(4,3,4,'absent','',1),'locked');
    $locked=$atEnd->room(4,3);
    attendanceCheck($locked['state']['lock_reason']==='automatic'&&$locked['state']['submitted_at']==='2026-12-01 12:00:00','Automatic lock did not use the exact exam end');
    attendanceCheck($locked['records'][1]['status']==='unmarked','Automatic lock silently changed an unmarked student');
    $revision=$locked['state']['revision'];
    (new App\Faculty\AttendanceOperations($pdo,$clock('2026-12-01 12:30:00')))->expire();
    attendanceCheck($atEnd->room(4,3)['state']['revision']===$revision,'Automatic lock was applied twice');
    attendanceReject(fn()=>$atEnd->coordinatorAttendance(1,$allocation,[4=>'absent'],[2=>$revision]),'submitted');
    attendanceReject(fn()=>$atEnd->closeReport(4,3,(int)$revision,[$exam=>'1'],true,'',''),'unmarked students');
    $login(4,'faculty');
    $_SERVER['REQUEST_URI']='/faculty-panel/duties/3';
    file_put_contents($out.'/teacher-locked.html',App\View\View::render('faculty-panel/room',$locked+['faculty'=>$atEnd->faculty(4),'success'=>null,'error'=>null]));
    $rooms=(new App\Faculty\AttendanceOperations($pdo,$clock('2026-12-01 12:00:00')))->rooms($allocation);
    attendanceCheck(count($rooms)===2&&(int)$rooms[1]['unmarked']===1&&$rooms[0]['updated_by']==='Teacher Two','Admin room totals or editor information are wrong');
    file_put_contents($out.'/rooms-locked.json',json_encode(['rooms'=>$rooms,'refreshed_at'=>'2026-12-01 12:00:00'],JSON_THROW_ON_ERROR));

    // Correction approval is the only way to resume editing a locked room.
    $atEnd->correction(4,3,'Verify the last attendance entry');
    $request=(int)$pdo->query('SELECT MAX(id) FROM faculty_correction_requests')->fetchColumn();
    $coordinator=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-01 12:01:00'));
    $coordinator->review(1,'correction',$request,true);
    $reopened=$coordinator->room(4,3);
    attendanceCheck($reopened['window']['allowed'],'Approved correction did not reopen attendance');
    $coordinator->mark(4,3,4,'absent','Verified after review',(int)$reopened['state']['revision']);
    $coordinator->submit(5,4,(int)$reopened['state']['revision']+1);
    $atEnd->correction(2,1,'Review the UFM note');
    $request=(int)$pdo->query('SELECT MAX(id) FROM faculty_correction_requests')->fetchColumn();
    $coordinator->review(1,'correction',$request,true);
    $expiry=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-01 13:01:00'));
    attendanceReject(fn()=>$expiry->mark(2,1,1,'absent','',4),'locked');
    attendanceCheck($expiry->room(2,1)['state']['submitted_at']==='2026-12-01 13:01:00','Correction expiry did not lock at its deadline');

    // Room exports and faculty URLs must never include another room's students.
    $login(1,'admin');
    $response=$call('/attendance');
    attendanceCheck((new ReflectionProperty($response,'status'))->getValue($response)===200,'Admin attendance page failed');
    file_put_contents($out.'/admin.html',(new ReflectionProperty($response,'content'))->getValue($response));
    $snapshot=$call('/attendance/'.$allocation.'/snapshot');
    $payload=json_decode((new ReflectionProperty($snapshot,'content'))->getValue($snapshot),true,512,JSON_THROW_ON_ERROR);
    attendanceCheck(count($payload['rooms'])===2,'Admin live endpoint lost a room');
    foreach(['/attendance/'.$allocation.'/export.xlsx'=>'master','/attendance/'.$allocation.'/rooms/1/export.xlsx'=>'room'] as $path=>$scope){
        $response=$call($path);
        attendanceCheck((new ReflectionProperty($response,'status'))->getValue($response)===200,'Attendance Excel route failed');
        $file=$out.'/'.$scope.'.xlsx';
        file_put_contents($file,(new ReflectionProperty($response,'content'))->getValue($response));
        $zip=new ZipArchive();attendanceCheck($zip->open($file)===true,'Excel package invalid');
        $workbook=$zip->getFromName('xl/workbook.xml');
        attendanceCheck(str_contains($workbook,'Master attendance')&&str_contains($workbook,'Room register'),'Missing master or room register worksheet');
        $xml='';for($i=1;$i<=$zip->numFiles;$i++){ $name=$zip->getNameIndex($i-1);if(str_starts_with($name,'xl/worksheets/'))$xml.=$zip->getFromName($name); }
        attendanceCheck(str_contains($xml,'Teacher One')&&str_contains($xml,'00123')&&str_contains($xml,'00456'),'Excel lost marking identities or UFM serials');
        attendanceCheck(str_contains($xml,'TEST004')===($scope==='master'),'Room export exposed another room or master lost a student');
        attendanceCheck(str_contains($zip->getFromName('xl/styles.xml'),'dd/mm/yyyy hh:mm:ss'),'Marking times lost their timestamp format');
        $zip->close();
    }
    $login(2,'faculty');
    $response=$call('/faculty-panel/duties/1/export.xlsx');
    attendanceCheck((new ReflectionProperty($response,'status'))->getValue($response)===200,'Assigned teacher cannot export their room');
    foreach(['/faculty-panel/duties/3/export.xlsx','/attendance/snapshot','/attendance/'.$allocation.'/export.xlsx'] as $path){
        $response=$call($path);
        attendanceCheck((new ReflectionProperty($response,'status'))->getValue($response)===403,'Faculty accessed another room or admin export');
    }
    $login(6,'viewer');
    $response=$call('/attendance/snapshot');
    attendanceCheck((new ReflectionProperty($response,'status'))->getValue($response)===403,'Viewer accessed teacher attendance operations');
    // An overnight shift locks on the following calendar day.
    $nightCycle=(new App\Exams\ExamService($pdo))->createCycle([
        'name'=>'Overnight attendance','academic_year'=>'2026-27','exam_type'=>'mid_sem',
        'start_date'=>'2026-12-01','end_date'=>'2026-12-02','duration'=>180,
        'shifts'=>[['name'=>'Night','start'=>'23:00','end'=>'02:00','duration'=>180]]
    ],1);
    $nightShift=(int)$pdo->query('SELECT id FROM exam_shifts WHERE cycle_id='.$nightCycle)->fetchColumn();
    $pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,status) VALUES(?,?,1,'2026-12-01','published')")->execute([$nightCycle,$nightShift]);
    $nightExam=(int)$pdo->lastInsertId();
    $pdo->prepare("INSERT INTO seating_allocations(cycle_id,exam_date,shift_id,version_no,seed_value,rule_profile,status,generated_by,generated_at)
        VALUES(?,'2026-12-01',?,1,'night','{}','published',1,NOW())")->execute([$nightCycle,$nightShift]);
    $nightAllocation=(int)$pdo->lastInsertId();
    $seat=(int)$pdo->query('SELECT id FROM room_seats WHERE room_id=1 LIMIT 1')->fetchColumn();
    $pdo->prepare('INSERT INTO seating_assignments(allocation_id,examination_id,student_id,room_id,seat_id) VALUES(?,?,1,1,?)')->execute([$nightAllocation,$nightExam,$seat]);
    $pdo->prepare('INSERT INTO attendance(allocation_id,examination_id,student_id,room_id) VALUES(?,?,1,1)')->execute([$nightAllocation,$nightExam]);
    $nightRecord=(int)$pdo->lastInsertId();
    $pdo->prepare("INSERT INTO invigilation_allocations(cycle_id,exam_date,shift_id,room_id,faculty_id,assigned_by) VALUES(?,'2026-12-01',?,1,1,1)")->execute([$nightCycle,$nightShift]);
    $nightDuty=(int)$pdo->lastInsertId();
    $night=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-02 01:59:59'));
    $night->mark(2,$nightDuty,$nightRecord,'present','',0);
    $nightEnd=new App\Faculty\FacultyPortalService($pdo,$clock('2026-12-02 02:00:00'));
    attendanceReject(fn()=>$nightEnd->mark(2,$nightDuty,$nightRecord,'absent','',1),'locked');
    attendanceCheck($nightEnd->room(2,$nightDuty)['state']['submitted_at']==='2026-12-02 02:00:00','Overnight shift locked on the wrong date');
    echo "Attendance workflow: PASS (assigned-room scope, shared manual locks, exact exam-end lock, incomplete flags, idempotency, correction expiry, admin live updates, room/master Excel and permissions)\n";
}finally{
    if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();
    $server->exec("DROP DATABASE IF EXISTS `$db`");
}
