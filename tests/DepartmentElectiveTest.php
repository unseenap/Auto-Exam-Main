<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
App\Foundation\Environment::load(BASE_PATH.'/.env');
function electiveCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
$config=require BASE_PATH.'/config/database.php';$testDb='gbu_electives_'.bin2hex(random_bytes(4));
if(!preg_match('/^gbu_electives_[a-f0-9]{8}$/',$testDb))throw new RuntimeException('Unsafe database name.');
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
 $server->exec(str_replace('gbu_exam_operations',$testDb,file_get_contents(BASE_PATH.'/database/schema.sql')));
 $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname={$testDb};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false]);
 $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name) VALUES('ICT','ICT'); INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','CSE','undergraduate',8),(1,'UAI','AI','undergraduate',8); INSERT INTO batches(programme_id,label,start_year,end_year) VALUES(1,'UCS 2024-2028',2024,2028),(1,'UCS 2023-2027',2023,2027),(2,'UAI 2024-2028',2024,2028); INSERT INTO courses(code,name) VALUES('EL1','Department elective'),('EL2','Unused elective alternative'); INSERT INTO programme_courses(programme_id,batch_id,course_id,semester,category) VALUES(1,1,1,5,'elective'),(1,1,2,5,'elective')");
 $insert=$pdo->prepare("INSERT INTO students(programme_id,batch_id,roll_no_original,normalized_roll_no,name,academic_session,current_year_of_study,semester,section,status) VALUES(?,?,?,?,?,'2026-2027',3,5,?,?)");
 foreach([[1,1,'245UCS501','A','active'],[1,1,'245UCS502','A','active'],[1,1,'245UCS503','B','active'],[1,1,'245UCS504','B','active'],[1,2,'235UCS501','A','active'],[2,3,'245UAI501','A','active'],[1,1,'245UCS505','A','inactive']] as [$p,$b,$roll,$section,$status])$insert->execute([$p,$b,$roll,$roll,'Demo '.$roll,$section,$status]);
 (new App\Academic\AcademicRollover($pdo))->run('2026-10-24',1,'test');
 electiveCheck((int)$pdo->query('SELECT COUNT(*) FROM student_course_registrations')->fetchColumn()===0,'Unselected alternatives were assigned.');
 $exam=new App\Exams\ExamService($pdo);
 $cycle=$exam->createCycle(['name'=>'Department electives','academic_year'=>'2026-2027','exam_type'=>'mid_sem','start_date'=>'2026-10-26','end_date'=>'2026-10-28','duration'=>90,'batch_ids'=>[1],'shifts'=>[['name'=>'Morning','start'=>'09:00','end'=>'10:30','duration'=>90]]],1);
 $shift=(int)$pdo->query('SELECT id FROM exam_shifts WHERE cycle_id='.$cycle)->fetchColumn();
 $data=['cycle_id'=>$cycle,'shift_id'=>$shift,'course_id'=>1,'exam_date'=>'2026-10-26','category'=>'regular','programme_id'=>1,'semester'=>5,'section'=>'ALL','batch_label'=>'UCS 2024-2028'];
 $paper=$exam->schedule($data);
 electiveCheck((int)$pdo->query("SELECT COUNT(*) FROM exam_eligibility WHERE examination_id=$paper AND eligibility_status='eligible'")->fetchColumn()===4,'Elective did not cover both class sections or included another cohort.');
 electiveCheck((int)$pdo->query('SELECT COUNT(*) FROM student_course_registrations WHERE programme_course_id=1')->fetchColumn()===4,'Department registrations missing.');
 electiveCheck((int)$pdo->query('SELECT COUNT(*) FROM student_course_registrations WHERE programme_course_id=2')->fetchColumn()===0,'Unscheduled elective alternative assigned.');
 $scope=$exam->resolveRegistrations($data+['roll_numbers'=>'245UCS501']);electiveCheck($scope['student_ids']===null,'Individual roll list restricted a department elective.');
 $repeat=$data;$repeat['category']='repeat';$caught=false;try{$exam->resolveRegistrations($repeat);}catch(RuntimeException $e){$caught=str_contains($e->getMessage(),'Roll Numbers');}electiveCheck($caught,'Repeat paper no longer requires explicit registration.');
 // Repair a published date sheet before seating, including old subset exclusions.
 $pdo->exec("UPDATE examinations SET status='published' WHERE id=$paper; UPDATE exam_eligibility SET eligibility_status='pending' WHERE examination_id=$paper; UPDATE exam_eligibility SET eligibility_status='ineligible',source='registration' WHERE examination_id=$paper AND student_id=2; DELETE FROM exam_eligibility WHERE examination_id=$paper AND student_id=4");
 $sync=new App\Academic\DepartmentElectiveRegistrations($pdo);$sync->synchronize($cycle);
 electiveCheck((int)$pdo->query("SELECT COUNT(*) FROM exam_eligibility WHERE examination_id=$paper AND eligibility_status='eligible'")->fetchColumn()===4,'Old pending/subset registrations not repaired.');
 electiveCheck($sync->synchronize($cycle)['eligibility_changes']===0,'Repeated reconciliation changed stable registrations.');
 $csv=tempnam(__DIR__,'dept_elective_');
 try{
     file_put_contents($csv,"Exam Date,Shift,Course Code,Course Name,Programme Code,Batch Label,Semester,Section,Category,Roll Numbers\n2026-10-27,1,EL1,Department elective,UCS,UCS 2024-2028,5,ALL,regular,\n");
     $importer=new App\Import\DateSheetImportService($pdo);$batch=$importer->stage($cycle,$csv,'department.csv',1);
     electiveCheck((int)$pdo->query('SELECT valid_rows FROM import_batches WHERE id='.$batch)->fetchColumn()===1,'Elective import required roll numbers.');
     $normal=json_decode($pdo->query('SELECT normalized_data FROM import_rows WHERE import_batch_id='.$batch)->fetchColumn(),true);
     electiveCheck(($normal['registration_scope']??'')==='Whole class - department elective','Import preview does not show class-wide assignment.');
     $pdo->beginTransaction();$importer->commit($batch,1);$pdo->commit();
     $imported=(int)$pdo->query("SELECT id FROM examinations WHERE cycle_id=$cycle AND exam_date='2026-10-27'")->fetchColumn();
     electiveCheck((int)$pdo->query("SELECT COUNT(*) FROM exam_eligibility WHERE examination_id=$imported AND eligibility_status='eligible'")->fetchColumn()===4,'Imported elective missed class students.');
 }finally{if(is_file($csv))unlink($csv);}
 $automatic=$exam->createCycle(['name'=>'Automatic electives','academic_year'=>'2026-2027','exam_type'=>'mid_sem','start_date'=>'2026-11-02','end_date'=>'2026-11-04','duration'=>90,'batch_ids'=>[1],'shifts'=>[['name'=>'Morning','start'=>'09:00','end'=>'10:30','duration'=>90]]],1);
 $scope=['cycle_id'=>$automatic,'school_id'=>1,'programme_ids'=>[1],'batch_ids'=>[1],'semesters'=>[5],'programme_course_ids'=>[1],'subject_selection_active'=>1,'minimum_gap_days'=>0,'maximum_papers_per_day'=>1];
 $validation=(new App\Exams\SchedulingValidator($pdo))->validate($scope,1);
 electiveCheck($validation['status']==='ready','Automatic elective validation blocked.');
 (new App\Exams\AutomaticScheduler($pdo))->generate((int)$validation['run_id'],1);
 electiveCheck((int)$pdo->query("SELECT COUNT(*) FROM exam_eligibility ee JOIN examinations e ON e.id=ee.examination_id WHERE e.cycle_id=$automatic AND ee.eligibility_status='eligible'")->fetchColumn()===4,'Automatic generation left elective candidates pending.');
 $pdo->exec("INSERT INTO rooms(code,building,rows_count,columns_count,physical_capacity,usable_capacity,seat_order,status) VALUES('DEMO','Demo',2,3,6,6,'row_major','active')");
 $pdo->exec('UPDATE rooms SET school_id=1');
 (new App\Rooms\RoomSeatGenerator($pdo))->regenerate(1,2,3,'row_major');
 $seating=(new App\Seating\SeatingAllocator($pdo))->generate($cycle,'2026-10-26',$shift,[1],1,'elective-test');
 electiveCheck($seating['assigned']===4&&$seating['unallocated']===0,'Whole-class elective seating failed.');
 $pdo->exec("UPDATE seating_allocations SET status='published' WHERE id=".$seating['allocation_id']);
 $pdo->exec("UPDATE exam_eligibility SET eligibility_status='pending' WHERE examination_id=$paper AND student_id=1");
 electiveCheck($sync->synchronize($cycle)['protected_sessions']===1,'Published seating not protected.');
 electiveCheck($pdo->query("SELECT eligibility_status FROM exam_eligibility WHERE examination_id=$paper AND student_id=1")->fetchColumn()==='pending','Protected seating registrations were changed.');
 echo "Department electives: PASS (whole class, sections and batch boundaries, no roll list, selected offerings only, legacy pending repair, idempotency, seating, published seating protection, explicit repeats).\n";
}finally{$server->exec('DROP DATABASE IF EXISTS `'.$testDb.'`');}
