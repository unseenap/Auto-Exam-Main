<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function checkHeader(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
$config=require BASE_PATH.'/config/database.php';$db='gbu_import_headers_'.bin2hex(random_bytes(4));$file=tempnam(sys_get_temp_dir(),'student_headers_');
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname=$db;charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name) VALUES('ICT','ICT'); INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','Computer Science','undergraduate',8)");
    $service=new App\Import\StudentImportService($pdo);
    $key=new ReflectionMethod($service,'headerKey');
    foreach(['Enrollment/Roll Number','Enrollment/Roll Number:','Roll Number.','Roll No.','Roll No Original',"\xEF\xBB\xBFEnrollment/Roll Number"] as $header)checkHeader($key->invoke($service,$header)==='roll_no','Alias not recognized: '.$header);
    foreach(['Rollnumber','RollNo','Roll No.'] as $header)checkHeader($key->invoke($service,$header)==='roll_no','Roll alias not recognized');
    foreach(['Enrollment Number','Enrolment Number','Enrollment No.','Enrollmentnumber','Enrillment Number'] as $header)checkHeader($key->invoke($service,$header)==='enrollment_number','Enrollment alias not recognized');
    foreach([false,true] as $bom){
        $handle=fopen($file,'wb');if($bom)fwrite($handle,"\xEF\xBB\xBF");
        fputcsv($handle,['Enrollment/Roll Number','Enrollment Number','Academic Session','Full Name','Branch','Mobile Number','Address','Department','School','Current Year of Study','Current Semester','Section']);
        fputcsv($handle,['235UCS001','2300100266','2023-2024','Demo Student','Computer Science','9876543210','Test address','Computing','ICT','1','1','A']);fclose($handle);
        $id=$service->stage($file,'students.csv',1);$row=$pdo->query('SELECT valid_rows,invalid_rows FROM import_batches WHERE id='.$id)->fetch(PDO::FETCH_ASSOC);
        checkHeader((int)$row['valid_rows']===1&&(int)$row['invalid_rows']===0,'Template header validation failed with BOM='.($bom?'yes':'no'));
    }
    checkHeader((int)$pdo->query('SELECT COUNT(*) FROM students')->fetchColumn()===0,'Validation committed students');
    file_put_contents($file,"Full Name,Semester\nDemo,1\n");$rejected=false;
    try{$service->stage($file,'missing.csv',1);}catch(RuntimeException $e){$rejected=str_contains($e->getMessage(),'roll_no');}checkHeader($rejected,'Truly missing roll column was accepted');
    $handle=fopen($file,'wb');
    fputcsv($handle,['Roll No','Academic Session','Name','Branch','Mobile Number','Address','Department','School','Year of Study','Semester','Section']);
    $cases=[['1','1','',true],['Passout','Passout','',true],['pass out','','',true],['','PASS-OUT','',true],['4','Passed Out','',true],['0','1','',false],['1','13','',false],['Passout','invalid','',false],['1','1','invalid',false]];
    foreach($cases as $i=>[$year,$semester,$mobile,$valid])fputcsv($handle,['235UCS'.sprintf('%03d',$i+10),'2023-2024','Synthetic Student','Computing',$mobile,'','Computing','ICT',$year,$semester,'A']);
    fclose($handle);$batch=$service->stage($file,'passout.csv',1);
    $rows=$pdo->query('SELECT * FROM import_rows WHERE import_batch_id='.$batch.' ORDER BY source_row_number')->fetchAll(PDO::FETCH_ASSOC);
    foreach($rows as $i=>$row){
        checkHeader(($row['validation_status']!=='invalid')===$cases[$i][3],'Wrong validation result for case '.$i.': '.$row['validation_messages']);
        if($i>0&&$i<5){$data=json_decode($row['normalized_data'],true);checkHeader($data['status']==='completed'&&$data['special_status']==='pass_out','Passout not normalized');checkHeader($data['semester']===8&&$data['current_year_of_study']===4,'Programme final year/semester not retained');}
    }
    $pdo->beginTransaction();$result=$service->commit($batch,1);$pdo->commit();checkHeader($result['created']===5,'Incorrect valid import count');
    checkHeader((int)$pdo->query("SELECT COUNT(*) FROM students WHERE status='completed' AND special_status='pass_out' AND mobile_number IS NULL AND address IS NULL")->fetchColumn()===4,'Passout/optional fields not persisted');
    (new App\Academic\AcademicRollover($pdo))->run('2026-10-31',1,'test',true);
    checkHeader((int)$pdo->query("SELECT COUNT(*) FROM students WHERE status='completed' AND special_status='pass_out'")->fetchColumn()===4,'Progression reactivated passed-out students');
    file_put_contents($file,"Roll No,Academic Session,Name,Branch,Department,School,Year of Study,Semester,Section\n235UCS099,2023-2024,Synthetic,Computing,Computing,ICT,1,1,A\n");
    $id=$service->stage($file,'without-contact-columns.csv',1);checkHeader((int)$pdo->query('SELECT valid_rows FROM import_batches WHERE id='.$id)->fetchColumn()===1,'Optional contact columns were required');
    file_put_contents($file,"Rollnumber,Enrollment No.,Academic Session,Name,Branch,Department,School,Year of Study,Semester,Section\n235UCS100,0012345678,2023-2024,Synthetic,Computing,Computing,ICT,1,1,A\n");
    $id=$service->stage($file,'separate-identifiers.csv',1);
    $row=$pdo->query('SELECT normalized_data FROM import_rows WHERE import_batch_id='.$id)->fetchColumn();$data=json_decode($row,true);
    checkHeader($data['roll_no_original']==='235UCS100'&&$data['enrollment_number']==='0012345678','Separate identifiers were overwritten during validation');
    $pdo->beginTransaction();$service->commit($id,1);$pdo->commit();
    $stored=$pdo->query("SELECT roll_no_original,enrollment_number FROM students WHERE normalized_roll_no='235UCS100'")->fetch(PDO::FETCH_ASSOC);
    checkHeader($stored['roll_no_original']==='235UCS100'&&$stored['enrollment_number']==='0012345678','Separate identifiers or enrollment leading zeros lost on commit');
    $before=(int)$pdo->query('SELECT COUNT(*) FROM students')->fetchColumn();
    $pdo->beginTransaction();$repeat=$service->commit($id,1);$pdo->commit();
    checkHeader($repeat['already_committed']===true&&$repeat['created']===1,'Repeated commit was not recognized');
    checkHeader((int)$pdo->query('SELECT COUNT(*) FROM students')->fetchColumn()===$before,'Repeated commit duplicated students');
    $missing=false;try{$pdo->beginTransaction();$service->commit(999999,1);}catch(RuntimeException $e){$missing=str_contains($e->getMessage(),'not found');}finally{if($pdo->inTransaction())$pdo->rollBack();}checkHeader($missing,'Missing import error is unclear');
    file_put_contents($file,"Roll No,Academic Session,Name,Branch,Department,School,Year of Study,Semester,Section\n235XYZ001,2023-2024,Synthetic,Unknown branch,Computing,ICT,1,1,A\n235XYZ002,2023-2024,,Unknown branch,Computing,ICT,1,1,A\n");
    $id=$service->stage($file,'unknown-programme.csv',1);$warnings=$pdo->query('SELECT *,source_row_number AS row_number FROM import_rows WHERE import_batch_id='.$id.' ORDER BY source_row_number')->fetchAll(PDO::FETCH_ASSOC);
    checkHeader($warnings[0]['validation_status']==='warning','Missing mapping should be a warning');
    $explanation=implode(' ',json_decode($warnings[0]['validation_messages'],true));
    checkHeader(str_contains($explanation,'XYZ')&&str_contains($explanation,'235XYZ001')&&str_contains($explanation,'admission batch')&&str_contains($explanation,'Add or correct'),'Warning does not explain missing mapping and remedy');
    checkHeader($warnings[1]['validation_status']==='invalid','Warning downgraded a required-field error');
    $app=new App\Foundation\Application(BASE_PATH);$app->boot();$app->session()->put('user',['id'=>1,'name'=>'Tester','role_code'=>'admin','role_name'=>'Admin']);
    $warnings[0]['validation_messages']='[]'; // Older saved previews must explain warnings too.
    $batch=$pdo->query('SELECT * FROM import_batches WHERE id='.$id)->fetch(PDO::FETCH_ASSOC);
    $html=App\View\View::render('students/import-preview',['batch'=>$batch,'rows'=>[$warnings[0]]]);
    checkHeader(str_contains($html,'Missing programme mapping: code XYZ')&&str_contains($html,'235XYZ001'),'Legacy warning preview still lacks explanation');
    checkHeader(!str_contains($html,'Ready to import</td>'),'Warning falsely says ready');
    echo "Student import: PASS (BOM headers, separate roll/enrollment and leading zeros, optional contacts, Passout, numeric guards, commit and progression)\n";
}finally{if(is_file($file))unlink($file);$server->exec("DROP DATABASE IF EXISTS `$db`");}
