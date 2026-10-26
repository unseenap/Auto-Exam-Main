<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function schoolCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
function schoolReject(callable $call,string $message):void{$failed=false;try{$call();}catch(RuntimeException $e){$failed=true;}schoolCheck($failed,$message);}
$config=require BASE_PATH.'/config/database.php';$db='gbu_school_rooms_'.bin2hex(random_bytes(4));
if(!preg_match('/^gbu_school_rooms_[a-f0-9]{8}$/',$db))throw new RuntimeException('Unsafe database name.');
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$csv=__DIR__.'/school_rooms_'.bin2hex(random_bytes(4)).'.csv';
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname=$db;charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false]);
    // Exercise the upgrade from an old rooms table as well as repeat runs.
    $pdo->exec('ALTER TABLE rooms DROP FOREIGN KEY fk_rooms_school, DROP INDEX idx_rooms_school_status, DROP COLUMN school_id');
    App\Rooms\RoomSchoolMigration::apply($pdo);App\Rooms\RoomSchoolMigration::apply($pdo);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name) VALUES('ICT','ICT'),('SOE','Engineering'); INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'ICTP','ICT programme','undergraduate',8),(2,'SOEP','Engineering programme','undergraduate',8); INSERT INTO courses(code,name) VALUES('COMMON','Shared written paper'); INSERT INTO programme_courses(programme_id,course_id,semester,category) VALUES(1,1,1,'common'),(2,1,1,'common')");
    $q=$pdo->prepare("INSERT INTO students(programme_id,roll_no_original,normalized_roll_no,name,academic_session,current_year_of_study,semester,section,status) VALUES(?,?,?,?,'2026-2027',1,1,'A','active')");
    foreach([[1,'ICT001'],[1,'ICT002'],[2,'SOE001'],[2,'SOE002']] as [$programme,$roll])$q->execute([$programme,$roll,$roll,$roll]);
    $exam=new App\Exams\ExamService($pdo);
    $cycle=$exam->createCycle(['name'=>'School room test','academic_year'=>'2026-2027','exam_type'=>'mid_sem','start_date'=>'2026-10-26','end_date'=>'2026-10-26','duration'=>90,'shifts'=>[['name'=>'Morning','start'=>'09:00','end'=>'10:30','duration'=>90]]],1);
    $shift=(int)$pdo->query('SELECT id FROM exam_shifts')->fetchColumn();
    foreach([1,2] as $programme)$exam->schedule(['cycle_id'=>$cycle,'shift_id'=>$shift,'course_id'=>1,'exam_date'=>'2026-10-26','category'=>'regular','programme_id'=>$programme,'semester'=>1]);
    $q=$pdo->prepare("INSERT INTO rooms(school_id,code,building,rows_count,columns_count,physical_capacity,usable_capacity,seat_order) VALUES(?,?, 'Test',1,?,?,?,'row_major')");
    $rooms=[];foreach([[1,'ICT-SMALL',1],[2,'SOE-LARGE',10],[null,'UNASSIGNED',10],[1,'ICT-EXTRA',2]] as [$school,$code,$capacity]){
        $q->execute([$school,$code,$capacity,$capacity,$capacity]);$room=(int)$pdo->lastInsertId();$rooms[$code]=$room;(new App\Rooms\RoomSeatGenerator($pdo))->regenerate($room,1,$capacity,'row_major');
    }
    $allocator=new App\Seating\SeatingAllocator($pdo);
    $limited=$allocator->generate($cycle,'2026-10-26',$shift,[$rooms['ICT-SMALL'],$rooms['SOE-LARGE'],$rooms['UNASSIGNED']],1,'school-shortage');
    schoolCheck($limited['assigned']===3&&$limited['unallocated']===1,'ICT shortage spilled into another school or an unassigned room.');
    $id=$limited['allocation_id'];$checks=$allocator->validate($id);schoolCheck($checks['school_mismatches']===0&&!$checks['valid'],'Shortage validation failed.');
    schoolCheck((int)$pdo->query("SELECT COUNT(*) FROM seating_unallocated u JOIN students s ON s.id=u.student_id WHERE u.allocation_id=$id AND s.programme_id=1")->fetchColumn()===1,'Wrong school left unallocated.');
    schoolCheck((int)$pdo->query("SELECT COUNT(*) FROM seating_assignments WHERE allocation_id=$id AND room_id=".$rooms['UNASSIGNED'])->fetchColumn()===0,'Unassigned room used.');
    $onlyOther=$allocator->generate($cycle,'2026-10-26',$shift,[$rooms['SOE-LARGE']],1,'other-school');
    schoolCheck($onlyOther['assigned']===2&&$onlyOther['unallocated']===2,'Other-school-only selection seated ICT students.');
    schoolReject(fn()=>$allocator->generate($cycle,'2026-10-26',$shift,[$rooms['UNASSIGNED']],1,'unassigned'),'Unassigned-only room accepted.');
    $full=$allocator->generate($cycle,'2026-10-26',$shift,[$rooms['ICT-SMALL'],$rooms['ICT-EXTRA'],$rooms['SOE-LARGE']],1,'complete');
    $id=$full['allocation_id'];schoolCheck($full['assigned']===4&&$allocator->validate($id)['valid'],'Mixed-school complete allocation failed.');
    $policy=new App\Rooms\SchoolRoomPolicy($pdo);$policy->assertStudentRoom(1,$rooms['ICT-SMALL']);
    schoolReject(fn()=>$policy->assertStudentRoom(1,$rooms['SOE-LARGE']),'Manual cross-school correction allowed.');
    schoolReject(fn()=>$policy->assertStudentRoom(1,$rooms['UNASSIGNED']),'Manual unassigned-school correction allowed.');
    // Exercise actual form handlers and view data against the isolated database.
    $app=new App\Foundation\Application(BASE_PATH);$app->boot();
    $database=new App\Foundation\Database(array_merge($config,['database'=>$db]));
    (new ReflectionProperty($database,'connection'))->setValue($database,$pdo);
    (new ReflectionProperty($app,'database'))->setValue($app,$database);
    (new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));
    $app->session()->put('user',['id'=>1,'name'=>'Tester','role_code'=>'admin','role_name'=>'Admin']);
    $_POST=['_token'=>$app->session()->csrfToken()];$_GET=[];
    $request=App\Http\Request::capture();
    $invoke=static fn(string $method,...$args):mixed=>(new ReflectionMethod($app,$method))->invoke($app,...$args);
    $assignment=$pdo->query("SELECT * FROM seating_assignments WHERE allocation_id=$id AND student_id=1")->fetch();
    $foreignSeat=(int)$pdo->query('SELECT id FROM room_seats WHERE room_id='.$rooms['SOE-LARGE'].' AND id NOT IN (SELECT seat_id FROM seating_assignments WHERE allocation_id='.$id.') LIMIT 1')->fetchColumn();
    $_POST+=['assignment_id'=>$assignment['id'],'seat_id'=>$foreignSeat,'reason'=>'School check'];
    $invoke('moveSeating',$request,$id);
    schoolCheck(str_contains($app->session()->pullFlash('error',''),'school'),'Move handler failed to reject a cross-school seat.');
    schoolCheck((int)$pdo->query('SELECT seat_id FROM seating_assignments WHERE id='.$assignment['id'])->fetchColumn()===(int)$assignment['seat_id'],'Rejected move altered the assignment.');
    $_POST['seat_id']=(int)$pdo->query('SELECT id FROM room_seats WHERE room_id='.$rooms['ICT-SMALL'])->fetchColumn();
    $invoke('moveSeating',$request,$id);
    schoolCheck($app->session()->pullFlash('error')===null,'Valid same-school move failed.');
    schoolCheck((int)$pdo->query('SELECT room_id FROM seating_assignments WHERE id='.$assignment['id'])->fetchColumn()===$rooms['ICT-SMALL'],'Same-school move did not persist.');
    $pending=$pdo->query('SELECT * FROM seating_unallocated WHERE allocation_id='.$limited['allocation_id'])->fetch();
    $_POST=['_token'=>$app->session()->csrfToken(),'unallocated_id'=>$pending['id'],'seat_id'=>$foreignSeat];
    $invoke('assignUnallocated',$request,$limited['allocation_id']);
    schoolCheck(str_contains($app->session()->pullFlash('error',''),'school'),'Unallocated handler failed to reject a cross-school seat.');
    schoolCheck($pdo->query('SELECT resolved_at FROM seating_unallocated WHERE id='.$pending['id'])->fetchColumn()===null,'Rejected resolution changed the unallocated record.');
    $_POST=[];$_GET=['cycle_id'=>$cycle];
    $viewData=$invoke('seatingGenerateData',$request);
    schoolCheck(count($viewData['sessions'][0]['school_demands'])===2,'UI session data lost a school.');
    schoolCheck(count($viewData['rooms'])===3,'UI offered an unassigned room.');
    set_error_handler(static function(int $severity,string $message,string $file,int $line):never{throw new ErrorException($message,0,$severity,$file,$line);});
    try{
        foreach(['seating/generate'=>$viewData,'seating/preview'=>$invoke('seatingPreviewData',$id),'rooms/index'=>$invoke('roomData',$request),'rooms/form'=>$invoke('roomFormData',$rooms['ICT-EXTRA'])] as $view=>$data){
            schoolCheck(strlen(App\View\View::render($view,$data))>100,'Empty rendered view: '.$view);
        }
    }finally{restore_error_handler();}
    $pdo->exec('UPDATE rooms SET school_id=NULL WHERE id='.$rooms['ICT-EXTRA']);
    $pdo->exec("UPDATE seating_allocations SET status='published' WHERE id=$id");
    $policy->assertOwnershipChange($rooms['ICT-EXTRA'],1);
    schoolReject(fn()=>$policy->assertOwnershipChange($rooms['ICT-EXTRA'],2),'Initial school conflicts with published students.');
    $pdo->exec('UPDATE rooms SET school_id=1 WHERE id='.$rooms['ICT-EXTRA']);
    schoolReject(fn()=>$policy->assertOwnershipChange($rooms['ICT-EXTRA'],2),'Published room changed school.');
    // Catch assignments altered outside the application before publication.
    $seat=(int)$pdo->query('SELECT id FROM room_seats WHERE room_id='.$rooms['SOE-LARGE'].' AND id NOT IN (SELECT seat_id FROM seating_assignments WHERE allocation_id='.$id.') LIMIT 1')->fetchColumn();
    $pdo->prepare('UPDATE seating_assignments SET room_id=?,seat_id=? WHERE allocation_id=? AND student_id=1')->execute([$rooms['SOE-LARGE'],$seat,$id]);
    $checks=$allocator->validate($id);schoolCheck($checks['school_mismatches']===1&&!$checks['valid'],'Publication validator missed a cross-school assignment.');
    $pdo->exec('UPDATE schools SET status=\'inactive\' WHERE id=1');schoolReject(fn()=>$policy->assertStudentRoom(2,$rooms['ICT-EXTRA']),'Inactive school accepted.');$pdo->exec('UPDATE schools SET status=\'active\' WHERE id=1');
    file_put_contents($csv,"Room Code,School Code,Building,Rows,Columns\nIMPORT-ICT,ICT,Test,1,2\nIMPORT-SOE,SOE,Test,1,2\nIMPORT-BAD,INVALID,Test,1,2\nIMPORT-DEFAULT,,Test,1,2\n");
    $importer=new App\Import\RoomImportService($pdo);$batch=$importer->stage($csv,'rooms.csv',1,1);
    schoolCheck((int)$pdo->query('SELECT valid_rows FROM import_batches WHERE id='.$batch)->fetchColumn()===3,'School code or upload default validation failed.');
    $pdo->beginTransaction();$importer->commit($batch,1);$pdo->commit();
    schoolCheck((int)$pdo->query("SELECT school_id FROM rooms WHERE code='IMPORT-SOE'")->fetchColumn()===2,'Explicit School Code did not override default.');
    file_put_contents($csv,"Room Code,Building,Rows,Columns\nIMPORT-MISSING,Test,1,2\n");$batch=$importer->stage($csv,'old.csv',1);
    schoolCheck((int)$pdo->query('SELECT invalid_rows FROM import_batches WHERE id='.$batch)->fetchColumn()===1,'Missing school accepted.');
    echo "School rooms: PASS (upgrade, mixed schools, shortages, unassigned rooms, manual policy, publication, history, imports)\n";
}finally{if($pdo??null){if($pdo->inTransaction())$pdo->rollBack();}if(is_file($csv))unlink($csv);$server->exec("DROP DATABASE IF EXISTS `$db`");}
