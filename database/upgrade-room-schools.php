<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
$base=dirname(__DIR__);require $base.'/app/Support/helpers.php';require $base.'/app/Foundation/Environment.php';require $base.'/app/Foundation/Database.php';require $base.'/app/Rooms/RoomSchoolMigration.php';
App\Foundation\Environment::load($base.'/.env');
$pdo=(new App\Foundation\Database(require $base.'/config/database.php'))->connection();
$snapshot=['rooms'=>$pdo->query('SELECT * FROM rooms')->fetchAll(PDO::FETCH_ASSOC),'schema'=>$pdo->query('SHOW CREATE TABLE rooms')->fetch(PDO::FETCH_NUM)[1]];
$path=$base.'/storage/backups/rooms-before-schools-'.date('Ymd-His').'-'.bin2hex(random_bytes(3)).'.json';
if(!is_dir(dirname($path)))mkdir(dirname($path),0770,true);
$json=json_encode($snapshot,JSON_THROW_ON_ERROR);
if(file_put_contents($path,$json,LOCK_EX)!==strlen($json))throw new RuntimeException('Room backup failed.');
App\Rooms\RoomSchoolMigration::apply($pdo);
echo "Room school schema installed. Existing rooms require an explicit school; their names are not used to guess ownership. Backup saved in storage/backups.\n";
