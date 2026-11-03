<?php
declare(strict_types=1);
namespace App\Faculty;
use PDO;
final class FacultyPortalMigration
{
    public static function apply(PDO $pdo):void
    {
        if($pdo->query("SHOW TABLES LIKE 'faculty_portal_settings'")->fetchColumn())return;
        $pdo->exec((string)file_get_contents(dirname(__DIR__,2).'/database/faculty-portal.sql'));
    }
}
