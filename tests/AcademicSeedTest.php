<?php
declare(strict_types=1);

define('BASE_PATH',dirname(__DIR__));
require BASE_PATH.'/app/Support/helpers.php';
require BASE_PATH.'/app/Foundation/Environment.php';
App\Foundation\Environment::load(BASE_PATH.'/.env');
$config=require BASE_PATH.'/config/database.php';
$testDb='gbu_academic_seed_'.bin2hex(random_bytes(4));
if(!preg_match('/^gbu_academic_seed_[a-f0-9]{8}$/',$testDb))throw new RuntimeException('Unsafe test database name.');
$pdo=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_EMULATE_PREPARES=>true]);
function academicSeedCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}

try{
    $schema=file_get_contents(BASE_PATH.'/database/schema.sql');
    $upgrade=file_get_contents(BASE_PATH.'/database/academic-rollover.sql');
    $pdo->exec(str_replace('gbu_exam_operations',$testDb,$schema));
    $seed=str_replace('gbu_exam_operations',$testDb,file_get_contents(BASE_PATH.'/database/seed.sql'));
    $pdo->exec($seed);$pdo->exec($seed);
    academicSeedCheck(count($pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN))===47,'Expected all 47 application tables.');
    $calendar=$pdo->query('SELECT enabled,session_start,even_start,last_checked FROM academic_rollover_settings WHERE id=1')->fetch(PDO::FETCH_ASSOC);
    academicSeedCheck((int)$calendar['enabled']===1&&$calendar['session_start']==='07-01'&&$calendar['even_start']==='01-01'&&$calendar['last_checked']===null,'Academic defaults were not initialized.');
    // Seed must initialize the singleton independently of the schema bootstrap.
    $pdo->exec('DELETE FROM academic_rollover_settings WHERE id=1');$pdo->exec($seed);
    academicSeedCheck((int)$pdo->query('SELECT COUNT(*) FROM academic_rollover_settings WHERE id=1')->fetchColumn()===1,'Seed did not create academic settings.');
    $pdo->exec("UPDATE academic_rollover_settings SET enabled=0,session_start='08-15',even_start='02-10',last_checked='2026-10-23' WHERE id=1");
    $before=$pdo->query('SELECT * FROM academic_rollover_settings WHERE id=1')->fetch(PDO::FETCH_ASSOC);
    $pdo->exec($upgrade);$pdo->exec($seed);
    academicSeedCheck($before===$pdo->query('SELECT * FROM academic_rollover_settings WHERE id=1')->fetch(PDO::FETCH_ASSOC),'Seed or upgrade overwrote configured calendar settings.');
    $facultyUpgrade=file_get_contents(BASE_PATH.'/database/faculty-portal.sql');
    $pdo->exec('DELETE FROM faculty_portal_settings WHERE id=1');$pdo->exec($seed);
    academicSeedCheck((int)$pdo->query('SELECT COUNT(*) FROM faculty_portal_settings WHERE id=1')->fetchColumn()===1,'Seed did not initialize faculty portal settings.');
    $pdo->exec('UPDATE faculty_portal_settings SET reporting_minutes=45,attendance_before_minutes=15,attendance_after_minutes=90 WHERE id=1');
    $facultyBefore=$pdo->query('SELECT * FROM faculty_portal_settings WHERE id=1')->fetch(PDO::FETCH_ASSOC);
    $pdo->exec($facultyUpgrade);$pdo->exec($seed);
    academicSeedCheck($facultyBefore===$pdo->query('SELECT * FROM faculty_portal_settings WHERE id=1')->fetch(PDO::FETCH_ASSOC),'Seed or upgrade reset faculty attendance windows.');
    academicSeedCheck((int)$pdo->query('SELECT COUNT(*) FROM programmes WHERE lateral_entry=1')->fetchColumn()===0,'Clean seed created separate lateral programmes.');
    academicSeedCheck((int)$pdo->query('SELECT COUNT(*) FROM batches b JOIN programmes p ON p.id=b.programme_id WHERE p.lateral_entry=1')->fetchColumn()===0,'Clean seed created separate lateral batches.');
    require_once BASE_PATH.'/app/Academic/RollNumberParser.php';
    require_once BASE_PATH.'/app/Academic/StudentAdmissionBatch.php';
    $programmes=[];foreach($pdo->query('SELECT * FROM programmes') as $programme)$programmes[$programme['code']]=$programme;
    foreach(['LCS'=>'UCS','LAI'=>'UAI','LCC'=>'UCC','LIT'=>'UIT','LEA'=>'UEA'] as $lateral=>$regular){
        $parsed=(new App\Academic\RollNumberParser())->parse('245'.$lateral.'001',$programmes);
        academicSeedCheck($parsed['programme_id']===$programmes[$regular]['id']&&$parsed['admission_type']==='lateral','Lateral seed mapping failed for '.$lateral.'.');
        $batch=(new App\Academic\StudentAdmissionBatch($pdo))->resolve((int)$parsed['programme_id'],$parsed['registration_prefix'],$parsed['admission_type']);
        $expected=$pdo->query("SELECT id FROM batches WHERE programme_id=".(int)$programmes[$regular]['id']." AND start_year=2023 AND end_year=2027")->fetchColumn();
        academicSeedCheck($batch===(int)$expected,'Lateral import did not reuse the regular 2023 class.');
    }
    // Re-importing the baseline must not reactivate a closed cohort or create a
    // new class for legacy lateral programmes retained by an older installation.
    $pdo->exec("UPDATE batches SET status='completed' WHERE programme_id=".(int)$programmes['UCS']['id']);
    $pdo->exec("INSERT INTO programmes(school_id,code,name,level,duration_semesters,lateral_entry) SELECT school_id,'LCS','Legacy lateral','undergraduate',6,1 FROM programmes WHERE code='UCS'");
    $legacy=(int)$pdo->lastInsertId();$pdo->exec($seed);
    academicSeedCheck($pdo->query("SELECT status FROM batches WHERE programme_id=".(int)$programmes['UCS']['id'])->fetchColumn()==='completed','Seed reactivated a completed batch.');
    academicSeedCheck((int)$pdo->query('SELECT COUNT(*) FROM programmes WHERE id='.$legacy)->fetchColumn()===1,'Seed deleted a legacy programme.');
    academicSeedCheck((int)$pdo->query('SELECT COUNT(*) FROM batches WHERE programme_id='.$legacy)->fetchColumn()===0,'Seed created a new legacy lateral cohort.');
    foreach(['students','academic_rollover_runs','student_progression_controls','student_term_enrollments','student_course_registrations','student_academic_history','faculty_user_links','faculty_duty_acknowledgments','faculty_room_sessions','faculty_correction_requests','faculty_availability_requests'] as $table){
        academicSeedCheck((int)$pdo->query('SELECT COUNT(*) FROM `'.$table.'`')->fetchColumn()===0,'Seed fabricated operational records in '.$table.'.');
    }
    foreach(['academic_rollover_settings','academic_rollover_runs','student_progression_controls','student_term_enrollments','student_course_registrations','student_academic_history'] as $table){
        $pattern='/CREATE TABLE IF NOT EXISTS '.preg_quote($table,'/').'\s*\(.*?\) ENGINE=InnoDB;/s';
        preg_match($pattern,$schema,$canonical);preg_match($pattern,$upgrade,$incremental);
        academicSeedCheck(isset($canonical[0],$incremental[0])&&preg_replace('/\s+/',' ',$canonical[0])===preg_replace('/\s+/',' ',$incremental[0]),'Schema and upgrade differ for '.$table.'.');
    }
    foreach(['faculty_user_links','faculty_duty_acknowledgments','faculty_room_sessions','faculty_correction_requests','faculty_availability_requests','faculty_portal_settings'] as $table){
        $pattern='/CREATE TABLE IF NOT EXISTS '.preg_quote($table,'/').'\s*\(.*?\) ENGINE=InnoDB;/s';
        preg_match($pattern,$schema,$canonical);preg_match($pattern,$facultyUpgrade,$incremental);
        academicSeedCheck(isset($canonical[0],$incremental[0])&&preg_replace('/\s+/',' ',$canonical[0])===preg_replace('/\s+/',' ',$incremental[0]),'Schema and faculty upgrade differ for '.$table.'.');
    }
    echo "Academic seed: PASS (47 tables, repeatable defaults, preserved calendar/faculty settings and batch status, seeded lateral class mapping, retained legacy records, empty operational tables, upgrade parity).\n";
}finally{$pdo->exec("DROP DATABASE IF EXISTS `{$testDb}`");}
