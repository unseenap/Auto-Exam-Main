<?php
declare(strict_types=1);
namespace App\Seating;
use PDO;
use RuntimeException;

final class SeatingRoster
{
    public function __construct(private readonly PDO $pdo) {}

    public function period(int $cycleId): array
    {
        $q=$this->pdo->prepare('SELECT start_date,academic_year FROM exam_cycles WHERE id=?');$q->execute([$cycleId]);$cycle=$q->fetch(PDO::FETCH_ASSOC);
        if(!$cycle)throw new RuntimeException('Examination cycle not found.');
        $period=(new \App\Academic\AcademicRollover($this->pdo))->calendar()->period($cycle['start_date']);
        preg_match('/^(\d{4})/',$cycle['academic_year'],$m);$year=isset($m[1])?(int)$m[1]:$period['session_start_year'];
        return ['session'=>$year.'-'.($year+1),'term'=>$period['term']];
    }

    public function eligible(int $cycleId,?string $date=null,?int $shiftId=null): array
    {
        $period=$this->period($cycleId);
        $q=$this->pdo->prepare("SELECT DISTINCT s.id AS student_id,s.normalized_roll_no,s.roll_no_original,s.name AS student_name,p.id AS programme_id,p.name AS programme_name,p.code AS programme_code,p.school_id,sc.code AS school_code,COALESCE(t.batch_id,s.batch_id) AS batch_id,b.label AS batch_label,b.start_year,b.end_year,COALESCE(t.semester,s.semester) AS semester,e.id AS examination_id,e.exam_date,e.shift_id,c.code AS course_code,c.name AS course_name,e.category
            FROM examinations e JOIN exam_eligibility ee ON ee.examination_id=e.id AND ee.eligibility_status='eligible'
            JOIN students s ON s.id=ee.student_id
            LEFT JOIN student_term_enrollments t ON t.student_id=s.id AND t.academic_session=? AND t.term=?
            JOIN programmes p ON p.id=COALESCE(t.programme_id,s.programme_id) JOIN schools sc ON sc.id=p.school_id
            LEFT JOIN batches b ON b.id=COALESCE(t.batch_id,s.batch_id) JOIN courses c ON c.id=e.course_id
            WHERE e.cycle_id=? AND (? IS NULL OR e.exam_date=?) AND (? IS NULL OR e.shift_id=?) AND e.status<>'cancelled'
            ORDER BY p.code,b.start_year,semester,s.normalized_roll_no");
        $q->execute([$period['session'],$period['term'],$cycleId,$date,$date,$shiftId,$shiftId]);$rows=$q->fetchAll(PDO::FETCH_ASSOC);
        foreach($rows as &$row){$row['group_key']=self::key($row);$row['study_year']=(int)ceil((int)$row['semester']/2);}unset($row);return $rows;
    }

    public static function key(array $row): string
    {return (int)$row['programme_id'].':'.(int)($row['batch_id']??0).':'.(int)$row['semester'];}

    public static function groups(array $students): array
    {
        $groups=[];foreach($students as $s){$key=$s['group_key'];if(!isset($groups[$key]))$groups[$key]=[
            'key'=>$key,'school_id'=>(int)$s['school_id'],'school_code'=>$s['school_code'],'programme_id'=>(int)$s['programme_id'],
            'programme_code'=>$s['programme_code'],'programme_name'=>$s['programme_name'],'batch_id'=>$s['batch_id'],'batch_label'=>$s['batch_label'],
            'semester'=>(int)$s['semester'],'study_year'=>(int)ceil((int)$s['semester']/2),'label'=>$s['programme_code'].' · '.($s['batch_label']?:'No batch').' · Year '.(int)ceil((int)$s['semester']/2).' / Semester '.$s['semester'],'count'=>0];$groups[$key]['count']++;}return $groups;
    }
}
