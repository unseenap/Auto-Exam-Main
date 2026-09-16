<?php

declare(strict_types=1);

namespace App\Exams;

use PDO;
use RuntimeException;

final class SchedulePublicationService
{
    public function __construct(private readonly PDO $pdo) {}

    public function finalChecks(int $runId):array
    {
        $run=$this->run($runId);if(!$run)throw new RuntimeException('Scheduling run not found.');$checks=[];
        $unscheduled=(int)$this->value("SELECT COUNT(*) FROM scheduling_run_items WHERE scheduling_run_id=:run AND item_status='unscheduled'",['run'=>$runId]);$checks[]=['state'=>$unscheduled?'blocked':'pass','message'=>$unscheduled?"{$unscheduled} subjects remain unscheduled.":'Every scheduling item has a placement.'];
        $blocked=(int)$this->value("SELECT COUNT(*) FROM scheduling_conflicts WHERE scheduling_run_id=:run AND severity='blocked'",['run'=>$runId]);$checks[]=['state'=>$blocked?'blocked':'pass','message'=>$blocked?"{$blocked} blocking conflicts remain.":'No blocking scheduling conflicts remain.'];
        $invalidDates=(int)$this->value("SELECT COUNT(*) FROM scheduling_run_items sri JOIN examinations e ON e.id=sri.examination_id LEFT JOIN exam_calendar_dates cd ON cd.cycle_id=e.cycle_id AND cd.exam_date=e.exam_date AND cd.is_exam_day=1 WHERE sri.scheduling_run_id=:run AND cd.id IS NULL",['run'=>$runId]);$checks[]=['state'=>$invalidDates?'blocked':'pass','message'=>$invalidDates?"{$invalidDates} papers occupy disabled or missing calendar dates.":'All papers use enabled examination dates.'];
        $invalidShifts=(int)$this->value("SELECT COUNT(*) FROM scheduling_run_items sri JOIN examinations e ON e.id=sri.examination_id JOIN scheduling_runs sr ON sr.id=sri.scheduling_run_id LEFT JOIN exam_shifts es ON es.id=e.shift_id AND es.cycle_id=sr.cycle_id WHERE sri.scheduling_run_id=:run AND es.id IS NULL",['run'=>$runId]);$checks[]=['state'=>$invalidShifts?'blocked':'pass','message'=>$invalidShifts?"{$invalidShifts} papers use invalid shifts.":'All papers use shifts from this cycle.'];
        $paperCount=(int)$this->value('SELECT COUNT(*) FROM scheduling_run_items WHERE scheduling_run_id=:run AND examination_id IS NOT NULL',['run'=>$runId]);$checks[]=['state'=>$paperCount?'pass':'blocked','message'=>$paperCount?"{$paperCount} examination papers are ready for approval.":'The run contains no examination papers.'];
        $labs=$this->pdo->prepare('SELECT DISTINCT c.name FROM scheduling_run_items sri JOIN examinations e ON e.id=sri.examination_id JOIN courses c ON c.id=e.course_id WHERE sri.scheduling_run_id=?');$labs->execute([$runId]);$labCount=count(array_filter($labs->fetchAll(PDO::FETCH_COLUMN),static fn(string $name):bool=>WrittenPaperPolicy::isLab($name)));
        $checks[]=['state'=>$labCount?'blocked':'pass','message'=>$labCount?"{$labCount} lab/practical subjects remain in this draft. Regenerate the draft without them.":'No lab/practical subjects are assigned.'];
        return ['checks'=>$checks,'blocked'=>count(array_filter($checks,static fn(array $check):bool=>$check['state']==='blocked'))];
    }

    public function approve(int $runId,int $userId):void
    {
        $run=$this->run($runId);if(!$run||$run['status']!=='generated')throw new RuntimeException('Only a generated draft can be approved.');$validation=$this->finalChecks($runId);if($validation['blocked'])throw new RuntimeException('Final validation is blocked. Resolve every listed issue before approval.');
        $this->pdo->beginTransaction();try{$this->pdo->prepare("UPDATE scheduling_runs SET status='approved',approved_by=:user,approved_at=NOW() WHERE id=:run")->execute(['user'=>$userId,'run'=>$runId]);$this->audit($userId,'date_sheet.run_approved',$runId,['final_checks'=>$validation['checks']]);$this->pdo->commit();}catch(\Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }

    public function publish(int $runId,int $userId):void
    {
        $run=$this->run($runId);if(!$run||$run['status']!=='approved')throw new RuntimeException('The scheduling run must be approved before publication.');$validation=$this->finalChecks($runId);if($validation['blocked'])throw new RuntimeException('Final validation no longer passes. Publication was stopped.');
        $this->pdo->beginTransaction();try{$this->pdo->prepare("UPDATE examinations e JOIN scheduling_run_items sri ON sri.examination_id=e.id SET e.status='published' WHERE sri.scheduling_run_id=:run")->execute(['run'=>$runId]);$this->pdo->prepare("UPDATE scheduling_runs SET status='published',published_by=:user,published_at=NOW() WHERE id=:run")->execute(['user'=>$userId,'run'=>$runId]);$this->pdo->prepare("UPDATE exam_cycles SET status='published',published_at=COALESCE(published_at,NOW()) WHERE id=:cycle")->execute(['cycle'=>$run['cycle_id']]);$this->audit($userId,'date_sheet.run_published',$runId,['cycle_id'=>(int)$run['cycle_id'],'school_id'=>(int)$run['school_id']]);$this->pdo->commit();}catch(\Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }

    private function run(int $id):array|false{$q=$this->pdo->prepare('SELECT * FROM scheduling_runs WHERE id=:id');$q->execute(['id'=>$id]);return $q->fetch(PDO::FETCH_ASSOC);}
    private function value(string $sql,array $parameters):mixed{$q=$this->pdo->prepare($sql);$q->execute($parameters);return $q->fetchColumn();}
    private function audit(int $userId,string $action,int $runId,array $values):void{$this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,:action,'scheduling_run',:run,:data)")->execute(['user'=>$userId,'action'=>$action,'run'=>$runId,'data'=>json_encode($values)]);}
}
