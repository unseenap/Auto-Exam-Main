<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
define('BASE_PATH',dirname(__DIR__));
require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
App\Foundation\Environment::load(BASE_PATH.'/.env');
date_default_timezone_set((require BASE_PATH.'/config/app.php')['timezone']);
try{
    $service=new App\Academic\AcademicRollover((new App\Foundation\Database(require BASE_PATH.'/config/database.php'))->connection());
    // Production jobs always use today's date. Simulated dates belong in isolated tests.
    $result=in_array('--preview',$argv,true)?$service->preview(date('Y-m-d'),10):$service->run(date('Y-m-d'),null,'scheduled',in_array('--force',$argv,true));
    if(isset($result['items']))$result['items']=array_map(static fn($i)=>['student_id'=>$i['student']['id'],'target'=>$i['target']],$result['items']);
    echo json_encode($result,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
}catch(Throwable $e){fwrite(STDERR,$e->getMessage().PHP_EOL);exit(1);}
