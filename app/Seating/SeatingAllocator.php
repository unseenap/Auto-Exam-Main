<?php

declare(strict_types=1);

namespace App\Seating;

use PDO;
use RuntimeException;

final class SeatingAllocator
{
    public function __construct(private readonly PDO $pdo) {}

    public function generate(int $cycleId,string $date,int $shiftId,array $roomIds,int $userId,string $seed,array $options=[]): array
    {
        if(!$roomIds)throw new RuntimeException('Select at least one examination room.');
        $session=$this->pdo->prepare('SELECT COUNT(*) FROM exam_shifts s JOIN exam_calendar_dates d ON d.cycle_id=s.cycle_id WHERE s.id=? AND s.cycle_id=? AND d.exam_date=? AND d.is_exam_day=1');
        $session->execute([$shiftId,$cycleId,$date]);
        if(!(int)$session->fetchColumn())throw new RuntimeException('Select an enabled examination date and its cycle shift.');
        (new \App\Academic\DepartmentElectiveRegistrations($this->pdo))->synchronize($cycleId,$date,$shiftId);
        $pending=$this->pdo->prepare("SELECT COUNT(*) FROM exam_eligibility ee JOIN examinations e ON e.id=ee.examination_id WHERE e.cycle_id=? AND e.exam_date=? AND e.shift_id=? AND e.status<>'cancelled' AND ee.eligibility_status='pending'");$pending->execute([$cycleId,$date,$shiftId]);
        if((int)$pending->fetchColumn())throw new RuntimeException('This session has pending repeat/back-paper or special registrations. Department-assigned electives are registered for the whole class automatically.');
        $placeholders=implode(',',array_fill(0,count($roomIds),'?'));
        $eligible=(new SeatingRoster($this->pdo))->eligible($cycleId,$date,$shiftId);
        if(!$eligible)throw new RuntimeException('No eligible students were found for this examination session.');
        $seen=[];foreach($eligible as $student){
            if(isset($seen[$student['student_id']]))throw new RuntimeException('Student '.$student['normalized_roll_no'].' is eligible for two papers in this session. Correct the date sheet or paper registrations before generating seating.');
            $seen[$student['student_id']]=true;
        }
        $seats=$this->pdo->prepare("SELECT rs.id AS seat_id,rs.room_id,r.code AS room_code,r.usable_capacity,r.school_id,rs.row_no,rs.column_no,rs.sequence_no FROM room_seats rs JOIN rooms r ON r.id=rs.room_id
            WHERE rs.is_blocked=0 AND r.status='active' AND r.school_id IS NOT NULL AND EXISTS (SELECT 1 FROM schools sc WHERE sc.id=r.school_id AND sc.status='active') AND r.id IN ({$placeholders}) ORDER BY r.priority,r.code,rs.sequence_no");
        $seats->execute($roomIds);$available=[];$roomCounts=[];
        foreach($seats->fetchAll(PDO::FETCH_ASSOC) as $seat){$room=(int)$seat['room_id'];if(($roomCounts[$room]??0)>=(int)$seat['usable_capacity'])continue;$available[]=$seat;$roomCounts[$room]=($roomCounts[$room]??0)+1;}
        if(!$available)throw new RuntimeException('Selected rooms have no usable seats in an active school. Assign a school to each room first.');
        // Keep independent seat pools: spare capacity in another school cannot absorb a shortage.
        $schoolSeats=[];foreach($available as $seat)$schoolSeats[$seat['school_id']][]=$seat;
        $schoolStudents=[];foreach($eligible as $student)$schoolStudents[$student['school_id']][]=$student;
        $assigned=[];$unallocated=[];$assignmentSeats=[];
        foreach($schoolStudents as $schoolId=>$cohort){
            $groups=[];foreach($cohort as $student)$groups[$student['examination_id']][]=$student;
            ksort($groups);$ordered=[];
            while($groups){foreach(array_keys($groups) as $key){$ordered[]=array_shift($groups[$key]);if(!$groups[$key])unset($groups[$key]);}}
            $pool=$schoolSeats[$schoolId]??[];
            foreach($ordered as $index=>$student){
                if(isset($pool[$index])){$assigned[]=$student;$assignmentSeats[]=$pool[$index];}
                else $unallocated[]=$student;
            }
        }
        $rules=['mode'=>'round_robin_paper','school_isolation'=>true];$capacity=count($available);
        if(($options['mode']??'')==='paired_cohorts'){
            $plan=(new PairedCohortPlanner())->plan($eligible,$available,(array)($options['pairings']??[]));
            $assigned=$plan['assigned'];$assignmentSeats=$plan['assignmentSeats'];$unallocated=$plan['unallocated'];$rules=$plan['rules'];$capacity=$plan['capacity'];
        }
        $this->pdo->beginTransaction();try{
            $version=$this->pdo->prepare('SELECT COALESCE(MAX(version_no),0)+1 FROM seating_allocations WHERE cycle_id=:cycle AND exam_date=:date AND shift_id=:shift FOR UPDATE');
            $version->execute(['cycle'=>$cycleId,'date'=>$date,'shift'=>$shiftId]);$versionNo=(int)$version->fetchColumn();
            $header=$this->pdo->prepare("INSERT INTO seating_allocations(cycle_id,exam_date,shift_id,version_no,seed_value,rule_profile,status,generated_by,generated_at)
                VALUES(:cycle,:date,:shift,:version,:seed,:rules,'draft',:user,NOW())");
            $header->execute(['cycle'=>$cycleId,'date'=>$date,'shift'=>$shiftId,'version'=>$versionNo,'seed'=>$seed,
                'rules'=>json_encode($rules+['room_ids'=>$roomIds,'seat_order'=>'room_geometry','unallocated'=>count($unallocated)],JSON_THROW_ON_ERROR),'user'=>$userId]);
            $allocationId=(int)$this->pdo->lastInsertId();$insert=$this->pdo->prepare('INSERT INTO seating_assignments(allocation_id,examination_id,room_id,seat_id,student_id) VALUES(:allocation,:exam,:room,:seat,:student)');
            foreach($assigned as $index=>$student)$insert->execute(['allocation'=>$allocationId,'exam'=>$student['examination_id'],'room'=>$assignmentSeats[$index]['room_id'],'seat'=>$assignmentSeats[$index]['seat_id'],'student'=>$student['student_id']]);
            $pending=$this->pdo->prepare('INSERT INTO seating_unallocated(allocation_id,examination_id,student_id) VALUES(:allocation,:exam,:student)');foreach($unallocated as $student)$pending->execute(['allocation'=>$allocationId,'exam'=>$student['examination_id'],'student'=>$student['student_id']]);
            $this->pdo->commit();return ['allocation_id'=>$allocationId,'assigned'=>count($assigned),'unallocated'=>count($unallocated),'capacity'=>$capacity];
        }catch(\Throwable $e){$this->pdo->rollBack();throw $e;}
    }

    public function assertPairingSeat(int $allocationId,int $studentId,int $seatId): void
    {
        $q=$this->pdo->prepare('SELECT rule_profile FROM seating_allocations WHERE id=?');$q->execute([$allocationId]);$rules=json_decode((string)$q->fetchColumn(),true)?:[];
        $q=$this->pdo->prepare('SELECT room_id,column_no FROM room_seats WHERE id=?');$q->execute([$seatId]);$seat=$q->fetch(PDO::FETCH_ASSOC);
        if(!$seat||!PairedCohortPlanner::allows($rules,$studentId,(int)$seat['room_id'],(int)$seat['column_no']))throw new RuntimeException('This seat does not match the student’s saved branch/batch pairing and desk column.');
    }

    public function validate(int $allocationId): array
    {
        $checks=[];$queries=[
            'unallocated_students'=>"SELECT COUNT(*) FROM seating_unallocated WHERE allocation_id=:id AND resolved_at IS NULL",
            'over_capacity_rooms'=>"SELECT COUNT(*) FROM (SELECT sa.room_id FROM seating_assignments sa JOIN rooms r ON r.id=sa.room_id WHERE sa.allocation_id=:id GROUP BY sa.room_id,r.usable_capacity HAVING COUNT(*)>r.usable_capacity)x",
            'school_mismatches'=>"SELECT COUNT(*) FROM seating_assignments sa JOIN rooms r ON r.id=sa.room_id JOIN students st ON st.id=sa.student_id JOIN programmes p ON p.id=st.programme_id LEFT JOIN schools sc ON sc.id=r.school_id WHERE sa.allocation_id=:id AND (r.school_id IS NULL OR r.school_id<>p.school_id OR sc.status<>'active')",
            'seat_room_mismatches'=>"SELECT COUNT(*) FROM seating_assignments sa JOIN room_seats rs ON rs.id=sa.seat_id WHERE sa.allocation_id=:id AND sa.room_id<>rs.room_id",
            'inactive_rooms'=>"SELECT COUNT(*) FROM seating_assignments sa JOIN rooms r ON r.id=sa.room_id WHERE sa.allocation_id=:id AND r.status<>'active'",
            'duplicate_students'=>"SELECT COUNT(*) FROM (SELECT student_id FROM seating_assignments WHERE allocation_id=:id GROUP BY student_id HAVING COUNT(*)>1)x",
            'duplicate_seats'=>"SELECT COUNT(*) FROM (SELECT room_id,seat_id FROM seating_assignments WHERE allocation_id=:id GROUP BY room_id,seat_id HAVING COUNT(*)>1)x",
            'blocked_seats'=>"SELECT COUNT(*) FROM seating_assignments sa JOIN room_seats rs ON rs.id=sa.seat_id WHERE sa.allocation_id=:id AND rs.is_blocked=1",
            'ineligible_students'=>"SELECT COUNT(*) FROM seating_assignments sa LEFT JOIN exam_eligibility ee ON ee.examination_id=sa.examination_id AND ee.student_id=sa.student_id AND ee.eligibility_status='eligible' WHERE sa.allocation_id=:id AND ee.id IS NULL"];
        foreach($queries as $name=>$sql){$q=$this->pdo->prepare($sql);$q->execute(['id'=>$allocationId]);$checks[$name]=(int)$q->fetchColumn();}
        $checks['pairing_mismatches']=0;
        $q=$this->pdo->prepare('SELECT rule_profile FROM seating_allocations WHERE id=?');$q->execute([$allocationId]);$rules=json_decode((string)$q->fetchColumn(),true)?:[];
        if(($rules['mode']??'')==='paired_cohorts'){
            $q=$this->pdo->prepare('SELECT sa.student_id,sa.room_id,rs.column_no FROM seating_assignments sa JOIN room_seats rs ON rs.id=sa.seat_id WHERE sa.allocation_id=?');$q->execute([$allocationId]);
            foreach($q as $row)if(!PairedCohortPlanner::allows($rules,(int)$row['student_id'],(int)$row['room_id'],(int)$row['column_no']))$checks['pairing_mismatches']++;
        }
        $checks['valid']=array_sum($checks)===0;return $checks;
    }
}
