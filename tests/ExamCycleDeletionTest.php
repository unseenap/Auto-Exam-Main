<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
$config=require BASE_PATH.'/config/database.php';$testDb='gbu_cycle_delete_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
    $server->exec(str_replace('gbu_exam_operations',$testDb,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $server->exec(str_replace('gbu_exam_operations',$testDb,file_get_contents(BASE_PATH.'/database/seed.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname={$testDb};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
    $pdo->exec("INSERT INTO users(role_id,username,password_hash,name,status) SELECT id,'delete_test','test','Deletion Test','active' FROM roles WHERE code='admin'");$user=(int)$pdo->lastInsertId();

    $exams=new App\Exams\ExamService($pdo);
    $cycle=$exams->createCycle(['name'=>'Delete cycle test','academic_year'=>'2026-2027','exam_type'=>'end_sem','start_date'=>'2026-09-15','end_date'=>'2026-09-15','duration'=>180,'shifts'=>[['name'=>'Morning','start'=>'09:30','end'=>'12:30','duration'=>180]]],$user);
    $mapping=$pdo->query("SELECT pc.* FROM programme_courses pc JOIN courses c ON c.id=pc.course_id WHERE c.name NOT LIKE '%Lab%' LIMIT 1")->fetch(PDO::FETCH_ASSOC);
    $shift=(int)$pdo->query("SELECT id FROM exam_shifts WHERE cycle_id={$cycle}")->fetchColumn();
    $exam=$exams->schedule(['cycle_id'=>$cycle,'shift_id'=>$shift,'course_id'=>$mapping['course_id'],'programme_id'=>$mapping['programme_id'],'semester'=>$mapping['semester'],'exam_date'=>'2026-09-15','category'=>'regular','display_label'=>'Test']);
    $service=new App\Exams\ExamCycleDeletionService($pdo);$preview=$service->preview($cycle);$fingerprint=$service::fingerprint($preview);
    assert($preview['counts']['Papers']===1);
    foreach([['wrong name',$fingerprint],['Delete cycle test','stale']] as [$name,$hash]){
        $caught=false;try{$service->delete($cycle,$user,$name,$hash);}catch(RuntimeException $e){$caught=true;}assert($caught);
        assert((int)$pdo->query("SELECT COUNT(*) FROM examinations WHERE id={$exam}")->fetchColumn()===1);
    }
    $pdo->prepare("UPDATE exam_cycles SET status='published' WHERE id=?")->execute([$cycle]);
    $caught=false;try{$service->preview($cycle);}catch(RuntimeException $e){$caught=true;}assert($caught);
    $pdo->prepare("UPDATE examinations SET status='published' WHERE id=?")->execute([$exam]);
    // Published automatic schedules retain shift references through run items.
    $school=(int)$pdo->query('SELECT school_id FROM programmes WHERE id='.(int)$mapping['programme_id'])->fetchColumn();
    $pdo->prepare("INSERT INTO scheduling_runs(cycle_id,school_id,status,rule_snapshot,created_by) VALUES(?,?,'published','{}',?)")->execute([$cycle,$school,$user]);$run=(int)$pdo->lastInsertId();
    $pdo->prepare("INSERT INTO scheduling_run_items(scheduling_run_id,examination_id,programme_course_id,assigned_date,shift_id,item_status) VALUES(?,?,?,'2026-09-15',?,'scheduled')")->execute([$run,$exam,$mapping['id'],$shift]);
    $pdo->prepare('UPDATE examinations SET generated_by_run_id=? WHERE id=?')->execute([$run,$exam]);
    $pdo->exec("INSERT INTO users(role_id,username,password_hash,name,status) SELECT id,'controller_test','test','Controller','active' FROM roles WHERE code='examination_controller'");$controller=(int)$pdo->lastInsertId();
    $caught=false;try{$service->preview($cycle,$controller);}catch(RuntimeException $e){$caught=true;}assert($caught);
    $preview=$service->preview($cycle,$user);
    $caught=false;try{$service->delete($cycle,$controller,'Delete cycle test',$service::fingerprint($preview));}catch(RuntimeException $e){$caught=true;}assert($caught);
    $service->delete($cycle,$user,'Delete cycle test',$service::fingerprint($preview));
    assert((int)$pdo->query("SELECT COUNT(*) FROM scheduling_runs WHERE id={$run}")->fetchColumn()===0);
    assert((int)$pdo->query("SELECT COUNT(*) FROM scheduling_run_items WHERE scheduling_run_id={$run}")->fetchColumn()===0);
    foreach(['exam_cycles'=>'id','examinations'=>'cycle_id','exam_shifts'=>'cycle_id','exam_calendar_dates'=>'cycle_id'] as $table=>$column)assert((int)$pdo->query("SELECT COUNT(*) FROM {$table} WHERE {$column}={$cycle}")->fetchColumn()===0);
    assert((int)$pdo->query("SELECT COUNT(*) FROM courses WHERE id=".(int)$mapping['course_id'])->fetchColumn()===1);
    assert((int)$pdo->query("SELECT COUNT(*) FROM audit_logs WHERE action='exam_cycle.deleted'")->fetchColumn()===1);
    echo "Exam cycle deletion: PASS (name confirmation, stale review, admin-only published deletion, linked records, master preservation, audit)\n";
}finally{$server->exec("DROP DATABASE IF EXISTS `{$testDb}`");}
