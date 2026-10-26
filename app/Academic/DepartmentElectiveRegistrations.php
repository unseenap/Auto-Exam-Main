<?php
declare(strict_types=1);
namespace App\Academic;

use PDO;
use Throwable;

/** A scheduled regular elective is a departmental assignment for its entire cohort. */
final class DepartmentElectiveRegistrations
{
    public function __construct(private readonly PDO $pdo) {}

    public function synchronize(?int $cycleId=null,?string $date=null,?int $shiftId=null,?int $actor=null):array
    {
        $ownsTransaction=!$this->pdo->inTransaction();
        if($ownsTransaction)$this->pdo->beginTransaction();
        try{
            $where=["e.status IN ('draft','published')","e.category='regular'","EXISTS(SELECT 1 FROM examination_cohorts ec JOIN programme_courses pc ON pc.programme_id=ec.programme_id AND pc.course_id=e.course_id AND pc.semester=ec.semester AND (pc.section=ec.section OR pc.section='ALL') AND (pc.batch_id=ec.batch_id OR pc.batch_id IS NULL) WHERE ec.examination_id=e.id AND pc.category='elective')"];$params=[];
            if($cycleId!==null){$where[]='e.cycle_id=?';$params[]=$cycleId;}
            if($date!==null){$where[]='e.exam_date=?';$params[]=$date;}
            if($shiftId!==null){$where[]='e.shift_id=?';$params[]=$shiftId;}
            $q=$this->pdo->prepare('SELECT e.*,c.start_date AS cycle_start_date FROM examinations e JOIN exam_cycles c ON c.id=e.cycle_id WHERE '.implode(' AND ',$where).' ORDER BY e.id FOR UPDATE');$q->execute($params);$papers=$q->fetchAll(PDO::FETCH_ASSOC);
            $counts=['papers'=>0,'eligibility_changes'=>0,'course_registrations'=>0,'protected_sessions'=>0];$placement=new StudentExamPlacement($this->pdo);$calendar=(new AcademicRollover($this->pdo))->calendar();
            foreach($papers as $paper){
                $q=$this->pdo->prepare("SELECT COUNT(*) FROM seating_allocations WHERE cycle_id=? AND exam_date=? AND shift_id=? AND status='published'");$q->execute([$paper['cycle_id'],$paper['exam_date'],$paper['shift_id']]);
                if((int)$q->fetchColumn()){$counts['protected_sessions']++;continue;}
                $q=$this->pdo->prepare("SELECT ec.*,pc.id AS curriculum_id FROM examination_cohorts ec JOIN programme_courses pc ON pc.programme_id=ec.programme_id AND pc.course_id=? AND pc.semester=ec.semester AND (pc.section=ec.section OR pc.section='ALL') AND (pc.batch_id=ec.batch_id OR pc.batch_id IS NULL) WHERE ec.examination_id=? AND pc.category='elective'");$q->execute([$paper['course_id'],$paper['id']]);$desired=[];$changed=0;
                foreach($q->fetchAll(PDO::FETCH_ASSOC) as $cohort){
                    foreach($placement->cohort((int)$paper['cycle_id'],(int)$cohort['programme_id'],$cohort['batch_id']?(int)$cohort['batch_id']:null,(int)$cohort['semester'],$cohort['section']) as $student){
                        $desired[(int)$student['id']]=true;
                        // 'core' is the existing marker for automatically required cohort registrations.
                        $register=$this->pdo->prepare("INSERT IGNORE INTO student_course_registrations(enrollment_id,programme_course_id,source) SELECT t.id,?,'core' FROM student_term_enrollments t JOIN exam_cycles c ON c.id=? WHERE t.student_id=? AND t.programme_id=? AND t.batch_id <=> ? AND t.semester=? AND t.placement_status IN ('active','held') AND t.academic_session=CONCAT(SUBSTRING(c.academic_year,1,4),'-',CAST(SUBSTRING(c.academic_year,1,4) AS UNSIGNED)+1) AND t.term=?");
                        $period=$calendar->period($paper['cycle_start_date']);
                        $register->execute([$cohort['curriculum_id'],$paper['cycle_id'],$student['id'],$cohort['programme_id'],$cohort['batch_id'],$cohort['semester'],$period['term']]);$counts['course_registrations']+=$register->rowCount();
                    }
                }
                foreach(array_keys($desired) as $student){
                    $q=$this->pdo->prepare("INSERT INTO exam_eligibility(examination_id,student_id,eligibility_status,source) VALUES(?,?,'eligible','cohort') ON DUPLICATE KEY UPDATE eligibility_status=IF(source<>'manual' AND eligibility_status<>'withdrawn','eligible',eligibility_status),source=IF(source<>'manual' AND eligibility_status<>'withdrawn','cohort',source)");$q->execute([$paper['id'],$student]);if($q->rowCount())$changed++;
                }
                // Retire stale pending cohort rows rather than letting them block seating forever.
                $q=$this->pdo->prepare("SELECT student_id FROM exam_eligibility WHERE examination_id=? AND eligibility_status='pending' AND source<>'manual'");$q->execute([$paper['id']]);
                foreach($q->fetchAll(PDO::FETCH_COLUMN) as $student)if(!isset($desired[(int)$student])){$this->pdo->prepare("UPDATE exam_eligibility SET eligibility_status='ineligible' WHERE examination_id=? AND student_id=? AND eligibility_status='pending' AND source<>'manual'")->execute([$paper['id'],$student]);$changed++;}
                if($changed){$this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(?,'exam.department_elective_registered','examination',?,?)")->execute([$actor,$paper['id'],json_encode(['cohort_students'=>count($desired),'changed_rows'=>$changed])]);}
                $counts['papers']++;$counts['eligibility_changes']+=$changed;
            }
            if($ownsTransaction)$this->pdo->commit();return $counts;
        }catch(Throwable $e){if($ownsTransaction&&$this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }
}
