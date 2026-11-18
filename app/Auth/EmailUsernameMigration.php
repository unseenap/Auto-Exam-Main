<?php
declare(strict_types=1);
namespace App\Auth;
use PDO;

final class EmailUsernameMigration
{
    public static function apply(PDO $pdo): void
    {
        $column=$pdo->query("SHOW COLUMNS FROM users LIKE 'username'")->fetch(PDO::FETCH_ASSOC);
        if($column&&preg_match('/varchar\((\d+)\)/i',$column['Type'],$match)&&(int)$match[1]<190){
            $pdo->exec('ALTER TABLE users MODIFY username VARCHAR(190) NOT NULL');
        }
    }
}
