<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
$config=require BASE_PATH.'/config/database.php';$testDb='gbu_course_delete_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
    $server->exec(str_replace('gbu_exam_operations',$testDb,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $server->exec(str_replace('gbu_exam_operations',$testDb,file_get_contents(BASE_PATH.'/database/seed.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname={$testDb};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
    $pdo->exec("INSERT INTO users(role_id,username,password_hash,name,status) SELECT id,'delete_test','test','Deletion Test','active' FROM roles WHERE code='admin'");$user=(int)$pdo->lastInsertId();
    $programmes=$pdo->query('SELECT id FROM programmes ORDER BY id LIMIT 2')->fetchAll(PDO::FETCH_COLUMN);
    $pdo->exec("INSERT INTO courses(code,name) VALUES('DEL-TEST','Deletion test')");$course=(int)$pdo->lastInsertId();$ids=[];
    foreach($programmes as $programme){$pdo->prepare('INSERT INTO programme_courses(programme_id,course_id,semester) VALUES(?,?,1)')->execute([$programme,$course]);$ids[]=(int)$pdo->lastInsertId();}
    $service=new App\Exams\CourseDeletionService($pdo);$service->deleteMapping($ids[0],$user);
    assert((int)$pdo->query("SELECT COUNT(*) FROM programme_courses WHERE id={$ids[0]}")->fetchColumn()===0);
    assert((int)$pdo->query("SELECT COUNT(*) FROM programme_courses WHERE id={$ids[1]}")->fetchColumn()===1);
    assert((int)$pdo->query("SELECT COUNT(*) FROM courses WHERE id={$course}")->fetchColumn()===1);
    assert((int)$pdo->query("SELECT COUNT(*) FROM audit_logs WHERE action='course.curriculum_deleted'")->fetchColumn()===1);
    $caught=false;try{$service->deleteMapping($ids[0],$user);}catch(RuntimeException $e){$caught=true;}assert($caught);
    $exams=new App\Exams\ExamService($pdo);$cycle=$exams->createCycle(['name'=>'Delete protection','academic_year'=>'2026-2027','exam_type'=>'end_sem','start_date'=>'2026-09-15','end_date'=>'2026-09-15','duration'=>180,'shifts'=>[['name'=>'Morning','start'=>'09:30','end'=>'12:30','duration'=>180]]],$user);
    $shift=(int)$pdo->query("SELECT id FROM exam_shifts WHERE cycle_id={$cycle}")->fetchColumn();
    $exams->schedule(['cycle_id'=>$cycle,'shift_id'=>$shift,'course_id'=>$course,'programme_id'=>$programmes[1],'semester'=>1,'exam_date'=>'2026-09-15','category'=>'regular','display_label'=>'Test']);
    $caught=false;try{$service->deleteMapping($ids[1],$user);}catch(RuntimeException $e){$caught=str_contains($e->getMessage(),'examination records');}assert($caught);
    assert((int)$pdo->query("SELECT COUNT(*) FROM programme_courses WHERE id={$ids[1]}")->fetchColumn()===1);
    $pdo->prepare('INSERT INTO programme_courses(programme_id,course_id,semester) VALUES(?,?,2)')->execute([$programmes[1],$course]);$historyMapping=(int)$pdo->lastInsertId();
    $school=(int)$pdo->query('SELECT school_id FROM programmes WHERE id='.(int)$programmes[1])->fetchColumn();
    $pdo->prepare("INSERT INTO scheduling_runs(cycle_id,school_id,status,rule_snapshot,created_by) VALUES(?,?,'ready','{}',?)")->execute([$cycle,$school,$user]);$run=(int)$pdo->lastInsertId();
    $pdo->prepare("INSERT INTO scheduling_run_items(scheduling_run_id,programme_course_id,item_status) VALUES(?,?,'pending')")->execute([$run,$historyMapping]);
    $caught=false;try{$service->deleteMapping($historyMapping,$user);}catch(RuntimeException $e){$caught=str_contains($e->getMessage(),'scheduling history');}assert($caught);
    echo "Course deletion: PASS (mapping scope, shared master, audit, missing mapping, examination and scheduling-history protection)\n";
}finally{$server->exec("DROP DATABASE IF EXISTS `{$testDb}`");}
