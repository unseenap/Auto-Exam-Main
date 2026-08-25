<?php

declare(strict_types=1);

$root = dirname(__DIR__);
$source = $root . '/storage/demo-data/large-multi-branch/gbu_rooms_proposed_demo.csv';
$output = $root . '/database/infinityfree_room_seed.sql';

function sqlString(?string $value): string
{
    if ($value === null || trim($value) === '') return 'NULL';
    return "'" . str_replace("'", "''", trim($value)) . "'";
}

/** @return list<array<string,string>> */
function csvRows(string $path): array
{
    $handle = fopen($path, 'rb');
    if ($handle === false) throw new RuntimeException("Unable to read {$path}");
    $headers = fgetcsv($handle);
    if ($headers === false) throw new RuntimeException("Room CSV has no header.");
    $rows = [];
    while (($values = fgetcsv($handle)) !== false) {
        if ($values === [null] || $values === []) continue;
        $values = array_pad($values, count($headers), '');
        $rows[] = array_combine($headers, array_slice($values, 0, count($headers)));
    }
    fclose($handle);
    return $rows;
}

/** @return array<string,true> */
function blockedSeats(string $value, int $rows, int $columns): array
{
    $blocked = [];
    foreach (preg_split('/[|;,]+/', strtoupper(trim($value)), -1, PREG_SPLIT_NO_EMPTY) ?: [] as $token) {
        $token = trim($token);
        if (!preg_match('/^(?:R)?0*(\d+)(?:\s*[-:]\s*C?0*(\d+))$/', $token, $match)) {
            throw new RuntimeException("Invalid disabled seat: {$token}");
        }
        $row = (int)$match[1];
        $column = (int)$match[2];
        if ($row < 1 || $row > $rows || $column < 1 || $column > $columns) {
            throw new RuntimeException("Disabled seat outside room layout: {$token}");
        }
        $blocked["{$row}-{$column}"] = true;
    }
    return $blocked;
}

$rooms = csvRows($source);
$sql = "-- GBU hosted room and seat-layout seed for phpMyAdmin\n";
$sql .= "-- Repeatable: rooms are updated by room code and their seats are regenerated.\n";
$sql .= "SET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS = 0;\nSTART TRANSACTION;\n\n";
$totalSeats = 0;
$totalBlocked = 0;

foreach ($rooms as $room) {
    $code = strtoupper(trim($room['Room Code']));
    $rows = (int)$room['Rows'];
    $columns = (int)$room['Columns'];
    $order = strtolower(trim($room['Seat Order'])) ?: 'column_major';
    $status = strtolower(trim($room['Status'])) ?: 'active';
    if ($code === '' || $rows < 1 || $columns < 1) throw new RuntimeException("Invalid room geometry for {$code}");
    if (!in_array($order, ['row_major','column_major'], true)) throw new RuntimeException("Invalid seat order for {$code}");
    if (!in_array($status, ['active','inactive','maintenance'], true)) throw new RuntimeException("Invalid room status for {$code}");
    $blocked = blockedSeats($room['Disabled Seat Numbers'], $rows, $columns);
    $physical = $rows * $columns;
    $usable = $physical - count($blocked);
    $totalSeats += $physical;
    $totalBlocked += count($blocked);

    $values = [
        sqlString($code), sqlString($room['Building']), sqlString($room['Floor']), (string)$rows, (string)$columns,
        (string)$physical, (string)$usable, sqlString($order), (string)((int)$room['Priority'] ?: 100),
        sqlString($status), sqlString($room['Notes'])
    ];
    $sql .= "INSERT INTO rooms (code,building,floor,rows_count,columns_count,physical_capacity,usable_capacity,seat_order,priority,status,notes) VALUES\n";
    $sql .= '(' . implode(',', $values) . ")\n";
    $sql .= "ON DUPLICATE KEY UPDATE building=VALUES(building),floor=VALUES(floor),rows_count=VALUES(rows_count),columns_count=VALUES(columns_count),physical_capacity=VALUES(physical_capacity),usable_capacity=VALUES(usable_capacity),seat_order=VALUES(seat_order),priority=VALUES(priority),status=VALUES(status),notes=VALUES(notes);\n";
    $sql .= "DELETE FROM room_seats WHERE room_id=(SELECT id FROM rooms WHERE code=" . sqlString($code) . " LIMIT 1);\n";

    $coordinates = [];
    if ($order === 'row_major') {
        for ($row = 1; $row <= $rows; $row++) for ($column = 1; $column <= $columns; $column++) $coordinates[] = [$row,$column];
    } else {
        for ($column = 1; $column <= $columns; $column++) for ($row = 1; $row <= $rows; $row++) $coordinates[] = [$row,$column];
    }
    $seatValues = [];
    foreach ($coordinates as $index => [$row,$column]) {
        $seatValues[] = '(' . implode(',', [
            "(SELECT id FROM rooms WHERE code=" . sqlString($code) . " LIMIT 1)",
            sqlString(sprintf('R%02d-C%02d', $row, $column)), (string)$row, (string)$column,
            sqlString('DESK-' . (int)ceil($column / 2)), (string)((($column - 1) % 2) + 1),
            (string)($index + 1), isset($blocked["{$row}-{$column}"]) ? '1' : '0'
        ]) . ')';
    }
    $sql .= "INSERT INTO room_seats (room_id,seat_label,row_no,column_no,desk_group,desk_position,sequence_no,is_blocked) VALUES\n";
    $sql .= implode(",\n", $seatValues) . ";\n\n";
}

$sql .= "COMMIT;\nSET FOREIGN_KEY_CHECKS = 1;\n\n";
$sql .= "-- Import verification\n";
$sql .= "SELECT COUNT(*) AS demo_rooms FROM rooms WHERE notes='Proposed demo room - verify with GBU';\n";
$sql .= "SELECT COUNT(*) AS generated_seats FROM room_seats rs JOIN rooms r ON r.id=rs.room_id WHERE r.notes='Proposed demo room - verify with GBU';\n";
$sql .= "SELECT COUNT(*) AS disabled_seats FROM room_seats rs JOIN rooms r ON r.id=rs.room_id WHERE r.notes='Proposed demo room - verify with GBU' AND rs.is_blocked=1;\n";
$sql .= "SELECT SUM(physical_capacity) AS physical_capacity,SUM(usable_capacity) AS usable_capacity FROM rooms WHERE notes='Proposed demo room - verify with GBU';\n";

file_put_contents($output, $sql);
fwrite(STDOUT, "Created {$output}\nRooms: " . count($rooms) . "\nSeats: {$totalSeats}\nDisabled: {$totalBlocked}\nUsable: " . ($totalSeats - $totalBlocked) . "\n");

