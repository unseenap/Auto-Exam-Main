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
    academicSeedCheck(count($pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN))===41,'Expected all 41 application tables.');
    $calendar=$pdo->query('SELECT enabled,session_start,even_start,last_checked FROM academic_rollover_settings WHERE id=1')->fetch(PDO::FETCH_ASSOC);
    academicSeedCheck((int)$calendar['enabled']===1&&$calendar['session_start']==='07-01'&&$calendar['even_start']==='01-01'&&$calendar['last_checked']===null,'Academic defaults were not initialized.');
    // Seed must initialize the singleton independently of the schema bootstrap.
    $pdo->exec('DELETE FROM academic_rollover_settings WHERE id=1');$pdo->exec($seed);
    academicSeedCheck((int)$pdo->query('SELECT COUNT(*) FROM academic_rollover_settings WHERE id=1')->fetchColumn()===1,'Seed did not create academic settings.');
    $pdo->exec("UPDATE academic_rollover_settings SET enabled=0,session_start='08-15',even_start='02-10',last_checked='2026-10-23' WHERE id=1");
    $before=$pdo->query('SELECT * FROM academic_rollover_settings WHERE id=1')->fetch(PDO::FETCH_ASSOC);
    $pdo->exec($upgrade);$pdo->exec($seed);
    academicSeedCheck($before===$pdo->query('SELECT * FROM academic_rollover_settings WHERE id=1')->fetch(PDO::FETCH_ASSOC),'Seed or upgrade overwrote configured calendar settings.');
    foreach(['students','academic_rollover_runs','student_progression_controls','student_term_enrollments','student_course_registrations','student_academic_history'] as $table){
        academicSeedCheck((int)$pdo->query('SELECT COUNT(*) FROM `'.$table.'`')->fetchColumn()===0,'Seed fabricated operational records in '.$table.'.');
    }
    foreach(['academic_rollover_settings','academic_rollover_runs','student_progression_controls','student_term_enrollments','student_course_registrations','student_academic_history'] as $table){
        $pattern='/CREATE TABLE IF NOT EXISTS '.preg_quote($table,'/').'\s*\(.*?\) ENGINE=InnoDB;/s';
        preg_match($pattern,$schema,$canonical);preg_match($pattern,$upgrade,$incremental);
        academicSeedCheck(isset($canonical[0],$incremental[0])&&preg_replace('/\s+/',' ',$canonical[0])===preg_replace('/\s+/',' ',$incremental[0]),'Schema and upgrade differ for '.$table.'.');
    }
    echo "Academic seed: PASS (41 tables, default initialization, repeatable imports, preserved custom calendar, empty operational tables, upgrade parity).\n";
}finally{$pdo->exec("DROP DATABASE IF EXISTS `{$testDb}`");}
