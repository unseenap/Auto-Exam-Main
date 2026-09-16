<?php

declare(strict_types=1);

namespace App\Exams;

use DateTimeImmutable;
use PDO;
use RuntimeException;

final class ScheduleReviewService
{
    public function __construct(private readonly PDO $pdo) {}

    public function setLock(int $runId,int $examinationId,bool $locked,int $userId):void
    {
        $paper=$this->paper($runId,$examinationId);if(!$paper)throw new RuntimeException('Generated paper was not found in this scheduling run.');if($paper['run_status']!=='generated'||$paper['status']!=='draft')throw new RuntimeException('Only a generated, unapproved draft can be edited.');
        $this->pdo->beginTransaction();try{$this->pdo->prepare('UPDATE examinations SET is_locked=:locked WHERE id=:id')->execute(['locked'=>$locked?1:0,'id'=>$examinationId]);$this->pdo->prepare("UPDATE scheduling_run_items SET item_status=:status WHERE scheduling_run_id=:run AND examination_id=:exam")->execute(['status'=>$locked?'locked':'scheduled','run'=>$runId,'exam'=>$examinationId]);$this->audit($userId,$locked?'date_sheet.paper_locked':'date_sheet.paper_unlocked',$examinationId,['run_id'=>$runId]);$this->pdo->commit();}catch(\Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }

    public function move(int $runId,int $examinationId,string $date,int $shiftId,int $userId):void
    {
        $paper=$this->paper($runId,$examinationId);if(!$paper)throw new RuntimeException('Generated paper was not found in this scheduling run.');if((int)$paper['is_locked']===1)throw new RuntimeException('Unlock this paper before moving it.');
        $validDate=$this->value('SELECT COUNT(*) FROM exam_calendar_dates WHERE cycle_id=:cycle AND exam_date=:date AND is_exam_day=1',['cycle'=>$paper['cycle_id'],'date'=>$date]);if((int)$validDate!==1)throw new RuntimeException('The selected date is not an enabled examination day.');
        $validShift=$this->value('SELECT COUNT(*) FROM exam_shifts WHERE id=:shift AND cycle_id=:cycle',['shift'=>$shiftId,'cycle'=>$paper['cycle_id']]);if((int)$validShift!==1)throw new RuntimeException('The selected shift does not belong to this examination cycle.');
        $rules=json_decode($paper['rule_snapshot'],true,flags:JSON_THROW_ON_ERROR);$gap=max(0,(int)($rules['minimum_gap_days']??1));$maximum=max(1,(int)($rules['maximum_papers_per_day']??1));
        if(!empty($rules['avoid_consecutive_days']))$gap=max(1,$gap);
        $cohorts=$this->query('SELECT programme_id,semester FROM examination_cohorts WHERE examination_id=:exam',['exam'=>$examinationId]);if(!$cohorts)throw new RuntimeException('The paper cohort is missing.');
        foreach($cohorts as $cohort){
            $others=$this->query("SELECT DISTINCT e.id,e.exam_date,e.shift_id FROM examinations e JOIN examination_cohorts ec ON ec.examination_id=e.id WHERE e.cycle_id=:cycle AND ec.programme_id=:programme AND ec.semester=:semester AND e.id<>:exam AND e.status<>'cancelled'",['cycle'=>$paper['cycle_id'],'programme'=>$cohort['programme_id'],'semester'=>$cohort['semester'],'exam'=>$examinationId]);
            $sameDay=0;foreach($others as $other){
                $difference=(int)(new DateTimeImmutable($date))->diff(new DateTimeImmutable($other['exam_date']))->days;
                if($difference===0){$sameDay++;if((int)$other['shift_id']===$shiftId)throw new RuntimeException('A cohort of this common paper already has an examination in that session.');}
                if(($difference===0&&$gap>0)||($difference>0&&$difference<=$gap))throw new RuntimeException("The move violates the mandatory {$gap}-day cohort gap.");
            }
            if($sameDay>=$maximum)throw new RuntimeException('The move exceeds the daily paper limit for a cohort of this common paper.');
        }
        $duplicate=$this->value("SELECT COUNT(*) FROM examinations WHERE cycle_id=:cycle AND course_id=:course AND exam_date=:date AND shift_id=:shift AND category=:category AND id<>:exam AND status<>'cancelled'",['cycle'=>$paper['cycle_id'],'course'=>$paper['course_id'],'date'=>$date,'shift'=>$shiftId,'category'=>$paper['category'],'exam'=>$examinationId]);if((int)$duplicate>0)throw new RuntimeException('The same subject already occupies this date and shift.');
        $old=['exam_date'=>$paper['exam_date'],'shift_id'=>(int)$paper['shift_id']];$this->pdo->beginTransaction();try{$this->pdo->prepare('UPDATE examinations SET exam_date=:date,shift_id=:shift WHERE id=:id')->execute(['date'=>$date,'shift'=>$shiftId,'id'=>$examinationId]);$this->pdo->prepare("UPDATE scheduling_run_items SET assigned_date=:date,shift_id=:shift,reason='Manually moved after constraint validation.' WHERE scheduling_run_id=:run AND examination_id=:exam")->execute(['date'=>$date,'shift'=>$shiftId,'run'=>$runId,'exam'=>$examinationId]);$this->audit($userId,'date_sheet.paper_moved',$examinationId,['run_id'=>$runId,'before'=>$old,'after'=>['exam_date'=>$date,'shift_id'=>$shiftId]]);$this->pdo->commit();}catch(\Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }

    public function prepareRegeneration(int $runId,int $userId):int
    {
        $run=$this->row("SELECT * FROM scheduling_runs WHERE id=:id AND status='generated'",['id'=>$runId]);if(!$run)throw new RuntimeException('Only a generated run can be regenerated.');$this->pdo->beginTransaction();try{
            $count=(int)$this->value('SELECT COUNT(*) FROM examinations WHERE generated_by_run_id=:run AND is_locked=0',['run'=>$runId]);
            $statement=$this->pdo->prepare("INSERT INTO scheduling_runs(cycle_id,school_id,status,rule_snapshot,validation_summary,created_by) VALUES(:cycle,:school,'ready',:rules,:summary,:user)");$statement->execute(['cycle'=>$run['cycle_id'],'school'=>$run['school_id'],'rules'=>$run['rule_snapshot'],'summary'=>json_encode(['regenerated_from'=>$runId,'unlocked_papers_to_regenerate'=>$count]),'user'=>$userId]);$newRunId=(int)$this->pdo->lastInsertId();$this->audit($userId,'date_sheet.regeneration_prepared',$newRunId,['previous_run_id'=>$runId,'removed_unlocked_papers'=>$count]);$this->pdo->commit();return $newRunId;
        }catch(\Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }

    private function paper(int $runId,int $examId):array|false{$q=$this->pdo->prepare('SELECT e.*,sr.rule_snapshot,sr.status AS run_status FROM scheduling_run_items sri JOIN examinations e ON e.id=sri.examination_id JOIN scheduling_runs sr ON sr.id=sri.scheduling_run_id WHERE e.id=:exam AND sr.id=:run');$q->execute(['exam'=>$examId,'run'=>$runId]);return $q->fetch(PDO::FETCH_ASSOC);}
    private function audit(int $userId,string $action,int $entityId,array $values):void{$this->pdo->prepare('INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,:action,\'examination\',:id,:data)')->execute(['user'=>$userId,'action'=>$action,'id'=>$entityId,'data'=>json_encode($values)]);}
    private function row(string $sql,array $parameters):array|false{$q=$this->pdo->prepare($sql);$q->execute($parameters);return $q->fetch(PDO::FETCH_ASSOC);}
    private function query(string $sql,array $parameters):array{$q=$this->pdo->prepare($sql);$q->execute($parameters);return $q->fetchAll(PDO::FETCH_ASSOC);}
    private function value(string $sql,array $parameters):mixed{$q=$this->pdo->prepare($sql);$q->execute($parameters);return $q->fetchColumn();}
}
