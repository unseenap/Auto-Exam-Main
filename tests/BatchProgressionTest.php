<?php

declare(strict_types=1);

define('BASE_PATH',dirname(__DIR__));
spl_autoload_register(static function(string $class):void{$prefix='App\\';if(str_starts_with($class,$prefix))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,strlen($prefix))).'.php';});

use App\Academic\BatchProgression;

$batch=['start_year'=>2023,'end_year'=>2027];
$odd=BatchProgression::calculate(['academic_year'=>'2025-2026','start_date'=>'2025-10-06','exam_type'=>'mid_sem'],$batch,8);
assert($odd['active']===true&&$odd['study_year']===3&&$odd['semester']===5);
$even=BatchProgression::calculate(['academic_year'=>'2025-2026','start_date'=>'2026-03-10','exam_type'=>'end_sem'],$batch,8);
assert($even['active']===true&&$even['study_year']===3&&$even['semester']===6);
$completed=BatchProgression::calculate(['academic_year'=>'2027-2028','start_date'=>'2027-10-06','exam_type'=>'mid_sem'],$batch,8);
assert($completed['active']===false&&$completed['completed']===true);
assert(BatchProgression::usesCurrentSemester(['exam_type'=>'end_sem'])===true);
assert(BatchProgression::usesCurrentSemester(['exam_type'=>'back_paper'])===false);
echo "Batch progression: PASS (odd/even semester and completion rules)\n";
