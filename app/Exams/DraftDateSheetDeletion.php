<?php
declare(strict_types=1);

namespace App\Exams;

use PDO;
use RuntimeException;

final class DraftDateSheetDeletion
{
    public function __construct(private readonly PDO $pdo) {}

    public function delete(int $cycleId,int $runId,int $userId):array
    {
        $this->pdo->beginTransaction();
        try {
            $q=$this->pdo->prepare('SELECT * FROM scheduling_runs WHERE id=? AND cycle_id=? FOR UPDATE');
            $q->execute([$runId,$cycleId]);$run=$q->fetch(PDO::FETCH_ASSOC);
            if(!$run||!in_array($run['status'],['ready','generated','failed','discarded'],true))throw new RuntimeException('Only unapproved drafts can be deleted. Approved, published and running schedules are protected.');
            $q=$this->pdo->prepare('SELECT * FROM examinations WHERE generated_by_run_id=? FOR UPDATE');
            $q->execute([$runId]);$papers=$q->fetchAll(PDO::FETCH_ASSOC);$deleted=0;$preserved=0;
            foreach($papers as $paper){
                if((int)$paper['cycle_id']!==$cycleId||$paper['status']!=='draft')throw new RuntimeException('This draft contains published or completed papers and cannot be deleted.');
                $q=$this->pdo->prepare('SELECT MIN(scheduling_run_id) FROM scheduling_run_items WHERE examination_id=? AND scheduling_run_id<>?');$q->execute([$paper['id'],$runId]);$otherRun=$q->fetchColumn();
                if($otherRun){$this->pdo->prepare('UPDATE examinations SET generated_by_run_id=? WHERE id=?')->execute([$otherRun,$paper['id']]);$preserved++;continue;}
                foreach(['seating_assignments','seating_unallocated','attendance'] as $table){
                    $q=$this->pdo->prepare("SELECT COUNT(*) FROM {$table} WHERE examination_id=?");$q->execute([$paper['id']]);
                    if((int)$q->fetchColumn()>0)throw new RuntimeException('This draft is used by seating or attendance records. Remove those dependencies before deleting it.');
                }
                $this->pdo->prepare('DELETE FROM examinations WHERE id=?')->execute([$paper['id']]);$deleted++;
            }
            $this->pdo->prepare('DELETE FROM scheduling_runs WHERE id=?')->execute([$runId]);
            $result=['deleted_papers'=>$deleted,'preserved_shared_papers'=>$preserved];
            $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(?,'date_sheet.draft_deleted','scheduling_run',?,?)")->execute([$userId,$runId,json_encode(['cycle_id'=>$cycleId]+$result,JSON_THROW_ON_ERROR)]);
            $this->pdo->commit();return $result;
        }catch(\Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }
}
