<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
App\Foundation\Environment::load(BASE_PATH.'/.env');date_default_timezone_set('Asia/Kolkata');
try{
    $pdo=(new App\Foundation\Database(require BASE_PATH.'/config/database.php'))->connection();
    $before=(int)$pdo->query("SELECT COUNT(*) FROM exam_eligibility WHERE eligibility_status='pending'")->fetchColumn();
    if(!in_array('--apply',$argv,true)){echo json_encode(['pending_registrations'=>$before,'action'=>'Use --apply to back up and reconcile department-assigned electives.']),PHP_EOL;exit;}
    $backup=['created_at'=>date(DATE_ATOM),'exam_eligibility'=>$pdo->query('SELECT * FROM exam_eligibility')->fetchAll(PDO::FETCH_ASSOC),'student_course_registrations'=>$pdo->query('SELECT * FROM student_course_registrations')->fetchAll(PDO::FETCH_ASSOC)];
    $file=BASE_PATH.'/storage/backups/department-electives-'.date('Ymd-His').'-'.bin2hex(random_bytes(3)).'.json';
    $json=json_encode($backup,JSON_THROW_ON_ERROR);
    if(file_put_contents($file,$json,LOCK_EX)!==strlen($json))throw new RuntimeException('Backup failed; reconciliation cancelled.');
    $result=(new App\Academic\DepartmentElectiveRegistrations($pdo))->synchronize();
    $after=(int)$pdo->query("SELECT COUNT(*) FROM exam_eligibility WHERE eligibility_status='pending'")->fetchColumn();
    echo json_encode(['pending_before'=>$before,'pending_after'=>$after,'result'=>$result,'backup_saved'=>true],JSON_PRETTY_PRINT),PHP_EOL;
}catch(Throwable $e){fwrite(STDERR,$e->getMessage().PHP_EOL);exit(1);}
