<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function accountCheck(bool $value,string $message):void{if(!$value)throw new RuntimeException($message);}
function accountReject(callable $call,string $text):void{try{$call();}catch(RuntimeException $e){accountCheck(str_contains($e->getMessage(),$text),'Wrong rejection reason.');return;}throw new LogicException('Unexpected success: '.$text);}
$c=require BASE_PATH.'/config/database.php';$db='gbu_faculty_accounts_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$c['host']};port={$c['port']};charset=utf8mb4",$c['username'],$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);$file=tempnam(sys_get_temp_dir(),'account_');
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$c['host']};port={$c['port']};dbname={$db};charset=utf8mb4",$c['username'],$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
    App\Faculty\FacultyPortalMigration::apply($pdo);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'),('faculty','Faculty'),('viewer','Viewer'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'admin','Administrator','unused'),(3,'viewer','Viewer','unused'); INSERT INTO schools(code,name) VALUES('ICT','School of ICT'); INSERT INTO faculty(school_id,employee_id,name,email) VALUES(1,'F1','Faculty One','one+faculty@example.test'),(1,'F2','Faculty Two','two@example.test'),(1,'F3','Faculty Three','three@example.test'),(1,'F4','Faculty Four','four@example.test')");
    $pdo->exec('ALTER TABLE users MODIFY username VARCHAR(80) NOT NULL');App\Auth\EmailUsernameMigration::apply($pdo);App\Auth\EmailUsernameMigration::apply($pdo);
    accountCheck($pdo->query("SHOW COLUMNS FROM users LIKE 'username'")->fetch()['Type']==='varchar(190)','Email username migration failed.');
    accountCheck(App\Auth\Username::valid('one+faculty@example.test')&&App\Auth\Username::valid('legacy.user')&&!App\Auth\Username::valid('bad user'),'Username validation failed.');
    $service=new App\Import\FacultyAccountImportService($pdo);$secret='SyntheticRandomPass123!';
    $csv="Name,Email,Username,Password,Role,Status\nFaculty One,ONE+FACULTY@example.test,one+faculty@example.test,{$secret},faculty,active\nDuplicate,one+faculty@example.test,one+faculty@example.test,{$secret},faculty,active\nMissing,nobody@example.test,nobody@example.test,{$secret},faculty,active\nEscalation,two@example.test,two@example.test,{$secret},admin,active\nMismatch,three@example.test,other@example.test,{$secret},faculty,active\n";
    file_put_contents($file,$csv);accountReject(fn()=>$service->stage($file,'accounts.csv',2),'administrator');
    $rows=$service->stage($file,'accounts.csv',1);
    accountCheck(count($rows)===5&&count(array_filter($rows,static fn($r)=>!$r['messages']))===1,'Stage validation differs.');
    accountCheck(!str_contains(json_encode($rows),$secret)&&password_verify($secret,$rows[0]['password_hash']),'Stage retained plaintext or hash failed.');
    $app=new App\Foundation\Application(BASE_PATH);$app->boot();$database=new App\Foundation\Database(array_merge($c,['database'=>$db]));(new ReflectionProperty($database,'connection'))->setValue($database,$pdo);(new ReflectionProperty($app,'database'))->setValue($app,$database);(new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));
    $admin=['id'=>1,'username'=>'admin','name'=>'Administrator','role_code'=>'admin','role_name'=>'Admin'];$app->session()->put('user',$admin);
    $call=function(string $path,array $post=[])use($app){$_GET=[];$_POST=$post;$_SERVER['SCRIPT_NAME']='/index.php';$_SERVER['REQUEST_URI']=$path;$_SERVER['REQUEST_METHOD']=$post?'POST':'GET';return $app->handle(App\Http\Request::capture());};
    $app->session()->put('faculty_account_import',['actor'=>1,'token'=>'review-token','created'=>time(),'rows'=>$rows]);
    $response=$call('/users/faculty-import');$html=(new ReflectionProperty($response,'content'))->getValue($response);
    accountCheck((new ReflectionProperty($response,'status'))->getValue($response)===200&&str_contains($html,'Bulk faculty login accounts')&&!str_contains($html,$secret)&&!str_contains($html,$rows[0]['password_hash']),'Review leaks credentials or fails.');
    $blocked=$call('/users/faculty-import/commit',['_token'=>'invalid','import_token'=>'review-token']);accountCheck((new ReflectionProperty($blocked,'status'))->getValue($blocked)===403,'CSRF protection failed.');
    accountCheck((int)$pdo->query('SELECT COUNT(*) FROM users')->fetchColumn()===2,'CSRF created accounts.');
    $call('/users/faculty-import/commit',['_token'=>$app->session()->csrfToken(),'import_token'=>'review-token']);
    accountCheck((int)$pdo->query('SELECT COUNT(*) FROM users')->fetchColumn()===3&&$app->session()->get('faculty_account_import')===null,'Reviewed import did not create exactly one account or clear pending data.');
    $user=$pdo->query("SELECT * FROM users WHERE username='one+faculty@example.test'")->fetch();accountCheck($user['email']===$user['username']&&password_verify($secret,$user['password_hash']),'Email login or hash differs.');
    accountCheck((new App\Faculty\FacultyPortalService($pdo))->faculty((int)$user['id'])['employee_id']==='F1','Faculty account was not linked.');
    accountCheck($app->auth()->attempt('ONE+FACULTY@example.test',$secret),'Email/password login failed.');
    $app->session()->put('user',$admin);
    $repeat=$service->stage($file,'repeat.csv',1);accountCheck((bool)$repeat[0]['messages'],'Existing account was accepted.');
    accountReject(fn()=>$service->commit($rows,1),'data changed');accountCheck(password_verify($secret,$pdo->query("SELECT password_hash FROM users WHERE id=".(int)$user['id'])->fetchColumn()),'Repeat import changed existing password.');
    $bytes=(new App\Export\XlsxExporter())->buildRegister('Accounts',['Accounts'=>['headers'=>['Email','Password'],'widths'=>[44,30],'rows'=>[['two@example.test',$secret],['three@example.test',$secret]]]]);file_put_contents($file,$bytes);
    $pending=$service->stage($file,'accounts.xlsx',1);accountCheck(count($pending)===2&&!$pending[0]['messages']&&!$pending[1]['messages'],'XLSX staging failed.');
    $pdo->exec("UPDATE faculty SET status='inactive' WHERE email='three@example.test'");
    accountReject(fn()=>$service->commit($pending,1),'data changed');accountCheck((int)$pdo->query("SELECT COUNT(*) FROM users WHERE email='two@example.test'")->fetchColumn()===0,'Partial account creation was not rolled back.');
    $pdo->exec("UPDATE faculty SET status='active' WHERE email='three@example.test'");accountCheck($service->commit($pending,1)===2,'Valid XLSX commit failed.');
    $audit=$pdo->query('SELECT new_values FROM audit_logs')->fetchAll();accountCheck(!str_contains(json_encode($audit),$secret)&&!str_contains(json_encode($audit),'password_hash'),'Audit retained password material.');
    $generated=$service->credentialRows(1);accountCheck(count($generated)===1&&strlen($generated[0][3])===20&&$generated[0][1]===$generated[0][2],'Credential generator includes linked accounts or has invalid columns.');
    $response=$call('/users/faculty-import/generate',['_token'=>$app->session()->csrfToken()]);accountCheck((new ReflectionProperty($response,'headers'))->getValue($response)['Cache-Control']==='no-store, private','Credential download must not be cached.');
    $app->session()->put('user',['id'=>2,'username'=>'viewer','name'=>'Viewer','role_code'=>'viewer','role_name'=>'Viewer']);
    accountCheck((new ReflectionProperty($call('/users/faculty-import'),'status'))->getValue($call('/users/faculty-import'))===403,'Viewer accessed account import.');
    echo "Faculty accounts: PASS (CSV/XLSX, email usernames, password hashes, duplicate/role checks, admin-only routes, CSRF, redacted preview, faculty linking/login, atomic rollback, generation, no password audit/cache).\n";
}finally{if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();if(is_file($file))unlink($file);$server->exec("DROP DATABASE IF EXISTS `{$db}`");}
