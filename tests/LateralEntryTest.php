<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function lateralCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
$config=require BASE_PATH.'/config/database.php';$db='gbu_lateral_'.bin2hex(random_bytes(4));$file=tempnam(sys_get_temp_dir(),'lateral_');
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname=$db;charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name) VALUES('ICT','ICT'); INSERT INTO programmes(school_id,code,name,level,duration_semesters,lateral_entry) VALUES(1,'UCS','Computer Science','undergraduate',8,0),(1,'UAI','Artificial Intelligence','undergraduate',8,0),(1,'LCS','Old separate lateral programme','undergraduate',6,1); INSERT INTO batches(programme_id,label,start_year,end_year) VALUES(1,'CSE Class of 2026',2022,2026)");
    $handle=fopen($file,'wb');fputcsv($handle,['Roll Number','Enrollment Number','Academic Session','Name','Branch','Department','School','Year of Study','Semester','Section']);
    foreach(['225UCS001','235LCS001','225UAI001','235LAI001'] as $i=>$roll)fputcsv($handle,[$roll,'000000000'.($i+1),'2023-2024','Synthetic student',$i<2?'Computer Science':'Artificial Intelligence','Computing','ICT','2','3','A']);fclose($handle);
    $import=new App\Import\StudentImportService($pdo);$batch=$import->stage($file,'lateral.csv',1);
    lateralCheck((int)$pdo->query('SELECT invalid_rows FROM import_batches WHERE id='.$batch)->fetchColumn()===0,'Lateral import rejected');
    $pdo->beginTransaction();$import->commit($batch,1);$pdo->commit();
    $students=$pdo->query('SELECT * FROM students ORDER BY id')->fetchAll(PDO::FETCH_ASSOC);
    lateralCheck($students[0]['programme_id']==$students[1]['programme_id']&&$students[0]['batch_id']==$students[1]['batch_id'],'LCS did not join regular UCS class');
    lateralCheck($students[2]['programme_id']==$students[3]['programme_id']&&$students[2]['batch_id']==$students[3]['batch_id'],'LAI did not join regular UAI class');
    lateralCheck((int)$students[1]['batch_id']===1,'Custom regular batch label was duplicated');
    lateralCheck($students[1]['admission_type']==='lateral'&&$students[1]['registration_prefix']==='235'&&$students[1]['roll_no_original']==='235LCS001'&&$students[1]['programme_code_detected']==='LCS','Lateral admission identity was lost');
    lateralCheck((int)$pdo->query("SELECT COUNT(*) FROM batches WHERE start_year=2023")->fetchColumn()===0,'Lateral admission year incorrectly used as class start year');
    $rollover=new App\Academic\AcademicRollover($pdo);$rollover->run('2023-10-15',1,'test',true);
    lateralCheck((int)$pdo->query("SELECT COUNT(*) FROM students WHERE semester=3 AND current_year_of_study=2 AND status='active'")->fetchColumn()===4,'Progression did not place lateral students in second year');
    $uaiBatch=(int)$students[2]['batch_id'];
    $pdo->exec("INSERT INTO courses(code,name) VALUES('CS201','Algorithms'),('AI201','AI Foundations'); INSERT INTO programme_courses(programme_id,batch_id,course_id,semester,section,category) VALUES(1,1,1,3,'ALL','core'),(2,$uaiBatch,2,3,'ALL','core')");
    $exam=new App\Exams\ExamService($pdo);$cycle=$exam->createCycle(['name'=>'Shared lateral exams','academic_year'=>'2023-2024','exam_type'=>'mid_sem','start_date'=>'2023-10-16','end_date'=>'2023-10-16','duration'=>90,'batch_ids'=>[1,$uaiBatch],'shifts'=>[['name'=>'Morning','start'=>'10:00','end'=>'11:30','duration'=>90]]],1);
    $shift=(int)$pdo->query('SELECT id FROM exam_shifts WHERE cycle_id='.$cycle)->fetchColumn();
    foreach([[1,1,'CSE Class of 2026'],[2,2,'UAI 2022-2026']] as [$programme,$course,$label])$exam->schedule(['cycle_id'=>$cycle,'shift_id'=>$shift,'course_id'=>$course,'programme_id'=>$programme,'semester'=>3,'section'=>'ALL','batch_label'=>$label,'exam_date'=>'2023-10-16','category'=>'regular']);
    lateralCheck((int)$pdo->query("SELECT COUNT(*) FROM exam_eligibility WHERE eligibility_status='eligible'")->fetchColumn()===4,'Regular exam omitted lateral students');
    $roster=(new App\Seating\SeatingRoster($pdo))->eligible($cycle,'2023-10-16',$shift);
    lateralCheck(count($roster)===4,'Lateral students missing from seating roster');$groups=App\Seating\SeatingRoster::groups($roster);lateralCheck(count($groups)===2,'Lateral students treated as separate seating branch');
    $keys=[];foreach($roster as $student)$keys[$student['normalized_roll_no']]=$student['group_key'];
    lateralCheck($keys['225UCS001']===$keys['235LCS001']&&$keys['225UAI001']===$keys['235LAI001'],'Same-class lateral students have different seating identities');
    echo "Lateral entry: PASS (LCS/UCS, LAI/UAI without separate lateral programme, prior-year/custom batch reuse, roll preservation, progression, shared exams and seating groups)\n";
}finally{if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();if(is_file($file))unlink($file);$server->exec("DROP DATABASE IF EXISTS `$db`");}
