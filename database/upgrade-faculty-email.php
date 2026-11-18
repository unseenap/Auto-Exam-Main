<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
$base=dirname(__DIR__);
require $base.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require dirname(__DIR__).'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
App\Foundation\Environment::load($base.'/.env');
$pdo=(new App\Foundation\Database(require $base.'/config/database.php'))->connection();
if(!$pdo->query("SHOW INDEX FROM faculty WHERE Key_name='uq_faculty_email'")->fetch()||$pdo->query("SHOW INDEX FROM faculty WHERE Key_name='uq_faculty_mobile'")->fetch()){
    $dir=$base.'/storage/backups';if(!is_dir($dir))mkdir($dir,0770,true);
    $backup=['schema'=>$pdo->query('SHOW CREATE TABLE faculty')->fetch(PDO::FETCH_NUM)[1],'records'=>$pdo->query('SELECT * FROM faculty')->fetchAll(PDO::FETCH_ASSOC)];
    $json=json_encode($backup,JSON_THROW_ON_ERROR);
    if(file_put_contents($dir.'/faculty-before-email-'.date('Ymd-His').'-'.bin2hex(random_bytes(3)).'.json',$json,LOCK_EX)!==strlen($json))throw new RuntimeException('Faculty backup failed.');
}
App\Faculty\FacultyEmailMigration::apply($pdo);
echo "Faculty email uniqueness installed; mobile numbers are optional and may be shared. Existing records retained.\n";
