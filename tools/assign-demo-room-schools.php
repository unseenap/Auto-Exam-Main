<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
$base=dirname(__DIR__);require $base.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class)use($base):void{if(str_starts_with($class,'App\\'))require $base.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
App\Foundation\Environment::load($base.'/.env');
$pdo=(new App\Foundation\Database(require $base.'/config/database.php'))->connection();
$rooms=$pdo->query('SELECT id,code,school_id,usable_capacity FROM rooms ORDER BY code')->fetchAll(PDO::FETCH_ASSOC);
if(!in_array('--apply',$argv,true)){echo json_encode($rooms,JSON_PRETTY_PRINT),PHP_EOL;exit;}
$school=(int)$pdo->query("SELECT id FROM schools WHERE code='ICT' AND status='active'")->fetchColumn();
$policy=new App\Rooms\SchoolRoomPolicy($pdo);$policy->assertSchool($school);
$codes=array_map(static fn(int $i):string=>sprintf('DEMO-RM-%02d',$i),range(1,20));
$pdo->beginTransaction();
try{
    $q=$pdo->prepare('SELECT id,code,school_id FROM rooms WHERE code IN ('.implode(',',array_fill(0,20,'?')).') FOR UPDATE');$q->execute($codes);$demo=$q->fetchAll(PDO::FETCH_ASSOC);
    if(count($demo)!==20)throw new RuntimeException('Expected exactly 20 imported DEMO-RM-01 through DEMO-RM-20 rooms. No rooms changed.');
    $json=json_encode($demo,JSON_THROW_ON_ERROR);$path=$base.'/storage/backups/demo-room-schools-'.date('Ymd-His').'-'.bin2hex(random_bytes(3)).'.json';
    if(!is_dir(dirname($path)))mkdir(dirname($path),0770,true);
    if(file_put_contents($path,$json,LOCK_EX)!==strlen($json))throw new RuntimeException('Backup failed.');
    foreach($demo as $room){$policy->assertOwnershipChange((int)$room['id'],$school);$pdo->prepare('UPDATE rooms SET school_id=? WHERE id=?')->execute([$school,$room['id']]);}
    $pdo->prepare("INSERT INTO audit_logs(action,entity_type,new_values) VALUES('room.demo_school_assigned','room',?)")->execute([json_encode(['school'=>'ICT','room_codes'=>$codes])]);
    $pdo->commit();echo "All 20 demo rooms assigned to ICT. Seat maps and capacities preserved.\n";
}catch(Throwable $e){$pdo->rollBack();throw $e;}
