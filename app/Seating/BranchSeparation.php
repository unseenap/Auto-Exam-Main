<?php
declare(strict_types=1);
namespace App\Seating;

/** Side-by-side positions and saved usable desk partners; blocked seats are absent. */
final class BranchSeparation
{
    public static function neighbours(array $seats): array
    {
        $rooms=[];$result=[];
        foreach($seats as $seat)$rooms[(int)$seat['room_id']][]=$seat;
        $connect=static function(int $a,int $b)use(&$result):void{$result[$a][$b]=true;$result[$b][$a]=true;};
        foreach($rooms as $pool){
            $columns=[];$maxColumn=0;
            foreach($pool as $seat){$columns[(int)$seat['column_no']][(int)$seat['row_no']]=(int)$seat['seat_id'];$maxColumn=max($maxColumn,(int)$seat['column_no']);}
            $total=(int)($pool[0]['columns_count']??$maxColumn);
            $aisle=min($total-1,max(1,2*(int)ceil($total/4)));
            ksort($columns);
            foreach($columns as $column=>$rows)foreach($rows as $row=>$id)if($column!==$aisle&&isset($columns[$column+1][$row]))$connect($id,$columns[$column+1][$row]);
            // Keep the same usable-column desk pairing as the allocation engine.
            $usable=array_values($columns);
            for($i=0;$i+1<count($usable);$i+=2)foreach($usable[$i] as $row=>$id)if(isset($usable[$i+1][$row]))$connect($id,$usable[$i+1][$row]);
        }
        return $result;
    }
}
