<?php
declare(strict_types=1);
namespace App\Academic;

use DateTimeImmutable;
use InvalidArgumentException;

final class AcademicCalendar
{
    public function __construct(public readonly string $sessionStart='07-01',public readonly string $evenStart='01-01')
    {
        foreach([$sessionStart,$evenStart] as $md){
            if(!preg_match('/^(\d{2})-(\d{2})$/',$md,$m)||!checkdate((int)$m[1],(int)$m[2],2001))throw new InvalidArgumentException('Use a valid MM-DD calendar date (excluding 29 February).');
        }
        if($sessionStart===$evenStart)throw new InvalidArgumentException('Session and even-semester start dates must be different.');
    }

    public function period(string $date):array
    {
        $d=DateTimeImmutable::createFromFormat('!Y-m-d',$date);
        if(!$d||$d->format('Y-m-d')!==$date)throw new InvalidArgumentException('Use a valid YYYY-MM-DD date.');
        $year=(int)$d->format('Y');
        if($d->format('m-d')<$this->sessionStart)$year--;
        $odd=$year.'-'.$this->sessionStart;
        $even=($year+($this->evenStart<$this->sessionStart?1:0)).'-'.$this->evenStart;
        $term=$date>=$even?2:1;
        return ['academic_session'=>$year.'-'.($year+1),'session_start_year'=>$year,'term'=>$term,'start_date'=>$term===1?$odd:$even,'next_date'=>$term===1?$even:($year+1).'-'.$this->sessionStart];
    }

    public function placement(string $date,array $batch,int $duration,int $delay=0):array
    {
        $period=$this->period($date);
        $semester=($period['session_start_year']-(int)$batch['start_year'])*2+$period['term']-$delay;
        $state=$semester<1?'not_started':($semester>$duration?'awaiting_completion':'active');
        $semester=max(1,min(max(1,$duration),$semester));
        return $period+['semester'=>$semester,'study_year'=>(int)ceil($semester/2),'placement_status'=>$state];
    }
}
