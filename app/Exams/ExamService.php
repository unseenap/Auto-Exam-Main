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
            $calendar=$this->pdo->prepare('INSERT INTO exam_calendar_dates(cycle_id,exam_date,is_exam_day,day_type,note) VALUES(:cycle,:date,:enabled,:type,:note)');
            $period=new DatePeriod(new DateTimeImmutable($data['start_date']),new DateInterval('P1D'),(new DateTimeImmutable($data['end_date']))->modify('+1 day'));
            foreach($period as $date){$sunday=$date->format('N')==='7';$calendar->execute(['cycle'=>$cycleId,'date'=>$date->format('Y-m-d'),'enabled'=>$sunday?0:1,'type'=>$sunday?'sunday':'exam_day','note'=>$sunday?'Sunday':null]);}
            $this->pdo->commit();return $cycleId;
        }catch(\Throwable $e){$this->pdo->rollBack();throw $e;}
    }

    public function schedule(array $data): int
    {
        $subject=$this->pdo->prepare('SELECT name FROM courses WHERE id=?');$subject->execute([$data['course_id']]);$subjectName=$subject->fetchColumn();
        if($subjectName!==false && WrittenPaperPolicy::isLab((string)$subjectName))throw new RuntimeException('Lab/practical subjects cannot be assigned to the written date sheet.');
        $registration=$this->resolveRegistrations($data);
        $session=$this->pdo->prepare("SELECT COUNT(*) FROM exam_cycles c JOIN exam_shifts s ON s.cycle_id=c.id JOIN exam_calendar_dates d ON d.cycle_id=c.id WHERE c.id=? AND s.id=? AND d.exam_date=? AND d.is_exam_day=1 AND c.status='draft'");
        $session->execute([$data['cycle_id'],$data['shift_id'],$data['exam_date']]);
        if(!(int)$session->fetchColumn())throw new RuntimeException('Choose an enabled date and a shift belonging to a draft examination cycle.');
        $curriculum=$this->pdo->prepare('SELECT COUNT(*) FROM programme_courses WHERE programme_id=:programme AND course_id=:course AND semester=:semester');
        $curriculum->execute(['programme'=>$data['programme_id'],'course'=>$data['course_id'],'semester'=>$data['semester']]);
        if((int)$curriculum->fetchColumn()===0)throw new RuntimeException('The selected subject is not assigned to this programme and semester curriculum.');
        $conflict=$this->pdo->prepare("SELECT COUNT(*) FROM examinations e JOIN examination_cohorts ec ON ec.examination_id=e.id
            WHERE e.cycle_id=:cycle AND e.exam_date=:date AND e.shift_id=:shift AND ec.programme_id=:programme AND ec.semester=:semester AND e.status<>'cancelled'");
        $conflict->execute(['cycle'=>$data['cycle_id'],'date'=>$data['exam_date'],'shift'=>$data['shift_id'],'programme'=>$data['programme_id'],'semester'=>$data['semester']]);
        if((int)$conflict->fetchColumn()>0 && $registration['student_ids']===null && !$registration['batch_id'])throw new RuntimeException('This programme and semester already has a paper in the selected date and shift.');
        $ownsTransaction=!$this->pdo->inTransaction();if($ownsTransaction)$this->pdo->beginTransaction();try{
            $shared=$this->pdo->prepare('SELECT id,status,is_locked FROM examinations WHERE cycle_id=? AND shift_id=? AND course_id=? AND exam_date=? AND category=? FOR UPDATE');
            $shared->execute([$data['cycle_id'],$data['shift_id'],$data['course_id'],$data['exam_date'],$data['category']]);$existing=$shared->fetch(PDO::FETCH_ASSOC);
            if($existing && ($existing['status']!=='draft'||$existing['is_locked']))throw new RuntimeException('The common paper is locked or no longer a draft.');
            if($existing){$examId=(int)$existing['id'];}else{
                $exam=$this->pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,category,status) VALUES(:cycle,:shift,:course,:date,:category,'draft')");
                $exam->execute(['cycle'=>$data['cycle_id'],'shift'=>$data['shift_id'],'course'=>$data['course_id'],'date'=>$data['exam_date'],'category'=>$data['category']]);$examId=(int)$this->pdo->lastInsertId();
            }
            $cohort=$this->pdo->prepare('SELECT id FROM examination_cohorts WHERE examination_id=? AND programme_id=? AND semester=? AND batch_id <=> ?');
            $cohort->execute([$examId,$data['programme_id'],$data['semester'],$registration['batch_id']]);
            if(!$cohort->fetchColumn())$this->pdo->prepare('INSERT INTO examination_cohorts(examination_id,programme_id,batch_id,semester,display_label) VALUES(?,?,?,?,?)')->execute([$examId,$data['programme_id'],$registration['batch_id'],$data['semester'],$data['display_label']??null]);
            $studentIds=$registration['student_ids'];
            if($studentIds===null){$q=$this->pdo->prepare("SELECT id FROM students WHERE programme_id=? AND semester=? AND status='active' AND (? IS NULL OR batch_id=?)");$q->execute([$data['programme_id'],$data['semester'],$registration['batch_id'],$registration['batch_id']]);$studentIds=$q->fetchAll(PDO::FETCH_COLUMN);}
            $check=$this->pdo->prepare("SELECT COUNT(*) FROM exam_eligibility ee JOIN examinations e ON e.id=ee.examination_id WHERE ee.student_id=? AND ee.eligibility_status='eligible' AND e.cycle_id=? AND e.exam_date=? AND e.shift_id=? AND e.id<>? AND e.status<>'cancelled'");
            $add=$this->pdo->prepare("INSERT INTO exam_eligibility(examination_id,student_id,eligibility_status,source) VALUES(?,?,'eligible',?) ON DUPLICATE KEY UPDATE source=IF(eligibility_status IN ('pending','ineligible') AND VALUES(source)='registration',VALUES(source),source),eligibility_status=IF(eligibility_status IN ('pending','ineligible') AND VALUES(source)='registration','eligible',eligibility_status)");
            foreach($studentIds as $studentId){$check->execute([$studentId,$data['cycle_id'],$data['exam_date'],$data['shift_id'],$examId]);if((int)$check->fetchColumn())throw new RuntimeException('A selected student already has another paper in this session. Review the registration list.');$add->execute([$examId,$studentId,$registration['student_ids']===null?'cohort':'registration']);}
            if($registration['student_ids']!==null)$this->pdo->prepare("UPDATE exam_eligibility ee JOIN students s ON s.id=ee.student_id SET ee.eligibility_status='ineligible',ee.source='registration' WHERE ee.examination_id=? AND ee.eligibility_status='pending' AND s.programme_id=? AND s.semester=? AND (? IS NULL OR s.batch_id=?)")->execute([$examId,$data['programme_id'],$data['semester'],$registration['batch_id'],$registration['batch_id']]);
            if($ownsTransaction)$this->pdo->commit();return $examId;
        }catch(\Throwable $e){if($ownsTransaction&&$this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }

    /** Resolve supplied university registrations without guessing repeats or electives. */
    public function resolveRegistrations(array $data): array
    {
        $batchId=null;$batchLabel=trim((string)($data['batch_label']??''));
        if($batchLabel!==''){$q=$this->pdo->prepare('SELECT id FROM batches WHERE programme_id=? AND label=?');$q->execute([$data['programme_id'],$batchLabel]);$batchId=$q->fetchColumn();if(!$batchId)throw new RuntimeException('Batch label was not found under this programme. Create the batch and assign its students first.');$batchId=(int)$batchId;}
        $rolls=array_values(array_unique(array_filter(array_map(static fn(string $roll):string=>strtoupper(trim($roll)),preg_split('/[|;,\r\n]+/',(string)($data['roll_numbers']??''))?:[]))));
        if(!$rolls && ($data['category']??'regular')!=='regular')throw new RuntimeException('Repeat and special papers require an explicit Roll Numbers list.');
        if(!$rolls && !empty($data['course_id'])){$q=$this->pdo->prepare("SELECT COUNT(*) FROM programme_courses WHERE programme_id=? AND semester=? AND course_id=? AND category='elective'");$q->execute([$data['programme_id'],$data['semester'],$data['course_id']]);if((int)$q->fetchColumn())throw new RuntimeException('Elective papers require an explicit Roll Numbers list.');}
        if(!$rolls)return ['batch_id'=>$batchId,'student_ids'=>null];
        $q=$this->pdo->prepare("SELECT id,semester,batch_id FROM students WHERE programme_id=? AND normalized_roll_no=? AND status='active'");$ids=[];
        foreach($rolls as $roll){$q->execute([$data['programme_id'],$roll]);$student=$q->fetch(PDO::FETCH_ASSOC);if(!$student||($batchId && (int)$student['batch_id']!==$batchId)||(($data['category']??'regular')==='regular' && (int)$student['semester']!==(int)$data['semester']))throw new RuntimeException('Roll number '.$roll.' does not match the programme, batch, semester or active status.');$ids[]=(int)$student['id'];}
        return ['batch_id'=>$batchId,'student_ids'=>$ids];
    }
}
