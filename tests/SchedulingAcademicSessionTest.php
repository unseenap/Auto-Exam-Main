<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function sessionCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
$config=require BASE_PATH.'/config/database.php';$db='gbu_schedule_session_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname=$db;charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name) VALUES('ICT','ICT'),('ENG','Engineering'); INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','Computer Science','undergraduate',8); INSERT INTO batches(programme_id,label,start_year,end_year) VALUES(1,'UCS 2025-2029',2025,2029); INSERT INTO courses(code,name) VALUES('CS101','First Semester Paper'),('CS301','Third Semester Paper'); INSERT INTO programme_courses(programme_id,batch_id,course_id,semester,category) VALUES(1,1,1,1,'core'),(1,1,2,3,'core')");
    $cycle=(new App\Exams\ExamService($pdo))->createCycle(['name'=>'Delayed session examination','academic_year'=>'2025-2026','exam_type'=>'mid_sem','start_date'=>'2026-10-26','end_date'=>'2026-10-28','duration'=>90,'batch_ids'=>[1],'shifts'=>[['name'=>'Morning','start'=>'10:00','end'=>'11:30','duration'=>90]]],1);
    // The test cycle explicitly schedules its admission batch.
    $pdo->prepare('INSERT IGNORE INTO exam_cycle_batches(cycle_id,batch_id) VALUES(?,1)')->execute([$cycle]);
    $scope=['cycle_id'=>$cycle,'school_id'=>1,'programme_ids'=>[1],'batch_ids'=>[1],'semesters'=>[1],'programme_course_ids'=>[1],'subject_selection_active'=>1,'minimum_gap_days'=>0,'maximum_papers_per_day'=>1];
    $validator=new App\Exams\SchedulingValidator($pdo);$result=$validator->validate($scope,1,false);
    sessionCheck($result['blocked']===0&&$result['status']==='ready','Academic-session/date mismatch blocked scheduling');
    $checks=array_column($result['checks'],null,'code');sessionCheck(($checks['cycle.academic_session']['state']??'')==='warning','Session mismatch is not a non-blocking notice');
    sessionCheck($result['scope']['batch_semesters'][1]===1,'Calendar date silently changed the chosen cycle semester');
    sessionCheck($pdo->query('SELECT academic_year FROM exam_cycles WHERE id='.$cycle)->fetchColumn()==='2025-2026','Validation changed the academic year');
    $persisted=$validator->validate($scope,1);sessionCheck($persisted['status']==='ready','Persisted validation remained failed');
    $generated=(new App\Exams\AutomaticScheduler($pdo))->generate($persisted['run_id'],1);sessionCheck($generated['scheduled']===1&&$generated['unscheduled']===0,'Date sheet did not generate after the notice');
    sessionCheck((int)$pdo->query('SELECT COUNT(*) FROM examinations WHERE cycle_id='.$cycle.' AND course_id=1')->fetchColumn()===1,'Selected semester paper was not generated');
    sessionCheck((int)$pdo->query('SELECT COUNT(*) FROM examinations WHERE cycle_id='.$cycle.' AND course_id=2')->fetchColumn()===0,'Future semester leaked into the date sheet');
    $pdo->exec("UPDATE courses SET status='inactive' WHERE id=1; UPDATE programme_courses SET subject_priority=0 WHERE id=1");
    $issues=$validator->validate($scope,1,false);$issueChecks=array_column($issues['checks'],null,'code');
    sessionCheck($issueChecks['courses.inactive']['details']['programme_course_ids']===[1],'Inactive-paper error did not identify its selection');
    sessionCheck($issueChecks['priority.invalid']['details']['programme_course_ids']===[1],'Priority error did not identify its selection');
    foreach(['priority.invalid','courses.inactive'] as $code){sessionCheck(str_contains($issueChecks[$code]['message'],'CS101')&&str_contains($issueChecks[$code]['message'],'UCS 2025-2029')&&str_contains($issueChecks[$code]['message'],'Semester 1'),'Subject problem lacks branch/batch/semester context');}
    $missingScope=$scope;$missingScope['programme_course_ids']=[2];$missingResult=$validator->validate($missingScope,1,false);$missingChecks=array_column($missingResult['checks'],null,'code');
    sessionCheck(str_contains($missingChecks['curriculum.selection_invalid']['message'],'CS301')&&str_contains($missingChecks['curriculum.selection_invalid']['message'],'UCS 2025-2029'),'Unavailable selected subject lacks details');
    sessionCheck(str_contains($missingChecks['curriculum.missing']['message'],'UCS 2025-2029')&&str_contains($missingChecks['curriculum.missing']['message'],'Semester 1'),'Missing curriculum lacks batch/semester details');
    $app=new App\Foundation\Application(BASE_PATH);$app->boot();$database=new App\Foundation\Database(array_merge($config,['database'=>$db]));(new ReflectionProperty($database,'connection'))->setValue($database,$pdo);(new ReflectionProperty($app,'database'))->setValue($app,$database);(new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));$app->session()->put('user',['id'=>1,'name'=>'Tester','role_code'=>'admin','role_name'=>'Admin']);$app->session()->put('automatic_scope_'.$cycle,$scope);$app->session()->flash('validation_result',$issues);
    $data=(new ReflectionMethod($app,'automaticScheduleData'))->invoke($app,$cycle);
    sessionCheck(in_array(1,array_map('intval',array_column($data['curriculum'],'id')),true),'Selected inactive paper is hidden from the scheduling form');
    $out=BASE_PATH.'/outputs/scheduler-validation-highlights';if(!is_dir($out))mkdir($out,0770,true);file_put_contents($out.'/planner.html',App\View\View::render('exams/automatic',$data));file_put_contents($out.'/issues.json',json_encode($issues,JSON_THROW_ON_ERROR));
    $pdo->exec("UPDATE courses SET status='active' WHERE id=1; UPDATE programme_courses SET subject_priority=50 WHERE id=1");
    $wrongSchool=$scope;$wrongSchool['school_id']=2;$bad=$validator->validate($wrongSchool,1,false);sessionCheck($bad['blocked']>0,'Wrong-school validation was weakened');
    $pdo->exec('UPDATE batches SET start_year=2010,end_year=2014 WHERE id=1');$bad=$validator->validate($scope,1,false);$badChecks=array_column($bad['checks'],null,'code');sessionCheck(($badChecks['scope.completed_batches']['state']??'')==='blocked','Completed-batch validation was weakened');
    sessionCheck($badChecks['scope.completed_batches']['details']['batch_ids']===[1],'Completed-batch error did not identify its selection');
    echo "Scheduling academic session: PASS (non-blocking date mismatch, persisted ready state, generation, cycle-year semester retained, school and completed-batch guards)\n";
}finally{if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();$server->exec("DROP DATABASE IF EXISTS `$db`");}
