<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function checkDraft(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
$config=require BASE_PATH.'/config/database.php';$db='gbu_draft_delete_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname=$db;charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name) VALUES('ICT','ICT'); INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','Computer Science','undergraduate',8); INSERT INTO batches(programme_id,label,start_year,end_year) VALUES(1,'UCS 2025-2029',2025,2029); INSERT INTO courses(code,name) VALUES('CS101','Paper'); INSERT INTO programme_courses(programme_id,batch_id,course_id,semester,category) VALUES(1,1,1,1,'core')");
    $cycle=(new App\Exams\ExamService($pdo))->createCycle(['name'=>'Draft deletion test','academic_year'=>'2025-2026','exam_type'=>'mid_sem','start_date'=>'2026-10-26','end_date'=>'2026-10-28','duration'=>90,'batch_ids'=>[1],'shifts'=>[['name'=>'Morning','start'=>'10:00','end'=>'11:30','duration'=>90]]],1);
    $service=new App\Exams\DraftDateSheetDeletion($pdo);
    $makeRun=function(string $status='generated')use($pdo,$cycle):int{$pdo->prepare("INSERT INTO scheduling_runs(cycle_id,school_id,status,rule_snapshot,created_by) VALUES(?,1,?,'{}',1)")->execute([$cycle,$status]);return (int)$pdo->lastInsertId();};
    $makePaper=function(int $run)use($pdo,$cycle):int{$pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,generated_by_run_id) VALUES(?,1,1,'2026-10-26',?)")->execute([$cycle,$run]);$id=(int)$pdo->lastInsertId();$pdo->prepare("INSERT INTO scheduling_run_items(scheduling_run_id,examination_id,programme_course_id,item_status) VALUES(?,?,1,'scheduled')")->execute([$run,$id]);return $id;};
    $run=$makeRun();$paper=$makePaper($run);
    try{$service->delete($cycle+1,$run,1);throw new LogicException('Wrong cycle accepted');}catch(RuntimeException $e){}
    $result=$service->delete($cycle,$run,1);checkDraft($result['deleted_papers']===1,'Paper not deleted');
    checkDraft((int)$pdo->query('SELECT COUNT(*) FROM examinations')->fetchColumn()===0,'Paper remains');
    checkDraft((int)$pdo->query('SELECT COUNT(*) FROM scheduling_run_items')->fetchColumn()===0,'Run items remain');
    checkDraft((int)$pdo->query('SELECT COUNT(*) FROM exam_cycles')->fetchColumn()===1,'Cycle deleted');
    foreach(['approved','published','generating'] as $status){$protected=$makeRun($status);$rejected=false;try{$service->delete($cycle,$protected,1);}catch(RuntimeException $e){$rejected=true;}checkDraft($rejected,'Protected status deleted: '.$status);}
    $run=$makeRun();$paper=$makePaper($run);$other=$makeRun();
    $pdo->prepare("INSERT INTO scheduling_run_items(scheduling_run_id,examination_id,programme_course_id,item_status) VALUES(?,?,1,'locked')")->execute([$other,$paper]);
    $result=$service->delete($cycle,$run,1);checkDraft($result['preserved_shared_papers']===1,'Shared paper deleted');
    checkDraft((int)$pdo->query('SELECT generated_by_run_id FROM examinations WHERE id='.$paper)->fetchColumn()===$other,'Shared ownership lost');
    $result=$service->delete($cycle,$other,1);checkDraft($result['deleted_papers']===1,'Last draft left orphan paper');
    $run=$makeRun();$paper=$makePaper($run);$pdo->exec("UPDATE examinations SET status='published' WHERE id=$paper");
    $rejected=false;try{$service->delete($cycle,$run,1);}catch(RuntimeException $e){$rejected=true;}checkDraft($rejected,'Published paper deleted');
    checkDraft((int)$pdo->query('SELECT COUNT(*) FROM scheduling_runs WHERE id='.$run)->fetchColumn()===1,'Failed deletion was not rolled back');
    $pdo->exec("UPDATE examinations SET status='draft' WHERE id=$paper; INSERT INTO students(roll_no_original,normalized_roll_no,name) VALUES('TEST1','TEST1','Test student'); INSERT INTO seating_allocations(cycle_id,exam_date,shift_id,version_no,seed_value,rule_profile,generated_by,generated_at) VALUES($cycle,'2026-10-26',1,1,'test','{}',1,NOW()); INSERT INTO seating_unallocated(allocation_id,examination_id,student_id) VALUES(1,$paper,1)");
    $rejected=false;try{$service->delete($cycle,$run,1);}catch(RuntimeException $e){$rejected=str_contains($e->getMessage(),'seating');}checkDraft($rejected,'Seating dependency not protected');
    checkDraft((int)$pdo->query('SELECT COUNT(*) FROM examinations WHERE id='.$paper)->fetchColumn()===1,'Dependency failure removed paper');
    checkDraft((int)$pdo->query("SELECT COUNT(*) FROM audit_logs WHERE action='date_sheet.draft_deleted'")->fetchColumn()===3,'Deletion not audited');
    $app=new App\Foundation\Application(BASE_PATH);$app->boot();$database=new App\Foundation\Database(array_merge($config,['database'=>$db]));(new ReflectionProperty($database,'connection'))->setValue($database,$pdo);(new ReflectionProperty($app,'database'))->setValue($app,$database);(new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));$app->session()->put('user',['id'=>1,'name'=>'Tester','role_code'=>'admin','role_name'=>'Admin']);
    $out=BASE_PATH.'/outputs/draft-date-sheet-deletion';if(!is_dir($out))mkdir($out,0770,true);
    $data=(new ReflectionMethod($app,'dateSheetData'))->invoke($app,$cycle);checkDraft(count($data['draftRuns'])===1,'Protected runs appear in draft list');
    file_put_contents($out.'/date-sheet.html',App\View\View::render('exams/date-sheet',$data));
    $data=(new ReflectionMethod($app,'automaticRunData'))->invoke($app,$cycle,$run);file_put_contents($out.'/review.html',App\View\View::render('exams/automatic-review',$data));
    echo "Draft deletion: PASS (delete, cascades, cycle retention, cross-cycle guard, protected states, shared ownership, rollback, audit)\n";
}finally{if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();$server->exec("DROP DATABASE IF EXISTS `$db`");}
