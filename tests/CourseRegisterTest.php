<?php
declare(strict_types=1);
require dirname(__DIR__).'/bootstrap/app.php';
$pdo=(new App\Foundation\Database(require BASE_PATH.'/config/database.php'))->connection();
$programmes=$pdo->query('SELECT id,code,name FROM programmes')->fetchAll();
$register=new App\Exams\CourseRegister($pdo);
function check(bool $value,string $message):void{if(!$value)throw new RuntimeException($message);}
$start=microtime(true);$all=$register->load([],$programmes);
check(count($all['courses'])<=50,'Unbounded register');
check($all['total']===(int)$all['courseStats']['mappings'],'Incorrect totals');
if($all['pages']>1){$next=$register->load(['page'=>2],$programmes);check(!array_intersect(array_column($all['courses'],'mapping_id'),array_column($next['courses'],'mapping_id')),'Overlapping pages');}
foreach($all['filterAvailability'] as $programmeId=>$batches){
    $code=array_search($programmeId,array_column($programmes,'id','code'));
    foreach($batches as $batchId=>$semesters){
        $semester=array_key_first($semesters);$filtered=$register->load(['programme'=>$code,'batch_id'=>$batchId,'semester'=>$semester],$programmes);
        foreach($filtered['courses'] as $course)check((int)$course['programme_id']===$programmeId&&(int)$course['batch_id']===$batchId&&(int)$course['semester']===$semester,'Filter mismatch');
        check($filtered['filterAvailability']===$all['filterAvailability'],'Availability lost across pages');
        break 2;
    }
}
$invalid=$register->load(['programme'=>'INVALID','batch_id'=>999999,'semester'=>99,'page'=>999999],$programmes);
check($invalid['programmeFilter']===''&&$invalid['batchFilter']===0&&$invalid['semesterFilter']===0,'Invalid filters not reset');
check($invalid['page']===$invalid['pages'],'Page not clamped');
$batches=$pdo->query('SELECT id,programme_id,label FROM batches')->fetchAll();
$success=null;$error=null;extract($all,EXTR_SKIP);
ob_start();require BASE_PATH.'/resources/views/exams/courses.php';$html=ob_get_clean();
check(substr_count($html,'class="course-status-form"')===count($all['courses']),'Rendered row count differs');
check(str_contains($html,'Course register pages'),'Pagination navigation missing');
check(str_contains($html,'name="programme_id"')&&str_contains($html,'Save batch course'),'Course entry missing');
echo 'Course register: PASS (read-only; '.$all['total'].' mappings, at most 50 rendered per page; filters, totals, pagination checked; '.round((microtime(true)-$start)*1000).' ms)'.PHP_EOL;
