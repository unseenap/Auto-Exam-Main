<?php

declare(strict_types=1);

namespace App\Seating;

use PDO;
use RuntimeException;

final class SeatingAllocator
{
    public function __construct(private readonly PDO $pdo) {}

    public function generate(int $cycleId,string $date,int $shiftId,array $roomIds,int $userId,string $seed): array
    {
        if(!$roomIds)throw new RuntimeException('Select at least one examination room.');
        $placeholders=implode(',',array_fill(0,count($roomIds),'?'));
        $students=$this->pdo->prepare("SELECT DISTINCT s.id AS student_id,s.normalized_roll_no,p.code AS programme_code,e.id AS examination_id
            FROM examinations e JOIN exam_eligibility ee ON ee.examination_id=e.id AND ee.eligibility_status='eligible'
            JOIN students s ON s.id=ee.student_id JOIN programmes p ON p.id=s.programme_id
            WHERE e.cycle_id=? AND e.exam_date=? AND e.shift_id=? AND e.status<>'cancelled' ORDER BY p.code,s.normalized_roll_no");
        $students->execute([$cycleId,$date,$shiftId]);$eligible=$students->fetchAll(PDO::FETCH_ASSOC);
        if(!$eligible)throw new RuntimeException('No eligible students were found for this examination session.');
        $seats=$this->pdo->prepare("SELECT rs.id AS seat_id,rs.room_id,r.code AS room_code,rs.sequence_no FROM room_seats rs JOIN rooms r ON r.id=rs.room_id
            WHERE rs.is_blocked=0 AND r.status='active' AND r.id IN ({$placeholders}) ORDER BY r.priority,r.code,rs.sequence_no");
        $seats->execute($roomIds);$available=$seats->fetchAll(PDO::FETCH_ASSOC);
        if(!$available)throw new RuntimeException('Selected rooms have no usable seats.');
        $groups=[];foreach($eligible as $student)$groups[$student['programme_code']][]=$student;
        ksort($groups);$ordered=[];
        while($groups){foreach(array_keys($groups) as $key){if($groups[$key])$ordered[]=array_shift($groups[$key]);if(!$groups[$key])unset($groups[$key]);}}
        $assigned=array_slice($ordered,0,count($available));$unallocated=array_slice($ordered,count($available));
        $this->pdo->beginTransaction();try{
            $version=$this->pdo->prepare('SELECT COALESCE(MAX(version_no),0)+1 FROM seating_allocations WHERE cycle_id=:cycle AND exam_date=:date AND shift_id=:shift FOR UPDATE');
            $version->execute(['cycle'=>$cycleId,'date'=>$date,'shift'=>$shiftId]);$versionNo=(int)$version->fetchColumn();
            $header=$this->pdo->prepare("INSERT INTO seating_allocations(cycle_id,exam_date,shift_id,version_no,seed_value,rule_profile,status,generated_by,generated_at)
                VALUES(:cycle,:date,:shift,:version,:seed,:rules,'draft',:user,NOW())");
            $header->execute(['cycle'=>$cycleId,'date'=>$date,'shift'=>$shiftId,'version'=>$versionNo,'seed'=>$seed,
                'rules'=>json_encode(['mode'=>'round_robin_programme','room_ids'=>$roomIds,'seat_order'=>'room_geometry','unallocated'=>count($unallocated)]),'user'=>$userId]);
            $allocationId=(int)$this->pdo->lastInsertId();$insert=$this->pdo->prepare('INSERT INTO seating_assignments(allocation_id,examination_id,room_id,seat_id,student_id) VALUES(:allocation,:exam,:room,:seat,:student)');
            foreach($assigned as $index=>$student)$insert->execute(['allocation'=>$allocationId,'exam'=>$student['examination_id'],'room'=>$available[$index]['room_id'],'seat'=>$available[$index]['seat_id'],'student'=>$student['student_id']]);
            $pending=$this->pdo->prepare('INSERT INTO seating_unallocated(allocation_id,examination_id,student_id) VALUES(:allocation,:exam,:student)');foreach($unallocated as $student)$pending->execute(['allocation'=>$allocationId,'exam'=>$student['examination_id'],'student'=>$student['student_id']]);
            $this->pdo->commit();return ['allocation_id'=>$allocationId,'assigned'=>count($assigned),'unallocated'=>count($unallocated),'capacity'=>count($available)];
        }catch(\Throwable $e){$this->pdo->rollBack();throw $e;}
    }

    public function validate(int $allocationId): array
    {
        $checks=[];$queries=[
            'duplicate_students'=>"SELECT COUNT(*) FROM (SELECT student_id FROM seating_assignments WHERE allocation_id=:id GROUP BY student_id HAVING COUNT(*)>1)x",
            'duplicate_seats'=>"SELECT COUNT(*) FROM (SELECT room_id,seat_id FROM seating_assignments WHERE allocation_id=:id GROUP BY room_id,seat_id HAVING COUNT(*)>1)x",
            'blocked_seats'=>"SELECT COUNT(*) FROM seating_assignments sa JOIN room_seats rs ON rs.id=sa.seat_id WHERE sa.allocation_id=:id AND rs.is_blocked=1",
            'ineligible_students'=>"SELECT COUNT(*) FROM seating_assignments sa LEFT JOIN exam_eligibility ee ON ee.examination_id=sa.examination_id AND ee.student_id=sa.student_id AND ee.eligibility_status='eligible' WHERE sa.allocation_id=:id AND ee.id IS NULL"];
        foreach($queries as $name=>$sql){$q=$this->pdo->prepare($sql);$q->execute(['id'=>$allocationId]);$checks[$name]=(int)$q->fetchColumn();}
        $checks['valid']=array_sum($checks)===0;return $checks;
    }
}
