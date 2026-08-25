<?php

declare(strict_types=1);

namespace App\Rooms;

use PDO;

final class RoomSeatGenerator
{
    public function __construct(private readonly PDO $pdo) {}

    public function regenerate(int $roomId, int $rows, int $columns, string $order, array $blocked = []): int
    {
        $this->pdo->prepare('DELETE FROM room_seats WHERE room_id=:room')->execute(['room' => $roomId]);
        $coordinates = [];
        if ($order === 'row_major') {
            for ($row=1;$row<=$rows;$row++) for ($column=1;$column<=$columns;$column++) $coordinates[] = [$row,$column];
        } else {
            for ($column=1;$column<=$columns;$column++) for ($row=1;$row<=$rows;$row++) $coordinates[] = [$row,$column];
        }
        $insert = $this->pdo->prepare('INSERT INTO room_seats(room_id,seat_label,row_no,column_no,desk_group,desk_position,sequence_no,is_blocked)
            VALUES(:room,:label,:row,:column,:desk,:position,:sequence,:blocked)');
        $usable = 0;
        foreach ($coordinates as $index => [$row,$column]) {
            $key = $row . '-' . $column; $isBlocked = in_array($key, $blocked, true);
            $insert->execute(['room'=>$roomId,'label'=>sprintf('R%02d-C%02d',$row,$column),'row'=>$row,'column'=>$column,
                'desk'=>'DESK-' . (int) ceil($column/2),'position'=>(($column-1)%2)+1,'sequence'=>$index+1,'blocked'=>$isBlocked?1:0]);
            if (!$isBlocked) $usable++;
        }
        $this->pdo->prepare('UPDATE rooms SET physical_capacity=:physical,usable_capacity=:usable WHERE id=:id')
            ->execute(['physical'=>$rows*$columns,'usable'=>$usable,'id'=>$roomId]);
        return $usable;
    }
}

