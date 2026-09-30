<?php

declare(strict_types=1);

namespace App\Academic;

final class BatchProgression
{
    public static function usesCurrentSemester(array $cycle): bool
    {
        return in_array((string)($cycle['exam_type']??''),['mid_sem','end_sem','regular'],true);
    }

    public static function calculate(array $cycle,array $batch,int $durationSemesters): array
    {
        preg_match('/(\d{4})/',(string)($cycle['academic_year']??''),$match);
        $month=(int)date('n',strtotime((string)$cycle['start_date']));
        $sessionStart=isset($match[1])?(int)$match[1]:((int)date('Y',strtotime((string)$cycle['start_date']))-($month<7?1:0));
        $studyYear=$sessionStart-(int)$batch['start_year']+1;
        $semester=$studyYear*2-($month>=7?1:0);
        $maximumYear=(int)ceil(max(1,$durationSemesters)/2);
        $active=$studyYear>=1&&$studyYear<=$maximumYear&&$semester>=1&&$semester<=$durationSemesters&&$sessionStart<(int)$batch['end_year'];
        return ['academic_session_start'=>$sessionStart,'study_year'=>$studyYear,'semester'=>$semester,'active'=>$active,'completed'=>$studyYear>$maximumYear||$sessionStart>=(int)$batch['end_year']];
    }
}
