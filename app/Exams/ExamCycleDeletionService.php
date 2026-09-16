<?php
declare(strict_types=1);
namespace App\Exams;

use PDO;
use RuntimeException;

final class ExamCycleDeletionService
{
    public function __construct(private readonly PDO $pdo) {}

    public function preview(int $id,int $userId=0): array
    {
        $q=$this->pdo->prepare('SELECT * FROM exam_cycles WHERE id=?');$q->execute([$id]);$cycle=$q->fetch(PDO::FETCH_ASSOC);
        if(!$cycle)throw new RuntimeException('Examination cycle not found.');
        if(!in_array($cycle['status'],['draft','published'],true))throw new RuntimeException('Closed and archived examination cycles are protected.');
        $published=$cycle['status']==='published';
        if($published){$q=$this->pdo->prepare("SELECT COUNT(*) FROM users u JOIN roles r ON r.id=u.role_id WHERE u.id=? AND u.status='active' AND r.code='admin'");$q->execute([$userId]);if(!(int)$q->fetchColumn())throw new RuntimeException('Only an active administrator can delete a published date sheet and its examination cycle.');}
        $checks=[
            "SELECT COUNT(*) FROM seating_allocations WHERE cycle_id=? AND status<>'draft'",
            'SELECT COUNT(*) FROM invigilation_allocations WHERE cycle_id=?',
            'SELECT COUNT(*) FROM attendance a JOIN examinations e ON e.id=a.examination_id WHERE e.cycle_id=?'
        ];
        if(!$published){$checks[]="SELECT COUNT(*) FROM examinations WHERE cycle_id=? AND status<>'draft'";$checks[]="SELECT COUNT(*) FROM scheduling_runs WHERE cycle_id=? AND status IN ('approved','published')";}
        foreach($checks as $sql){$q=$this->pdo->prepare($sql);$q->execute([$id]);if((int)$q->fetchColumn())throw new RuntimeException('This cycle contains protected examination, seating, approval, attendance or invigilation records and cannot be deleted.');}
        $counts=[];
        foreach(['examinations'=>'Papers','seating_allocations'=>'Draft seating versions','scheduling_runs'=>'Scheduling runs','exam_shifts'=>'Shifts','exam_calendar_dates'=>'Calendar dates'] as $table=>$label){$q=$this->pdo->prepare("SELECT COUNT(*) FROM {$table} WHERE cycle_id=?");$q->execute([$id]);$counts[$label]=(int)$q->fetchColumn();}
        return ['cycle'=>$cycle,'counts'=>$counts];
    }

    public function delete(int $id,int $userId,string $name,string $fingerprint):void
    {
        $this->pdo->beginTransaction();
        try{
            $q=$this->pdo->prepare('SELECT id FROM exam_cycles WHERE id=? FOR UPDATE');$q->execute([$id]);
            $preview=$this->preview($id,$userId);
            if($name!==$preview['cycle']['name'])throw new RuntimeException('The cycle name does not match. Nothing was deleted.');
            if(!hash_equals($fingerprint,self::fingerprint($preview)))throw new RuntimeException('The cycle changed after your review. Please start the confirmation again.');
            $this->pdo->prepare('DELETE FROM seating_allocations WHERE cycle_id=?')->execute([$id]);
            $this->pdo->prepare('DELETE FROM examinations WHERE cycle_id=?')->execute([$id]);
            // Remove run items (via their parent runs) before cycle deletion cascades
            // to shifts. InnoDB does not defer the run-item -> shift foreign key.
            $this->pdo->prepare('DELETE FROM scheduling_runs WHERE cycle_id=?')->execute([$id]);
            $this->pdo->prepare('DELETE fa FROM faculty_availability fa JOIN exam_shifts es ON es.id=fa.shift_id WHERE es.cycle_id=?')->execute([$id]);
            $this->pdo->prepare('DELETE FROM exam_cycles WHERE id=?')->execute([$id]);
            $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,old_values) VALUES(?,'exam_cycle.deleted','exam_cycle',?,?)")->execute([$userId,$id,json_encode($preview,JSON_THROW_ON_ERROR)]);
            $this->pdo->commit();
        }catch(\Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }

    public static function fingerprint(array $preview):string
    {
        return hash('sha256',json_encode($preview,JSON_THROW_ON_ERROR));
    }
}
