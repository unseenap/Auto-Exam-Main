<?php

declare(strict_types=1);

namespace App\Exams;

use DateInterval;
use DatePeriod;
use DateTimeImmutable;
use PDO;
use RuntimeException;

final class ExamService
{
    public function __construct(private readonly PDO $pdo) {}

    public function createCycle(array $data, int $userId): int
    {
        $this->pdo->beginTransaction();
        try {
            $statement=$this->pdo->prepare("INSERT INTO exam_cycles(name,academic_year,exam_type,start_date,end_date,default_duration_minutes,status,created_by)
                VALUES(:name,:academic_year,:exam_type,:start_date,:end_date,:duration,'draft',:user)");
            $statement->execute(['name'=>$data['name'],'academic_year'=>$data['academic_year'],'exam_type'=>$data['exam_type'],
                'start_date'=>$data['start_date'],'end_date'=>$data['end_date'],'duration'=>$data['duration'],'user'=>$userId]);
            $cycleId=(int)$this->pdo->lastInsertId();
            $shift=$this->pdo->prepare('INSERT INTO exam_shifts(cycle_id,name,start_time,end_time,duration_minutes,sequence_no) VALUES(:cycle,:name,:start,:end,:duration,:sequence)');
            foreach($data['shifts'] as $index=>$item)$shift->execute(['cycle'=>$cycleId,'name'=>$item['name'],'start'=>$item['start'],'end'=>$item['end'],'duration'=>$item['duration'],'sequence'=>$index+1]);
            $calendar=$this->pdo->prepare('INSERT INTO exam_calendar_dates(cycle_id,exam_date,is_exam_day) VALUES(:cycle,:date,1)');
            $period=new DatePeriod(new DateTimeImmutable($data['start_date']),new DateInterval('P1D'),(new DateTimeImmutable($data['end_date']))->modify('+1 day'));
            foreach($period as $date)if(!in_array($date->format('N'),['7'],true))$calendar->execute(['cycle'=>$cycleId,'date'=>$date->format('Y-m-d')]);
            $this->pdo->commit();return $cycleId;
        }catch(\Throwable $e){$this->pdo->rollBack();throw $e;}
    }

    public function schedule(array $data): int
    {
        $curriculum=$this->pdo->prepare('SELECT COUNT(*) FROM programme_courses WHERE programme_id=:programme AND course_id=:course AND semester=:semester');
        $curriculum->execute(['programme'=>$data['programme_id'],'course'=>$data['course_id'],'semester'=>$data['semester']]);
        if((int)$curriculum->fetchColumn()===0)throw new RuntimeException('The selected subject is not assigned to this programme and semester curriculum.');
        $conflict=$this->pdo->prepare("SELECT COUNT(*) FROM examinations e JOIN examination_cohorts ec ON ec.examination_id=e.id
            WHERE e.cycle_id=:cycle AND e.exam_date=:date AND e.shift_id=:shift AND ec.programme_id=:programme AND ec.semester=:semester AND e.status<>'cancelled'");
        $conflict->execute(['cycle'=>$data['cycle_id'],'date'=>$data['exam_date'],'shift'=>$data['shift_id'],'programme'=>$data['programme_id'],'semester'=>$data['semester']]);
        if((int)$conflict->fetchColumn()>0)throw new RuntimeException('This programme and semester already has a paper in the selected date and shift.');
        $ownsTransaction=!$this->pdo->inTransaction();if($ownsTransaction)$this->pdo->beginTransaction();try{
            $exam=$this->pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,category,status) VALUES(:cycle,:shift,:course,:date,:category,'draft')");
            $exam->execute(['cycle'=>$data['cycle_id'],'shift'=>$data['shift_id'],'course'=>$data['course_id'],'date'=>$data['exam_date'],'category'=>$data['category']]);$examId=(int)$this->pdo->lastInsertId();
            $this->pdo->prepare('INSERT INTO examination_cohorts(examination_id,programme_id,batch_id,semester,display_label) VALUES(:exam,:programme,NULL,:semester,:label)')
                ->execute(['exam'=>$examId,'programme'=>$data['programme_id'],'semester'=>$data['semester'],'label'=>$data['display_label']]);
            $this->pdo->prepare("INSERT INTO exam_eligibility(examination_id,student_id,eligibility_status,source)
                SELECT :exam,id,'eligible','cohort' FROM students WHERE programme_id=:programme AND semester=:semester AND status='active'")
                ->execute(['exam'=>$examId,'programme'=>$data['programme_id'],'semester'=>$data['semester']]);
            if($ownsTransaction)$this->pdo->commit();return $examId;
        }catch(\Throwable $e){if($ownsTransaction&&$this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }
}
