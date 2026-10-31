<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function bulkCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
function bulkReject(callable $call):void{try{$call();}catch(RuntimeException $e){return;}throw new LogicException('Unsafe deletion scope accepted');}
$config=require BASE_PATH.'/config/database.php';$db='gbu_student_bulk_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname=$db;charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name) VALUES('ICT','ICT'),('ENG','Engineering'); INSERT INTO departments(school_id,code,name) VALUES(1,'CS','Computing'),(2,'CE','Civil'); INSERT INTO programmes(school_id,department_id,code,name,level,duration_semesters) VALUES(1,1,'UCS','Computer Science','undergraduate',8),(1,NULL,'UAI','Artificial Intelligence','undergraduate',8),(2,2,'CIV','Civil Engineering','undergraduate',8); INSERT INTO courses(code,name) VALUES('CS101','Computing')");
    $add=static function(?int $programme,string $roll,string $department='Computing',string $branch='CS')use($pdo):int{$q=$pdo->prepare("INSERT INTO students(programme_id,roll_no_original,normalized_roll_no,name,department_name,branch,school_name,academic_session) VALUES(?,?,?,?,?,?,?,'2026-2027')");$q->execute([$programme,$roll,$roll,'Student '.$roll,$department,$branch,'Test School']);return (int)$pdo->lastInsertId();};
    $add(1,'S001');$add(1,'S002');$add(2,'S003');$add(3,'S004','Civil','Civil');$add(null,'S005','Legacy Dept','Legacy Branch');
    $pdo->exec('INSERT INTO student_progression_controls(student_id) VALUES(2)');
    $cycle=(new App\Exams\ExamService($pdo))->createCycle(['name'=>'Bulk deletion test','academic_year'=>'2026-2027','exam_type'=>'mid_sem','start_date'=>'2026-10-26','end_date'=>'2026-10-26','duration'=>90,'shifts'=>[['name'=>'Morning','start'=>'10:00','end'=>'11:30','duration'=>90]]],1);$shift=(int)$pdo->query('SELECT id FROM exam_shifts LIMIT 1')->fetchColumn();
    $pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date) VALUES(?,?,1,'2026-10-26')")->execute([$cycle,$shift]);$exam=(int)$pdo->lastInsertId();$pdo->prepare('INSERT INTO exam_eligibility(examination_id,student_id) VALUES(?,1)')->execute([$exam]);
    $service=new App\Academic\StudentBulkDeletion($pdo);
    $school=$service->preview('school','1');bulkCheck($school['matched']===3&&$school['protected']===1&&$school['deletable']===2,'School preview counts incorrect');
    bulkCheck($service->preview('department','id:1')['matched']===2,'Master department mapping ignored');
    bulkCheck($service->preview('department','name:Computing')['matched']===3,'Student-record department filter ignored');
    bulkCheck($service->preview('branch','name:Legacy Branch')['matched']===1,'Unmapped branch records cannot be selected');
    bulkCheck($service->preview('branch','id:2')['matched']===1,'Branch filter incorrect');
    foreach([['school','999'],['department','id:999'],['branch',''],['all','1'],['anything','']] as [$scope,$target])bulkReject(fn()=>$service->preview($scope,$target));
    $add(1,'S006');$pdo->exec('UPDATE students SET programme_id=3 WHERE id=3');
    $result=$service->delete('school','1',$school['ids'],1);bulkCheck($result===['deleted'=>1,'protected'=>1,'changed'=>1],'Preview scope broadened or protected/changed records removed');
    bulkCheck((int)$pdo->query('SELECT COUNT(*) FROM students WHERE id IN (1,3,6)')->fetchColumn()===3,'Protected, moved, or newly created student removed');
    bulkCheck((int)$pdo->query('SELECT COUNT(*) FROM student_progression_controls WHERE student_id=2')->fetchColumn()===0,'Related student history did not follow normal cascade rules');
    $branch=$service->preview('branch','id:3');
    try{$service->delete('branch','id:3',$branch['ids'],99999);throw new LogicException('Audit failure was accepted');}catch(PDOException $error){}
    bulkCheck((int)$pdo->query('SELECT COUNT(*) FROM students WHERE id IN (3,4)')->fetchColumn()===2,'Audit failure did not roll deletion back');
    $all=$service->preview('all','');$pdo->prepare('INSERT INTO exam_eligibility(examination_id,student_id) VALUES(?,4)')->execute([$exam]);
    $result=$service->delete('all','',$all['ids'],1);bulkCheck($result['deleted']===3&&$result['protected']===2,'Newly protected student was not retained');
    bulkCheck((int)$pdo->query('SELECT COUNT(*) FROM students')->fetchColumn()===2,'All-students scope produced the wrong remaining count');

    // Exercise the actual preview and confirmation handler, not only the service.
    $app=new App\Foundation\Application(BASE_PATH);$app->boot();$database=new App\Foundation\Database(array_merge($config,['database'=>$db]));(new ReflectionProperty($database,'connection'))->setValue($database,$pdo);(new ReflectionProperty($app,'database'))->setValue($app,$database);(new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));$app->session()->put('user',['id'=>1,'name'=>'Tester','role_code'=>'admin','role_name'=>'Admin']);
    $handler=new ReflectionMethod($app,'studentBulkDelete');$invoke=static function(string $path,array $post=[])use($handler,$app){$_GET=[];$_POST=$post;$_SERVER['REQUEST_METHOD']=$post?'POST':'GET';$_SERVER['REQUEST_URI']=$path;$_SERVER['SCRIPT_NAME']='/index.php';return $handler->invoke($app,App\Http\Request::capture());};
    $out=BASE_PATH.'/outputs/student-bulk-delete';if(!is_dir($out))mkdir($out,0770,true);
    $response=$invoke('/students/bulk-delete');file_put_contents($out.'/form.html',(new ReflectionProperty($response,'content'))->getValue($response));
    $student=$add(2,'S007');$token=$app->session()->csrfToken();$response=$invoke('/students/bulk-delete/preview',['_token'=>$token,'scope'=>'all','target'=>'']);file_put_contents($out.'/review.html',(new ReflectionProperty($response,'content'))->getValue($response));
    $saved=$app->session()->get('student_bulk_delete_preview');$previewToken=$saved['review']['token'];
    foreach([['_token'=>'bad','preview_token'=>$previewToken,'confirmation'=>'DELETE 1'],['_token'=>$token,'preview_token'=>'bad','confirmation'=>'DELETE 1'],['_token'=>$token,'preview_token'=>$previewToken,'confirmation'=>'DELETE 999']] as $post){$invoke('/students/bulk-delete/commit',$post);bulkCheck((int)$pdo->query('SELECT COUNT(*) FROM students')->fetchColumn()===3,'Invalid confirmation/CSRF/token deleted students');}
    $expired=$saved;$expired['expires']=time()-1;$app->session()->put('student_bulk_delete_preview',$expired);$invoke('/students/bulk-delete/commit',['_token'=>$token,'preview_token'=>$previewToken,'confirmation'=>'DELETE 1']);bulkCheck((int)$pdo->query('SELECT COUNT(*) FROM students')->fetchColumn()===3,'Expired preview deleted students');$app->session()->put('student_bulk_delete_preview',$saved);
    $new=$add(2,'S008');$invoke('/students/bulk-delete/commit',['_token'=>$token,'preview_token'=>$previewToken,'confirmation'=>'DELETE 1']);
    bulkCheck((int)$pdo->query('SELECT COUNT(*) FROM students WHERE id='.$student)->fetchColumn()===0,'Confirmed student not deleted');bulkCheck((int)$pdo->query('SELECT COUNT(*) FROM students WHERE id='.$new)->fetchColumn()===1,'Confirmation included a student created after preview');
    $invoke('/students/bulk-delete/commit',['_token'=>$token,'preview_token'=>$previewToken,'confirmation'=>'DELETE 1']);bulkCheck((int)$pdo->query('SELECT COUNT(*) FROM students')->fetchColumn()===3,'Replayed confirmation deleted students');
    bulkCheck((new ReflectionMethod($app,'requiredPermission'))->invoke($app,'/students/bulk-delete/commit')==='students.manage','Bulk deletion bypassed the student-management permission');
    $pdo->exec("UPDATE students SET parsing_status='verified'");
    $reviewA=$add(null,'REVIEW01');$reviewB=$add(2,'REVIEW02');$reviewMoved=$add(2,'REVIEW03');
    $pdo->exec("UPDATE students SET parsing_status='review' WHERE id=1");
    $reviewScope=$service->preview('review','');bulkCheck($reviewScope['matched']===4&&$reviewScope['protected']===1,'Review scope missed unmapped/protected students or included verified students');
    bulkReject(fn()=>$service->preview('review','1'));
    $pdo->exec("UPDATE students SET parsing_status='verified' WHERE id=$reviewMoved");
    $reviewNew=$add(null,'REVIEW04');$result=$service->delete('review','',$reviewScope['ids'],1);
    bulkCheck($result===['deleted'=>2,'protected'=>1,'changed'=>1],'Review deletion included verified, newly added or protected students');
    bulkCheck((int)$pdo->query("SELECT COUNT(*) FROM students WHERE id IN ($reviewA,$reviewB)")->fetchColumn()===0,'Review students not deleted');
    bulkCheck((int)$pdo->query("SELECT COUNT(*) FROM students WHERE id IN (1,$reviewMoved,$reviewNew)")->fetchColumn()===3,'Protected/changed/new records not retained');
    echo "Student bulk deletion: PASS (school/department/branch/all/review, unmapped review students, protected records, exact preview snapshot, changed records, cascades, audit rollback, CSRF, expiry, confirmation, replay protection)\n";
}finally{if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();$server->exec("DROP DATABASE IF EXISTS `$db`");}
