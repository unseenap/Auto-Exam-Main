<?php
declare(strict_types=1);
namespace App\Faculty;
use PDO;
final class FacultyPortalMigration
{
    public static function apply(PDO $pdo):void
    {
        $directory=dirname(__DIR__,2).'/database/';
        if(!$pdo->query("SHOW TABLES LIKE 'faculty_portal_settings'")->fetchColumn()){
            $pdo->exec((string)file_get_contents($directory.'faculty-portal.sql'));
        }
        if(!$pdo->query("SHOW TABLES LIKE 'attendance_ufm'")->fetchColumn()){
            $pdo->exec((string)file_get_contents($directory.'attendance-ufm.sql'));
        }
    }
}
