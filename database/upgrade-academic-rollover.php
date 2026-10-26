<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
$base=dirname(__DIR__);require $base.'/app/Support/helpers.php';require $base.'/app/Foundation/Environment.php';require $base.'/app/Foundation/Database.php';
App\Foundation\Environment::load($base.'/.env');
$pdo=(new App\Foundation\Database(require $base.'/config/database.php'))->connection();
$backup=$base.'/storage/backups/academic-before-upgrade-'.date('Ymd-His').'-'.bin2hex(random_bytes(3)).'.json';
$pdo->beginTransaction();
try{
    $tables=[];
    foreach($pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN) as $table){
        if(!preg_match('/^[a-z_]+$/',$table))throw new RuntimeException('Unexpected table name.');
        $tables[$table]=['schema'=>$pdo->query('SHOW CREATE TABLE `'.$table.'`')->fetch(PDO::FETCH_NUM)[1],'rows'=>$pdo->query('SELECT * FROM `'.$table.'`')->fetchAll(PDO::FETCH_ASSOC)];
    }
    $json=json_encode(['database'=>$pdo->query('SELECT DATABASE()')->fetchColumn(),'tables'=>$tables],JSON_THROW_ON_ERROR);
    if(!is_dir(dirname($backup)))mkdir(dirname($backup),0770,true);
    if(file_put_contents($backup,$json,LOCK_EX)!==strlen($json))throw new RuntimeException('Backup could not be saved. Upgrade cancelled.');
    $pdo->commit();
}catch(Throwable $e){$pdo->rollBack();throw $e;}
$pdo->exec(file_get_contents(__DIR__.'/academic-rollover.sql'));
echo 'Academic rollover schema installed; pre-upgrade snapshot saved in storage/backups.',PHP_EOL;
