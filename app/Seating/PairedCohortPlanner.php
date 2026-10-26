<?php
declare(strict_types=1);
namespace App\Seating;
use RuntimeException;

/** One room has at most two chosen cohorts, each filling separate desk columns. */
final class PairedCohortPlanner
{
    public function plan(array $students,array $seats,array $pairings): array
    {
        if(!$pairings)throw new RuntimeException('Add at least one branch/batch pairing and choose its rooms.');
        $groups=SeatingRoster::groups($students);$queues=[];$studentGroups=[];
        foreach($students as $s){$queues[$s['group_key']][]=$s;$studentGroups[$s['student_id']]=$s['group_key'];}
        foreach($queues as &$queue)usort($queue,static fn(array $a,array $b):int=>strnatcmp($a['normalized_roll_no'],$b['normalized_roll_no']));unset($queue);
        $rooms=[];foreach($seats as $seat)$rooms[(int)$seat['room_id']][]=$seat;
        $used=[];$rules=[];
        foreach($pairings as $pair){
            if(!is_array($pair))throw new RuntimeException('Invalid branch/batch pairing.');
            $left=(string)($pair['left']??'');$right=(string)($pair['right']??'');
            if(!isset($groups[$left],$groups[$right])||$left===$right)throw new RuntimeException('Choose two different branch/batch groups from this examination session.');
            if($groups[$left]['school_id']!==$groups[$right]['school_id'])throw new RuntimeException('The two groups in a pairing must belong to the same school.');
            $roomIds=array_values(array_unique(array_map('intval',(array)($pair['room_ids']??[]))));
            if(!$roomIds)throw new RuntimeException('Choose at least one room for each pairing.');
            foreach($roomIds as $roomId){
                if(isset($used[$roomId]))throw new RuntimeException('A room can belong to only one pairing in this seating version.');
                if(!isset($rooms[$roomId]))throw new RuntimeException('A chosen room has no available seats.');
                if((int)$rooms[$roomId][0]['school_id']!==$groups[$left]['school_id'])throw new RuntimeException('Pairing rooms must belong to the selected groups’ school.');
                $used[$roomId]=true;
            }
            $rules[]=['left'=>$left,'right'=>$right,'room_ids'=>$roomIds];
        }
        $assigned=[];$assignmentSeats=[];$capacity=0;$roomColumns=[];
        foreach($rules as $pair){foreach($pair['room_ids'] as $roomId){
            $pool=$rooms[$roomId];usort($pool,static fn(array $a,array $b):int=>[(int)$a['column_no'],(int)$a['row_no']]<=>[(int)$b['column_no'],(int)$b['row_no']]);
            $capacity+=count($pool);$columns=array_values(array_unique(array_map(static fn(array $s):int=>(int)$s['column_no'],$pool)));sort($columns);foreach($columns as $i=>$column)$roomColumns[$roomId][$column]=$pair[$i%2===0?'left':'right'];
            foreach($pool as $seat){$key=$roomColumns[$roomId][(int)$seat['column_no']];
                // Do not fill an exhausted group's columns with another cohort.
                if(!empty($queues[$key])){$assigned[]=array_shift($queues[$key]);$assignmentSeats[]=$seat;}
            }
        }}
        $unallocated=[];foreach($queues as $queue)array_push($unallocated,...$queue);
        return compact('assigned','assignmentSeats','unallocated','capacity')+['rules'=>['mode'=>'paired_cohorts','school_isolation'=>true,'pairings'=>$rules,'room_columns'=>$roomColumns,'cohorts'=>$groups,'student_groups'=>$studentGroups]];
    }

    public static function allows(array $rules,int $studentId,int $roomId,int $column): bool
    {
        if(($rules['mode']??'')!=='paired_cohorts')return true;
        $key=$rules['student_groups'][$studentId]??null;
        foreach($rules['pairings']??[] as $pair)if(in_array($roomId,$pair['room_ids'],true))return $key!==null&&$key===($rules['room_columns'][$roomId][$column]??null);
        return false;
    }
}
