<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
App\Foundation\Environment::load(BASE_PATH.'/.env');
use App\Academic\AcademicRollover;
function rolloverCheck(bool $ok,string $why):void{if(!$ok)throw new RuntimeException($why);}
$config=require BASE_PATH.'/config/database.php';$testDb='gbu_rollover_test_'.bin2hex(random_bytes(4));
if(!preg_match('/^gbu_rollover_test_[a-f0-9]{8}$/',$testDb))throw new RuntimeException('Unsafe test database');
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
 $server->exec(str_replace('gbu_exam_operations',$testDb,file_get_contents(BASE_PATH.'/database/schema.sql')));
 $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname={$testDb};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false]);
 $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name) VALUES('ICT','ICT'); INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','CSE','undergraduate',8); INSERT INTO batches(programme_id,label,start_year,end_year) VALUES(1,'UCS 2024-2028',2024,2028),(1,'UCS 2022-2026',2022,2026),(1,'UCS 2027-2031',2027,2031); INSERT INTO courses(code,name) VALUES('CORE5','Core five'),('ELECT5','Elective five'),('CORE6','Core six'); INSERT INTO programme_courses(programme_id,batch_id,course_id,semester,category) VALUES(1,1,1,5,'core'),(1,1,2,5,'elective'),(1,1,3,6,'core')");
 $insert=$pdo->prepare("INSERT INTO students(programme_id,batch_id,roll_no_original,normalized_roll_no,name,academic_session,current_year_of_study,semester,section,status,special_status) VALUES(1,?,?,?,?,'2026-2027',?,?, 'A',?,?)");
 foreach([[1,'245UCS501',3,5,'active','none'],[1,'245UCS502',2,3,'active','not_promoted'],[2,'225UCS501',4,8,'active','none'],[3,'275UCS501',1,1,'active','none'],[1,'245UCS503',3,5,'inactive','none']] as [$batch,$roll,$year,$sem,$status,$special])$insert->execute([$batch,$roll,$roll,'Demo '.$roll,$year,$sem,$status,$special]);
 $pdo->exec("INSERT INTO students(roll_no_original,normalized_roll_no,name) VALUES('UNMAPPED','UNMAPPED','No batch')");
 $service=new AcademicRollover($pdo);$preview=$service->preview('2026-10-22');
 rolloverCheck($preview['counts']['blocked']===1&&$preview['counts']['held']===1&&$preview['counts']['awaiting_completion']===1,'Preview exceptions incorrect');
 rolloverCheck((int)$pdo->query('SELECT COUNT(*) FROM student_term_enrollments')->fetchColumn()===0,'Preview wrote records');
 $run=$service->run('2026-10-22',1,'test');
 rolloverCheck($run['blocked']===1&&$run['registrations']===1,'Core registration or exception counts wrong');
 rolloverCheck((int)$pdo->query('SELECT COUNT(*) FROM student_course_registrations r JOIN programme_courses pc ON pc.id=r.programme_course_id WHERE pc.category=\'elective\'')->fetchColumn()===0,'Elective choice invented');
 rolloverCheck($pdo->query('SELECT placement_status FROM student_term_enrollments WHERE student_id=3 ORDER BY id DESC LIMIT 1')->fetchColumn()==='awaiting_completion','Completion assumed');
 rolloverCheck($pdo->query('SELECT status FROM students WHERE id=3')->fetchColumn()==='inactive','Awaiting completion remains in normal active cohort');
 $history=(int)$pdo->query('SELECT COUNT(*) FROM student_academic_history')->fetchColumn();$terms=(int)$pdo->query('SELECT COUNT(*) FROM student_term_enrollments')->fetchColumn();
 rolloverCheck(!empty($service->run('2026-10-22',1,'test')['skipped']),'Daily execution not idempotent');
 $again=$service->run('2026-10-22',1,'test',true);
 rolloverCheck($again['updated']===0&&(int)$pdo->query('SELECT COUNT(*) FROM student_academic_history')->fetchColumn()===$history&&(int)$pdo->query('SELECT COUNT(*) FROM student_term_enrollments')->fetchColumn()===$terms,'Repeated run changed history or term snapshots');
 rolloverCheck(!empty($service->run('2026-10-23',1,'test')['skipped']),'Same-period daily check rescanned placements');
 $service->run('2027-01-01',1,'test');
 rolloverCheck((int)$pdo->query('SELECT semester FROM students WHERE id=1')->fetchColumn()===6,'Even semester not advanced');
 rolloverCheck((int)$pdo->query('SELECT semester FROM students WHERE id=2')->fetchColumn()===3,'Held student advanced');
 $service->run('2027-07-01',1,'test');
 rolloverCheck((int)$pdo->query('SELECT current_year_of_study FROM students WHERE id=1')->fetchColumn()===4&&(int)$pdo->query('SELECT semester FROM students WHERE id=1')->fetchColumn()===7,'Year 3 did not advance to Year 4');
 rolloverCheck((int)$pdo->query('SELECT semester FROM student_term_enrollments WHERE student_id=1 AND academic_session=\'2026-2027\' AND term=1')->fetchColumn()===5,'Previous semester overwritten');
 // Cycle eligibility reads a historical snapshot after the live directory advances.
 $pdo->exec("INSERT INTO exam_cycles(name,academic_year,exam_type,start_date,end_date,default_duration_minutes,created_by) VALUES('Historical','2026-2027','mid_sem','2026-10-10','2026-10-20',90,1)");
 $eligible=(new App\Academic\StudentExamPlacement($pdo))->cohort(1,1,1,5,'A');
 rolloverCheck(in_array(1,array_map('intval',array_column($eligible,'id')),true),'Historical exam lost promoted student');
 $pdo->exec("INSERT INTO exam_shifts(cycle_id,name,start_time,end_time,duration_minutes,sequence_no) VALUES(1,'Morning','09:00','10:30',90,1); INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,status) VALUES(1,1,1,'2026-10-10','draft'),(1,1,1,'2026-10-11','published'); INSERT INTO examination_cohorts(examination_id,programme_id,batch_id,semester,section) VALUES(1,1,1,5,'A'),(2,1,1,5,'A'); INSERT INTO exam_eligibility(examination_id,student_id,source) VALUES(1,2,'registration')");
 (new App\Academic\DraftExamEligibility($pdo))->refresh();
 rolloverCheck((int)$pdo->query("SELECT COUNT(*) FROM exam_eligibility WHERE examination_id=1 AND student_id=1 AND source='cohort'")->fetchColumn()===1,'Draft did not receive historical cohort registration');
 rolloverCheck((int)$pdo->query("SELECT COUNT(*) FROM exam_eligibility WHERE examination_id=1 AND student_id=2 AND source='registration'")->fetchColumn()===1,'Explicit registration was removed');
 rolloverCheck((int)$pdo->query('SELECT COUNT(*) FROM exam_eligibility WHERE examination_id=2')->fetchColumn()===0,'Published eligibility was rewritten');
 $service->setControl(2,'automatic',2,'Repeat year approved',1);$service->run('2027-07-01',1,'test',true);
 rolloverCheck((int)$pdo->query('SELECT semester FROM students WHERE id=2')->fetchColumn()===5,'Repeat year delay not retained');
 $service->setControl(3,'completed',0,'Completion verified by examination cell',1);$service->run('2027-07-01',1,'test',true);
 rolloverCheck($pdo->query('SELECT status FROM students WHERE id=3')->fetchColumn()==='completed','Verified completion failed');
 // A failed run must restore placements, history, registrations and last-check metadata.
 $before=$pdo->query('SELECT * FROM students ORDER BY id')->fetchAll();$beforeHistory=$pdo->query('SELECT COUNT(*) FROM student_academic_history')->fetchColumn();
 $pdo->exec("CREATE TRIGGER rollover_failure BEFORE INSERT ON student_academic_history FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Simulated history failure'");
 $failed=false;try{$service->run('2028-01-01',1,'test',true);}catch(Throwable){$failed=true;}
 rolloverCheck($failed&&$before===$pdo->query('SELECT * FROM students ORDER BY id')->fetchAll()&&$beforeHistory===$pdo->query('SELECT COUNT(*) FROM student_academic_history')->fetchColumn(),'Failed rollover was not atomic');
 $pdo->exec('DROP TRIGGER rollover_failure');
 $service->saveSettings(false,'07-01','01-01',1);rolloverCheck(!empty($service->run('2028-01-01',1,'test',true)['skipped']),'Disabled progression ran');
 echo "Academic rollover: PASS (preview, core registrations, holds, repeated-year delay, completion, historical eligibility, idempotency, transaction rollback, disabled mode).\n";
}finally{$server->exec('DROP DATABASE IF EXISTS `'.$testDb.'`');}
