<?php
declare(strict_types=1);
namespace App\Rooms;
use PDO;

final class RoomSchoolMigration
{
    public static function apply(PDO $pdo): void
    {
        if(!$pdo->query("SHOW COLUMNS FROM rooms LIKE 'school_id'")->fetchColumn()){
            $pdo->exec('ALTER TABLE rooms ADD COLUMN school_id BIGINT UNSIGNED NULL AFTER id, ADD INDEX idx_rooms_school_status (school_id,status), ADD CONSTRAINT fk_rooms_school FOREIGN KEY (school_id) REFERENCES schools(id)');
        }
    }
}
