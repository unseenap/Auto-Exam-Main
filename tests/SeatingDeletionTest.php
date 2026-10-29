<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));
require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function checkDeletion(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
$config=require BASE_PATH.'/config/database.php';
$db='gbu_seating_delete_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try {
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname=$db;charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name,short_name) VALUES('ICT','ICT','ICT'); INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','Computer Science','undergraduate',8); INSERT INTO courses(code,name) VALUES('CS101','Computing'); INSERT INTO students(programme_id,roll_no_original,normalized_roll_no,name,academic_session,current_year_of_study,semester) VALUES(1,'TEST01','TEST01','Test Student','2026-2027',1,1); INSERT INTO rooms(school_id,code,building,rows_count,columns_count,physical_capacity,usable_capacity) VALUES(1,'R1','ICT',1,1,1,1); INSERT INTO faculty(employee_id,name,school_id) VALUES('F1','Test Faculty',1)");
    (new App\Rooms\RoomSeatGenerator($pdo))->regenerate(1,1,1,'row_major',[]);
    $exams=new App\Exams\ExamService($pdo);
    $cycle=$exams->createCycle(['name'=>'Deletion test','academic_year'=>'2026-2027','exam_type'=>'mid_sem','start_date'=>'2026-10-26','end_date'=>'2026-10-26','duration'=>90,'shifts'=>[['name'=>'Morning','start'=>'10:00','end'=>'11:30','duration'=>90]]],1);
    $shift=(int)$pdo->query('SELECT id FROM exam_shifts LIMIT 1')->fetchColumn();
    $pdo->exec("INSERT INTO programme_courses(programme_id,course_id,semester,category) VALUES(1,1,1,'core')");
    $exam=$exams->schedule(['cycle_id'=>$cycle,'shift_id'=>$shift,'course_id'=>1,'programme_id'=>1,'semester'=>1,'exam_date'=>'2026-10-26','category'=>'regular']);
    $insert=$pdo->prepare("INSERT INTO seating_allocations(cycle_id,exam_date,shift_id,version_no,seed_value,rule_profile,status,generated_by,generated_at) VALUES(?,'2026-10-26',?,?,'test','{}',?,1,NOW())");
    foreach([1=>'draft',2=>'published'] as $version=>$status){
        $insert->execute([$cycle,$shift,$version,$status]);$id=(int)$pdo->lastInsertId();
        $pdo->prepare('INSERT INTO seating_assignments(allocation_id,examination_id,room_id,seat_id,student_id) VALUES(?,?,1,1,1)')->execute([$id,$exam]);
        $pdo->prepare('INSERT INTO seating_unallocated(allocation_id,examination_id,student_id) VALUES(?,?,1)')->execute([$id,$exam]);
    }
    $pdo->prepare("INSERT INTO attendance(allocation_id,examination_id,room_id,student_id,status) VALUES(2,?,1,1,'present')")->execute([$exam]);
    $service=new App\Seating\SeatingDeletionService($pdo);
    $reject=static function(int $id,string $message)use($service):void{try{$service->delete($id,1);}catch(RuntimeException $e){checkDeletion(str_contains($e->getMessage(),$message),'Unexpected rejection: '.$e->getMessage());return;}throw new RuntimeException('Protected deletion succeeded.');};
    $reject(2,'recorded attendance');
    checkDeletion((int)$pdo->query('SELECT COUNT(*) FROM seating_assignments WHERE allocation_id=2')->fetchColumn()===1,'Blocked deletion changed seating.');
    $pdo->exec("UPDATE attendance SET status='unmarked',remarks='Retain this note'");$reject(2,'recorded attendance');
    $pdo->exec('UPDATE attendance SET remarks=NULL');
    $pdo->prepare("INSERT INTO invigilation_allocations(cycle_id,exam_date,shift_id,room_id,faculty_id,assigned_by) VALUES(?,'2026-10-26',?,1,1,1)")->execute([$cycle,$shift]);
    $reject(2,'invigilation');
    $service->delete(1,1);
    $pdo->exec("UPDATE invigilation_allocations SET duty_status='cancelled'");
    // Audit failure must roll back the entire deletion, including blank attendance.
    try{$service->delete(2,99999);throw new RuntimeException('Expected audit failure.');}catch(PDOException $e){}
    checkDeletion((int)$pdo->query('SELECT COUNT(*) FROM attendance WHERE allocation_id=2')->fetchColumn()===1,'Failed deletion did not roll back.');
    $service->delete(2,1);
    foreach(['seating_allocations','seating_assignments','seating_unallocated','attendance'] as $table)checkDeletion((int)$pdo->query("SELECT COUNT(*) FROM $table")->fetchColumn()===0,"Remaining records in $table");
    foreach(['examinations','students','rooms','invigilation_allocations'] as $table)checkDeletion((int)$pdo->query("SELECT COUNT(*) FROM $table")->fetchColumn()===1,"Deletion affected $table");
    checkDeletion((int)$pdo->query("SELECT COUNT(*) FROM audit_logs WHERE action='seating.deleted'")->fetchColumn()===2,'Missing audit records.');
    $reject(2,'not found');
    echo "Seating deletion: PASS (draft and published deletion, dependent cleanup, attendance and duty protection, rollback, audit, master preservation)\n";
} finally {
    if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();
    $server->exec("DROP DATABASE IF EXISTS `$db`");
}
