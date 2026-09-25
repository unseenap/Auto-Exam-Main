<?php

declare(strict_types=1);

namespace App\Exams;

use PDO;
use RuntimeException;

final class CourseDeletionService
{
    public function __construct(private readonly PDO $pdo) {}

    /** Remove the selected curriculum mapping and clean up an unused subject master. */
    public function deleteMapping(int $mappingId, int $userId): void
    {
        $this->pdo->beginTransaction();
        try {
            $q=$this->pdo->prepare('SELECT pc.*,c.code FROM programme_courses pc JOIN courses c ON c.id=pc.course_id WHERE pc.id=? FOR UPDATE');
            $q->execute([$mappingId]);$mapping=$q->fetch(PDO::FETCH_ASSOC);
            if(!$mapping)throw new RuntimeException('This course mapping no longer exists.');
            $q=$this->pdo->prepare('SELECT COUNT(*) FROM scheduling_run_items WHERE programme_course_id=?');
            $q->execute([$mappingId]);
            if((int)$q->fetchColumn())throw new RuntimeException('Cannot delete: this course mapping is referenced by scheduling history. Existing schedules must be preserved.');
            $q=$this->pdo->prepare('SELECT COUNT(*) FROM examinations e JOIN examination_cohorts ec ON ec.examination_id=e.id WHERE e.course_id=? AND ec.programme_id=? AND ec.semester <=> ?');
            $q->execute([$mapping['course_id'],$mapping['programme_id'],$mapping['semester']]);
            if((int)$q->fetchColumn())throw new RuntimeException('Cannot delete: this branch and semester already have examination records for the subject.');
            $this->pdo->prepare('DELETE FROM programme_courses WHERE id=?')->execute([$mappingId]);
            $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,old_values) VALUES(?,'course.curriculum_deleted','programme_course',?,?)")->execute([$userId,$mappingId,json_encode($mapping,JSON_THROW_ON_ERROR)]);
            $q=$this->pdo->prepare('SELECT COUNT(*) FROM programme_courses WHERE course_id=?');
            $q->execute([$mapping['course_id']]);
            $remainingMappings=(int)$q->fetchColumn();
            $q=$this->pdo->prepare('SELECT COUNT(*) FROM examinations WHERE course_id=?');
            $q->execute([$mapping['course_id']]);
            $historicExams=(int)$q->fetchColumn();
            if($remainingMappings===0&&$historicExams===0){
                $this->pdo->prepare('DELETE FROM courses WHERE id=?')->execute([$mapping['course_id']]);
                $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,old_values) VALUES(?,'course.deleted','course',?,?)")->execute([$userId,$mapping['course_id'],json_encode(['code'=>$mapping['code']],JSON_THROW_ON_ERROR)]);
            }
            $this->pdo->commit();
        } catch (\Throwable $e) {
            if($this->pdo->inTransaction())$this->pdo->rollBack();
            throw $e;
        }
    }
}
