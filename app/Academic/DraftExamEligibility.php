<?php
declare(strict_types=1);
namespace App\Academic;
use PDO;

final class DraftExamEligibility
{
    public function __construct(private readonly PDO $pdo) {}

    /** Reconcile cohort-derived draft registrations; explicit and published records stay fixed. */
    public function refresh():int
    {
        $papers=$this->pdo->query("SELECT e.id,e.cycle_id FROM examinations e WHERE e.status='draft' AND e.category='regular' AND NOT EXISTS(SELECT 1 FROM scheduling_run_items ri JOIN scheduling_runs r ON r.id=ri.scheduling_run_id WHERE ri.examination_id=e.id AND r.status IN ('approved','published')) ORDER BY e.id")->fetchAll(PDO::FETCH_ASSOC);
        $placement=new StudentExamPlacement($this->pdo);$changes=0;
        foreach($papers as $paper){
            $q=$this->pdo->prepare("SELECT DISTINCT ec.programme_id,ec.batch_id,ec.semester,ec.section,pc.category FROM examination_cohorts ec JOIN examinations e ON e.id=ec.examination_id JOIN programme_courses pc ON pc.programme_id=ec.programme_id AND pc.course_id=e.course_id AND pc.semester=ec.semester AND (pc.section=ec.section OR pc.section='ALL') AND (pc.batch_id=ec.batch_id OR pc.batch_id IS NULL) WHERE ec.examination_id=?");$q->execute([$paper['id']]);$desired=[];
            foreach($q->fetchAll(PDO::FETCH_ASSOC) as $cohort){
                foreach($placement->cohort((int)$paper['cycle_id'],(int)$cohort['programme_id'],$cohort['batch_id']?(int)$cohort['batch_id']:null,(int)$cohort['semester'],$cohort['section']) as $student){
                    $state=$cohort['category']==='back_paper'?'pending':'eligible';
                    if(!isset($desired[$student['id']])||$state==='pending')$desired[$student['id']]=$state;
                }
            }
            $q=$this->pdo->prepare("SELECT student_id,eligibility_status FROM exam_eligibility WHERE examination_id=? AND source='cohort'");$q->execute([$paper['id']]);
            $existing=$q->fetchAll(PDO::FETCH_KEY_PAIR);
            foreach($existing as $student=>$state)if(!isset($desired[$student])){$this->pdo->prepare("DELETE FROM exam_eligibility WHERE examination_id=? AND student_id=? AND source='cohort'")->execute([$paper['id'],$student]);$changes++;}
            foreach($desired as $student=>$state){
                $q=$this->pdo->prepare("INSERT INTO exam_eligibility(examination_id,student_id,eligibility_status,source) VALUES(?,?,?,'cohort') ON DUPLICATE KEY UPDATE eligibility_status=IF(source='cohort',VALUES(eligibility_status),eligibility_status)");$q->execute([$paper['id'],$student,$state]);if($q->rowCount())$changes++;
            }
        }
        return $changes;
    }
}
