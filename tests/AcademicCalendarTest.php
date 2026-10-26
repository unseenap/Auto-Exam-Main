<?php
declare(strict_types=1);
require dirname(__DIR__).'/app/Academic/AcademicCalendar.php';
require dirname(__DIR__).'/app/Academic/BatchProgression.php';
use App\Academic\AcademicCalendar;
use App\Academic\BatchProgression;
function calendarCheck(bool $ok,string $why):void{if(!$ok)throw new RuntimeException($why);}
$calendar=new AcademicCalendar();$batch=['start_year'=>2024,'end_year'=>2028];
foreach([
 ['2026-07-01','2026-2027',3,5,'active'],['2026-12-31','2026-2027',3,5,'active'],
 ['2027-01-01','2026-2027',3,6,'active'],['2027-06-30','2026-2027',3,6,'active'],
 ['2027-07-01','2027-2028',4,7,'active'],['2028-01-01','2027-2028',4,8,'active'],
 ['2028-07-01','2028-2029',4,8,'awaiting_completion'],['2023-12-01','2023-2024',1,1,'not_started']
] as [$date,$session,$year,$semester,$state]){
 $p=$calendar->placement($date,$batch,8);calendarCheck([$p['academic_session'],$p['study_year'],$p['semester'],$p['placement_status']]===[$session,$year,$semester,$state],'Wrong placement on '.$date);
}
calendarCheck($calendar->placement('2027-07-01',$batch,8,2)['semester']===5,'Repeated year delay ignored');
$custom=new AcademicCalendar('08-15','02-10');
calendarCheck($custom->period('2027-02-09')['term']===1&&$custom->period('2027-02-10')['term']===2,'Custom semester boundary failed');
$p=BatchProgression::calculate(['start_date'=>'2027-02-09','academic_year'=>'2026-2027'],$batch,8,$custom);
calendarCheck($p['semester']===5,'Scheduler calendar differs');
$caught=0;foreach([['02-29','01-01'],['07-01','07-01'],['13-01','01-01']] as $bad){try{new AcademicCalendar(...$bad);}catch(InvalidArgumentException){$caught++;}}
calendarCheck($caught===3,'Invalid calendar accepted');
echo "Academic calendar: PASS (year/semester boundaries, completion, future intake, repeats, custom dates, scheduler consistency).\n";
