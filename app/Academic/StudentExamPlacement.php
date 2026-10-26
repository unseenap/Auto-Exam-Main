<?php
declare(strict_types=1);
namespace App\Academic;
use PDO;
use RuntimeException;

/** Exam eligibility uses the placement for that cycle, not a later directory value. */
final class StudentExamPlacement
{
    public function __construct(private readonly PDO $pdo) {}

    public function cohort(int $cycleId,int $programme,?int $batch,int $semester,string $section):array
    {
        $q=$this->pdo->prepare('SELECT start_date,academic_year FROM exam_cycles WHERE id=?');$q->execute([$cycleId]);$cycle=$q->fetch(PDO::FETCH_ASSOC);
        if(!$cycle)throw new RuntimeException('Examination cycle not found.');
        $period=(new AcademicRollover($this->pdo))->calendar()->period($cycle['start_date']);
        // Retain legacy cycle labels, but use their explicit session when supplied.
        preg_match('/^(\d{4})/',$cycle['academic_year'],$m);$year=isset($m[1])?(int)$m[1]:$period['session_start_year'];$session=$year.'-'.($year+1);
        $q=$this->pdo->prepare("SELECT s.id,s.normalized_roll_no,COALESCE(t.semester,s.semester) AS semester,COALESCE(t.batch_id,s.batch_id) AS batch_id,COALESCE(t.section,s.section) AS section FROM students s LEFT JOIN student_term_enrollments t ON t.student_id=s.id AND t.academic_session=? AND t.term=? WHERE COALESCE(t.programme_id,s.programme_id)=? AND COALESCE(t.semester,s.semester)=? AND (? IS NULL OR COALESCE(t.batch_id,s.batch_id)=?) AND (?='ALL' OR COALESCE(t.section,s.section)=?) AND ((t.id IS NOT NULL AND t.placement_status IN ('active','held')) OR (t.id IS NULL AND s.status='active' AND NOT EXISTS(SELECT 1 FROM student_term_enrollments h WHERE h.student_id=s.id))) ORDER BY s.id");
        $q->execute([$session,$period['term'],$programme,$semester,$batch,$batch,$section,$section]);return $q->fetchAll(PDO::FETCH_ASSOC);
    }
}
