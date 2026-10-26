<?php
declare(strict_types=1);
namespace App\Seating;
use PDO;
use RuntimeException;

/** Shared physical room model for the screen, print view and Excel export. */
final class SeatingPlanDocument
{
    public function __construct(private readonly PDO $pdo) {}

    public function build(int $allocationId): array
    {
        $q=$this->pdo->prepare('SELECT a.*,c.name AS cycle_name,c.exam_type,s.name AS shift_name,s.start_time,s.end_time FROM seating_allocations a JOIN exam_cycles c ON c.id=a.cycle_id JOIN exam_shifts s ON s.id=a.shift_id WHERE a.id=?');$q->execute([$allocationId]);$allocation=$q->fetch(PDO::FETCH_ASSOC);
        if(!$allocation)throw new RuntimeException('Seating allocation not found.');
        $rules=json_decode($allocation['rule_profile'],true)?:[];$period=(new SeatingRoster($this->pdo))->period((int)$allocation['cycle_id']);
        $q=$this->pdo->prepare("SELECT a.*,st.roll_no_original,st.normalized_roll_no,p.id AS programme_id,p.name AS programme_name,p.code AS programme_code,COALESCE(t.batch_id,st.batch_id) AS batch_id,b.label AS batch_label,COALESCE(t.semester,st.semester) AS semester,c.code AS course_code,c.name AS course_name,e.category FROM seating_assignments a JOIN students st ON st.id=a.student_id LEFT JOIN student_term_enrollments t ON t.student_id=st.id AND t.academic_session=? AND t.term=? JOIN programmes p ON p.id=COALESCE(t.programme_id,st.programme_id) LEFT JOIN batches b ON b.id=COALESCE(t.batch_id,st.batch_id) JOIN examinations e ON e.id=a.examination_id JOIN courses c ON c.id=e.course_id WHERE a.allocation_id=? ORDER BY st.normalized_roll_no");
        $q->execute([$period['session'],$period['term'],$allocationId]);$students=$q->fetchAll(PDO::FETCH_ASSOC);$assigned=[];
        foreach($students as $student){
            $key=$rules['student_groups'][$student['student_id']]??SeatingRoster::key($student);$student['group_key']=$key;
            if(isset($rules['cohorts'][$key]))foreach(['programme_name','programme_code','batch_label','semester'] as $field)$student[$field]=$rules['cohorts'][$key][$field];
            $assigned[(int)$student['seat_id']]=$student;
        }
        $q=$this->pdo->prepare("SELECT DISTINCT r.*,sc.code AS school_code,COALESCE(NULLIF(sc.short_name,''),sc.code) AS school_label FROM rooms r LEFT JOIN schools sc ON sc.id=r.school_id JOIN seating_assignments a ON a.room_id=r.id WHERE a.allocation_id=? ORDER BY r.priority,r.code");$q->execute([$allocationId]);$rooms=$q->fetchAll(PDO::FETCH_ASSOC);
        foreach($rooms as &$room){
            $q=$this->pdo->prepare('SELECT * FROM room_seats WHERE room_id=? ORDER BY row_no,column_no');$q->execute([$room['id']]);$room['grid']=[];$summary=[];$room['assigned_count']=0;
            foreach($q as $seat){$student=$assigned[(int)$seat['id']]??null;$room['grid'][(int)$seat['row_no']][(int)$seat['column_no']]=['seat'=>$seat,'student'=>$student];
                if(!$student)continue;$room['assigned_count']++;
                $key=$student['group_key'].':'.$student['examination_id'];
                if(!isset($summary[$key]))$summary[$key]=['programme_name'=>$student['programme_name'],'programme_code'=>$student['programme_code'],'batch_label'=>$student['batch_label'],'semester'=>(int)$student['semester'],'category'=>$student['category'],'course_code'=>$student['course_code'],'course_name'=>$student['course_name'],'rolls'=>[],'count'=>0];
                $summary[$key]['rolls'][]=$student['roll_no_original'];$summary[$key]['count']++;
            }
            foreach($summary as &$item){$item['roll_detail']=self::rollRanges($item['rolls']);$item['detail']=$item['programme_name'].' · '.($item['batch_label']?:'Batch not recorded').' · '.self::ordinal($item['semester']).' Semester ('.$item['roll_detail'].') '.$item['course_code'].' '.$item['course_name'].($item['category']!=='regular'?' ['.str_replace('_',' ',$item['category']).']':'');}unset($item);
            $room['summary']=array_values($summary);$room['aisle_after']=min((int)$room['columns_count']-1,max(1,2*(int)ceil((int)$room['columns_count']/4)));
            if((int)$room['columns_count']===1)$room['aisle_after']=1;
        }unset($room);
        $allocation['session_label']=$allocation['shift_name'].(stripos($allocation['shift_name'],'shift')===false?' Shift':'').' ('.date('g:i a',strtotime($allocation['start_time'])).' - '.date('g:i a',strtotime($allocation['end_time'])).')    '.date('d-m-Y',strtotime($allocation['exam_date']));
        return compact('allocation','rooms','rules');
    }

    public static function ordinal(int $number): string
    {return $number.((($number%100)>=11&&($number%100)<=13)?'th':([1=>'st',2=>'nd',3=>'rd'][$number%10]??'th'));}

    public static function rollRanges(array $rolls): string
    {
        usort($rolls,'strnatcmp');$parts=[];$start=null;$last=null;
        $flush=static function()use(&$parts,&$start,&$last):void{if($start!==null)$parts[]=$start===$last?$start:$start.' to '.$last;};
        foreach($rolls as $roll){$consecutive=false;if($last!==null&&preg_match('/^(.*?)(\d+)$/',$last,$a)&&preg_match('/^(.*?)(\d+)$/',$roll,$b))$consecutive=$a[1]===$b[1]&&strlen($a[2])===strlen($b[2])&&(int)$b[2]===(int)$a[2]+1;
            if(!$consecutive){$flush();$start=$roll;}$last=$roll;
        }$flush();return implode(', ',$parts);
    }
}
