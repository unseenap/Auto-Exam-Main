<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
use App\Exams\AutomaticScheduler;use App\Exams\ExamService;use App\Exams\SchedulingValidator;
$config=require BASE_PATH.'/config/database.php';$testDb='gbu_gap_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
 $server->exec(str_replace('gbu_exam_operations',$testDb,file_get_contents(BASE_PATH.'/database/schema.sql')));$server->exec(str_replace('gbu_exam_operations',$testDb,file_get_contents(BASE_PATH.'/database/seed.sql')));
 $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname={$testDb};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
 $pdo->exec("INSERT INTO users(role_id,username,password_hash,name,status) SELECT id,'gap_test','test','Gap Test','active' FROM roles WHERE code='admin'");$user=(int)$pdo->lastInsertId();
 $pdo->exec("INSERT INTO schools(code,name,short_name,status) VALUES('GAP','Gap Test School','GAP','active')");$school=(int)$pdo->lastInsertId();
 $pdo->prepare("INSERT INTO programmes(school_id,code,name,duration_semesters,status) VALUES(?,'GAP','Gap Test Branch',12,'active')")->execute([$school]);$programme=(int)$pdo->lastInsertId();
 foreach([1=>9,2=>8,3=>12] as $semester=>$total){for($i=1;$i<=$total;$i++){$code='GP-'.$semester.'-'.str_pad((string)$i,2,'0',STR_PAD_LEFT);$pdo->prepare("INSERT INTO courses(code,name,status) VALUES(?,?,'active')")->execute([$code,'Written Paper '.$i]);$course=(int)$pdo->lastInsertId();$pdo->prepare("INSERT INTO programme_courses(programme_id,course_id,semester,category,subject_priority) VALUES(?,?,?,'core',?)")->execute([$programme,$course,$semester,$i]);}}
 $examService=new ExamService($pdo);
 foreach([[1,9],[2,8]] as [$semester,$paperCount]){
  $cycle=$examService->createCycle(['name'=>'Gap case '.$paperCount,'academic_year'=>'2026-2027','exam_type'=>'end_sem','start_date'=>'2026-10-05','end_date'=>'2026-10-14','duration'=>180,'shifts'=>[['name'=>'Morning','start'=>'09:30','end'=>'12:30','duration'=>180]]],$user);
  assert((int)$pdo->query("SELECT COUNT(*) FROM exam_calendar_dates WHERE cycle_id={$cycle} AND is_exam_day=1")->fetchColumn()===9);
  $validation=(new SchedulingValidator($pdo))->validate(['cycle_id'=>$cycle,'school_id'=>$school,'programme_ids'=>[$programme],'semesters'=>[$semester],'minimum_gap_days'=>1,'maximum_papers_per_day'=>1,'use_subject_priority'=>1],$user);
  assert($validation['status']==='ready'&&$validation['blocked']===0);
  assert(count(array_filter($validation['checks'],static fn(array $check):bool=>$check['code']==='gap.window'&&$check['state']==='warning'))===1);
  $result=(new AutomaticScheduler($pdo))->generate($validation['run_id'],$user);assert($result['scheduled']===$paperCount&&$result['unscheduled']===0);
  assert((int)$pdo->query("SELECT COUNT(DISTINCT exam_date) FROM examinations WHERE cycle_id={$cycle}")->fetchColumn()===$paperCount);
  $dates=$pdo->query("SELECT e.exam_date,pc.subject_priority FROM examinations e JOIN programme_courses pc ON pc.course_id=e.course_id AND pc.programme_id={$programme} WHERE e.cycle_id={$cycle} ORDER BY pc.subject_priority")->fetchAll();
  assert((int)(new DateTimeImmutable($dates[0]['exam_date']))->diff(new DateTimeImmutable($dates[1]['exam_date']))->days>=2);
 }
 $flexCycle=$examService->createCycle(['name'=>'Flexible twelve papers','academic_year'=>'2026-2027','exam_type'=>'end_sem','start_date'=>'2026-10-05','end_date'=>'2026-10-15','duration'=>180,'shifts'=>[['name'=>'Morning','start'=>'09:30','end'=>'12:30','duration'=>180],['name'=>'Afternoon','start'=>'14:00','end'=>'17:00','duration'=>180]]],$user);
 assert((int)$pdo->query("SELECT COUNT(*) FROM exam_calendar_dates WHERE cycle_id={$flexCycle} AND is_exam_day=1")->fetchColumn()===10);
 $flexValidation=(new SchedulingValidator($pdo))->validate(['cycle_id'=>$flexCycle,'school_id'=>$school,'programme_ids'=>[$programme],'semesters'=>[3],'minimum_gap_days'=>1,'maximum_papers_per_day'=>1,'use_subject_priority'=>1],$user);
 assert($flexValidation['status']==='ready'&&$flexValidation['blocked']===0);
 assert(count(array_filter($flexValidation['checks'],static fn(array $check):bool=>$check['code']==='slots.capacity'&&$check['state']==='warning'))===1);
 $flexResult=(new AutomaticScheduler($pdo))->generate($flexValidation['run_id'],$user);assert($flexResult['scheduled']===12&&$flexResult['unscheduled']===0);
 assert((int)$pdo->query("SELECT MAX(papers) FROM (SELECT COUNT(*) AS papers FROM examinations WHERE cycle_id={$flexCycle} GROUP BY exam_date)x")->fetchColumn()===2);
 assert((int)$pdo->query("SELECT COUNT(DISTINCT CONCAT(exam_date,'-',shift_id)) FROM examinations WHERE cycle_id={$flexCycle}")->fetchColumn()===12);
 echo "Preferred gap: PASS (8/9 paper spacing and adaptive 12-paper scheduling across configured shifts)\n";
}finally{$server->exec("DROP DATABASE IF EXISTS `{$testDb}`");}
