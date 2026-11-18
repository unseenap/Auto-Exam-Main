<?php
declare(strict_types=1);

define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function facultyCheck(bool $condition,string $message):void{if(!$condition)throw new RuntimeException($message);}
$config=require BASE_PATH.'/config/database.php';$db='gbu_faculty_import_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$file=tempnam(sys_get_temp_dir(),'faculty_import_');
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname={$db};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name,short_name) VALUES('ICT','School of ICT','ICT School'); INSERT INTO schools(code,name,status) VALUES('OLD','Closed School','inactive')");
    $service=new App\Import\FacultyImportService($pdo);
    file_put_contents($file,"Name,School,Designation,Email,Phone No.,Status\nFaculty One,ICT,Professor,one@example.test,9876543210,Active\nFaculty Two,school of ict,Assistant Professor,two@example.test,+91 9999999999,inactive\nBad Email,ICT,Professor,invalid,,active\nBad School,OLD,Professor,,,active\nBad Status,ICT,Professor,,,pending\nMissing Designation,ICT,,,,active\n");
    $batch=$service->stage($file,'faculty.csv',1);
    $summary=$pdo->query("SELECT * FROM import_batches WHERE id={$batch}")->fetch();
    facultyCheck((int)$summary['valid_rows']===2&&(int)$summary['invalid_rows']===4,'CSV validation counts differ.');
    $pdo->beginTransaction();facultyCheck($service->commit($batch,1)===2,'Wrong commit count.');$pdo->commit();
    $records=$pdo->query('SELECT * FROM faculty ORDER BY id')->fetchAll();
    facultyCheck($records[0]['email']==='one@example.test'&&$records[0]['phone']==='9876543210','Contacts were not saved.');
    facultyCheck($records[1]['status']==='inactive'&&$records[1]['phone']==='9999999999','Status or phone was lost.');
    facultyCheck($records[0]['employee_id']!==$records[1]['employee_id'],'Generated IDs collide.');
    file_put_contents($file,"Name,School,Designation,Email,Mobile Number,Status\nUpper Case Duplicate,ICT,Professor,ONE@example.test,9876543210,active\nFirst New,ICT,Professor,new@example.test,9876543210,active\nRepeated Email,ICT,Professor,NEW@example.test,9876543211,active\nMissing Mobile,ICT,Professor,missing@example.test,,active\nMissing Email,ICT,Professor,,9876543210,active\n");
    $batch=$service->stage($file,'duplicates.csv',1);$summary=$pdo->query("SELECT valid_rows,invalid_rows FROM import_batches WHERE id={$batch}")->fetch();
    facultyCheck((int)$summary['valid_rows']===2&&(int)$summary['invalid_rows']===3,'Optional mobile or email duplicate detection failed.');
    $pdo->beginTransaction();facultyCheck($service->commit($batch,1)===2,'Shared or missing mobile with a different email should be allowed.');$pdo->commit();
    facultyCheck($pdo->query("SELECT phone FROM faculty WHERE email='missing@example.test'")->fetchColumn()===null,'Missing mobile must be stored as null.');
    file_put_contents($file,"Name,School,Designation,Email,Status\nNo Mobile Column,ICT,Professor,no-mobile@example.test,active\n");
    $optionalBatch=$service->stage($file,'no-mobile.csv',1);
    facultyCheck((int)$pdo->query("SELECT valid_rows FROM import_batches WHERE id={$optionalBatch}")->fetchColumn()===1,'Mobile column should be optional.');
    file_put_contents($file,(new App\Export\XlsxExporter())->buildRegister('Faculty',['Faculty'=>['headers'=>['Name','School','Designation','Email','Phone','Status'],'widths'=>[25,25,25,25,25,25],'rows'=>[['XLSX Faculty','ICT','Professor','xlsx@example.test','9876543212','inactive']]]]));
    $batch=$service->stage($file,'faculty.xlsx',1);$pdo->beginTransaction();facultyCheck($service->commit($batch,1)===1,'XLSX import failed.');$pdo->commit();
    try{$pdo->beginTransaction();$service->commit($batch,1);throw new LogicException('Repeated commit succeeded.');}catch(RuntimeException $e){facultyCheck(str_contains($e->getMessage(),'not available'),'Wrong repeated-commit error.');}finally{if($pdo->inTransaction())$pdo->rollBack();}

    $app=new App\Foundation\Application(BASE_PATH);$app->boot();$database=new App\Foundation\Database(array_merge($config,['database'=>$db]));
    (new ReflectionProperty($database,'connection'))->setValue($database,$pdo);(new ReflectionProperty($app,'database'))->setValue($app,$database);
    (new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));
    $app->session()->put('user',['id'=>1,'username'=>'test','name'=>'Tester','role_code'=>'admin','role_name'=>'Admin']);
    $request=function(string $path,array $data=[])use($app){$_GET=[];$_POST=$data;$_SERVER['SCRIPT_NAME']='/index.php';$_SERVER['REQUEST_URI']=$path;$_SERVER['REQUEST_METHOD']=$data?'POST':'GET';return $app->handle(App\Http\Request::capture());};
    $input=['_token'=>$app->session()->csrfToken(),'name'=>'Manual Faculty','school_id'=>1,'designation'=>'Professor','email'=>'manual@example.test','phone'=>'','status'=>'active'];
    $request('/faculty',$input);$manual=$pdo->query("SELECT * FROM faculty WHERE name='Manual Faculty'")->fetch();facultyCheck((bool)$manual,'Manual create without employee ID or mobile failed.');
    $input['name']='Manual Updated';$input['status']='inactive';$input['employee_id']='SHOULD-NOT-CHANGE';$request('/faculty/'.$manual['id'],$input);
    $updated=$pdo->query('SELECT * FROM faculty WHERE id='.(int)$manual['id'])->fetch();facultyCheck($updated['employee_id']===$manual['employee_id']&&$updated['name']==='Manual Updated'&&$updated['status']==='inactive','Edit did not preserve identity or fields.');
    $input['email']='invalid';$input['status']='pending';$before=(int)$pdo->query('SELECT COUNT(*) FROM faculty')->fetchColumn();$request('/faculty',$input);
    facultyCheck((int)$pdo->query('SELECT COUNT(*) FROM faculty')->fetchColumn()===$before,'Invalid manual input saved.');
    $errors=$app->session()->pullFlash('errors',[]);facultyCheck(isset($errors['email'],$errors['status']),'Missing manual validation errors.');
    $html=(new ReflectionProperty(App\Http\Response::class,'content'))->getValue($request('/faculty/create'));
    facultyCheck(!str_contains($html,'name="employee_id"')&&str_contains($html,'Mobile number (optional)')&&str_contains($html,'Email (required, unique)'),'Manual form still requests old fields.');
    $csv=(new ReflectionProperty(App\Http\Response::class,'content'))->getValue($request('/faculty/import/template.csv'));
    facultyCheck(str_starts_with($csv,'Name,School,Designation,Email,Mobile Number,Status'),'Template route failed.');
    try{$pdo->exec("INSERT INTO faculty(school_id,employee_id,name,email,phone) VALUES(1,'DUP','Duplicate','one@example.test','9999999999')");throw new LogicException('DB email constraint missing.');}catch(PDOException $e){facultyCheck(($e->errorInfo[1]??0)===1062,'Wrong database duplicate error.');}
    $pdo->exec('ALTER TABLE faculty DROP INDEX uq_faculty_email');
    $pdo->exec("UPDATE faculty SET email='  ONE@EXAMPLE.TEST  ' WHERE name='Faculty One'");
    App\Faculty\FacultyEmailMigration::apply($pdo);App\Faculty\FacultyEmailMigration::apply($pdo);
    facultyCheck($pdo->query("SELECT email FROM faculty WHERE name='Faculty One'")->fetchColumn()==='one@example.test','Migration did not normalize email.');
    $pdo->exec('ALTER TABLE faculty DROP INDEX uq_faculty_email');
    $pdo->exec("INSERT INTO faculty(school_id,employee_id,name,email) VALUES(1,'LEGACY-DUP','Legacy Duplicate','ONE@example.test')");
    try{App\Faculty\FacultyEmailMigration::apply($pdo);throw new LogicException('Duplicate migration succeeded.');}catch(RuntimeException $e){facultyCheck(str_contains($e->getMessage(),'share an email'),'Migration must report duplicate emails.');}
    echo "Faculty import: PASS (CSV, XLSX, required email, optional mobile, email uniqueness, shared mobile, validation, status, auto IDs, commit guard, manual create/edit, form, template).\n";
}finally{
    if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();
    if(is_file($file))unlink($file);
    $server->exec("DROP DATABASE IF EXISTS `{$db}`");
}
