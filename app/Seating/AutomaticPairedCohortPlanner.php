<?php
declare(strict_types=1);
namespace App\Seating;

use RuntimeException;

/** Reserves equal cohort counts, then fills shared desk pairs in priority order. */
final class AutomaticPairedCohortPlanner
{
    public function plan(array $students,array $seats,array $pairings,bool $seatRemaining=false,bool $alternateUnmatched=false): array
    {
        if(!$pairings&&!$seatRemaining&&!$alternateUnmatched)throw new RuntimeException('Add a pairing or choose alternating-column seating for unmatched groups.');
        $groups=SeatingRoster::groups($students);$queues=[];$studentGroups=[];$studentPapers=[];
        foreach($students as $student){$queues[$student['group_key']][]=$student;$studentGroups[$student['student_id']]=$student['group_key'];$studentPapers[$student['student_id']]=SeatingRoster::paperKey($student);if($studentPapers[$student['student_id']]==='')throw new RuntimeException('Every eligible student needs an identified examination paper before generating seating.');}
        foreach($queues as &$queue)usort($queue,static fn(array $a,array $b):int=>strnatcmp($a['normalized_roll_no'],$b['normalized_roll_no']));unset($queue);
        $rooms=[];
        // Input rooms already follow the saved room priority and code.
        foreach($seats as $seat)$rooms[(int)$seat['room_id']][]=$seat;
        $slots=[];$used=[];$seatGroups=[];$assigned=[];$assignmentSeats=[];$unallocated=[];$saved=[];$convertedPairings=[];
        $neighbours=BranchSeparation::neighbours($seats);$seatBranches=[];$seatPapers=[];
        $safe=static function(array $student,array $seat)use(&$seatBranches,&$seatPapers,$neighbours,$groups):bool{
            // Cohort paper sets match the live preview, including mixed electives.
            foreach($neighbours[(int)$seat['seat_id']]??[] as $id=>$_)if(($seatBranches[$id]??null)===(int)$student['programme_id']||array_intersect($groups[$student['group_key']]['paper_ids'],$seatPapers[$id]??[]))return false;
            return true;
        };
        foreach($rooms as $roomId=>$pool){
            $columns=[];foreach($pool as $seat)$columns[(int)$seat['column_no']][(int)$seat['row_no']]=$seat;
            ksort($columns);$columns=array_values($columns);
            for($i=0;$i+1<count($columns);$i+=2){
                ksort($columns[$i]);
                foreach($columns[$i] as $row=>$seat)if(isset($columns[$i+1][$row]))$slots[$roomId][]=[$seat,$columns[$i+1][$row]];
            }
        }
        $place=static function(array $student,array $seat)use(&$used,&$seatGroups,&$assigned,&$assignmentSeats,&$seatBranches,&$seatPapers,$groups):void{
            $seatBranches[(int)$seat['seat_id']]=(int)$student['programme_id'];
            $seatPapers[(int)$seat['seat_id']]=$groups[$student['group_key']]['paper_ids'];
            $used[(int)$seat['seat_id']]=true;$seatGroups[(int)$seat['seat_id']]=$student['group_key'];$assigned[]=$student;$assignmentSeats[]=$seat;
        };
        foreach($pairings as $pair){
            if(!is_array($pair))throw new RuntimeException('Invalid branch/batch pairing.');
            $left=(string)($pair['left']??'');$right=(string)($pair['right']??'');
            if(!isset($groups[$left],$groups[$right]))throw new RuntimeException('Choose branch/batch groups from this examination session.');
            $school=$groups[$left]['school_id'];
            if($school!==$groups[$right]['school_id'])throw new RuntimeException('The two groups in a pairing must belong to the same school.');
            $sameBranch=$groups[$left]['programme_id']===$groups[$right]['programme_id'];$sharedPaper=(bool)array_intersect($groups[$left]['paper_ids'],$groups[$right]['paper_ids']);
            if($sameBranch||$sharedPaper){
                if($alternateUnmatched){$convertedPairings[]=['left'=>$left,'right'=>$right,'reason'=>$sameBranch?'same_branch':'shared_paper'];continue;}
                throw new RuntimeException($sameBranch?'These groups are from the same branch. Choose “Alternate columns · partner stays empty” to generate spaced seating, or select a different branch.':'These groups share a paper today. Choose “Alternate columns · partner stays empty” or select groups with different papers.');
            }
            $count=min(count($queues[$left]),count($queues[$right]));
            if(!$count)throw new RuntimeException('A selected group has no students remaining for this pairing. Remove it or choose a remaining group.');
            $preferred=array_values(array_unique(array_map('intval',(array)($pair['room_ids']??[]))));
            foreach($preferred as $roomId)if(!isset($rooms[$roomId])||(int)$rooms[$roomId][0]['school_id']!==$school)throw new RuntimeException('Preferred rooms must have usable seats in the selected groups’ school.');
            $order=$preferred;
            foreach($rooms as $roomId=>$pool)if((int)$pool[0]['school_id']===$school&&!in_array($roomId,$order,true))$order[]=$roomId;
            // Reserve the matched students even when physical room capacity is short.
            // They remain in this pair's unallocated list, rather than being paired twice.
            $a=array_splice($queues[$left],0,$count);$b=array_splice($queues[$right],0,$count);$n=0;$actual=[];
            foreach($order as $roomId)foreach($slots[$roomId]??[] as [$seatA,$seatB]){
                if($n===$count)break;
                if(isset($used[(int)$seatA['seat_id']])||isset($used[(int)$seatB['seat_id']]))continue;
                if(!$safe($a[$n],$seatA)||!$safe($b[$n],$seatB)){
                    if(!$safe($a[$n],$seatB)||!$safe($b[$n],$seatA))continue;
                    [$seatA,$seatB]=[$seatB,$seatA];
                }
                $place($a[$n],$seatA);$place($b[$n],$seatB);$n++;$actual[$roomId]=true;
            }
            array_push($unallocated,...array_slice($a,$n),...array_slice($b,$n));
            $saved[]=['left'=>$left,'right'=>$right,'room_ids'=>array_keys($actual),'preferred_room_ids'=>$preferred,'matched_count'=>$count,'seated_pairs'=>$n];
        }
        $emptyPartnerColumns=[];
        if($alternateUnmatched){
            // Whole partner columns stay empty, even when several unmatched groups remain.
            $fallback=[];
            foreach($rooms as $roomId=>$pool){
                $columns=[];$occupiedColumns=[];
                foreach($pool as $seat){$columns[(int)$seat['column_no']][]=$seat;if(isset($used[(int)$seat['seat_id']]))$occupiedColumns[(int)$seat['column_no']]=true;}
                ksort($columns);$numbers=array_keys($columns);
                for($i=0;$i<count($numbers);$i+=2){
                    $target=$numbers[$i];$partner=$numbers[$i+1]??null;
                    if(isset($occupiedColumns[$target])||($partner!==null&&isset($occupiedColumns[$partner])))continue;
                    usort($columns[$target],static fn(array $a,array $b):int=>(int)$a['row_no']<=>(int)$b['row_no']);
                    foreach($columns[$target] as $seat)$fallback[$roomId][]=['seat'=>$seat,'partner'=>$partner];
                }
            }
            foreach($queues as $key=>$queue){
                $n=0;$actual=[];
                foreach($fallback as $roomId=>$candidates){
                    if((int)$rooms[$roomId][0]['school_id']!==$groups[$key]['school_id'])continue;
                    foreach($candidates as $candidate){$seat=$candidate['seat'];if(!isset($queue[$n]))break;if(isset($used[(int)$seat['seat_id']])||!$safe($queue[$n],$seat))continue;
                        $place($queue[$n++],$seat);$actual[$roomId]=true;if($candidate['partner']!==null)$emptyPartnerColumns[$roomId][(int)$candidate['partner']]=true;
                    }
                }
                $queues[$key]=array_slice($queue,$n);
                if($n)$saved[]=['left'=>$key,'right'=>$key,'room_ids'=>array_keys($actual),'single_remaining'=>true,'empty_partner'=>true,'matched_count'=>$n,'seated_pairs'=>0];
            }
        }elseif($seatRemaining){
            $bySchool=[];foreach($queues as $key=>$queue)if($queue)$bySchool[$groups[$key]['school_id']][]=$key;
            foreach($bySchool as $school=>$keys){
                // A single remaining cohort in each school may use any vacant seat.
                if(count($keys)!==1)continue;
                $key=$keys[0];$n=0;$actual=[];
                foreach($rooms as $roomId=>$pool){
                    if((int)$pool[0]['school_id']!==(int)$school)continue;
                    usort($pool,static fn(array $a,array $b):int=>[(int)$a['column_no'],(int)$a['row_no']]<=>[(int)$b['column_no'],(int)$b['row_no']]);
                    foreach($pool as $seat){if(!isset($queues[$key][$n]))break;if(isset($used[(int)$seat['seat_id']])||!$safe($queues[$key][$n],$seat))continue;$place($queues[$key][$n++],$seat);$actual[$roomId]=true;}
                }
                $queues[$key]=array_slice($queues[$key],$n);
                if($n)$saved[]=['left'=>$key,'right'=>$key,'room_ids'=>array_keys($actual),'single_remaining'=>true,'matched_count'=>$n,'seated_pairs'=>0];
            }
        }
        foreach($queues as $queue)array_push($unallocated,...$queue);
        return compact('assigned','assignmentSeats','unallocated')+['capacity'=>count($seats),'rules'=>['mode'=>'paired_cohorts','allocation_mode'=>'automatic_pairs','day_paper_separation'=>true,'branch_separation'=>true,'paper_separation'=>true,'student_papers'=>$studentPapers,'seat_remaining'=>$seatRemaining,'alternate_unmatched'=>$alternateUnmatched,'converted_pairings'=>$convertedPairings,'empty_partner_columns'=>$emptyPartnerColumns,'school_isolation'=>true,'pairings'=>$saved,'seat_groups'=>$seatGroups,'cohorts'=>$groups,'student_groups'=>$studentGroups]];
    }
}
