<?php
declare(strict_types=1);
namespace App\Faculty;

use PDO;
use RuntimeException;

final class FacultyEmailMigration
{
    public static function apply(PDO $pdo): void
    {
        if(!$pdo->query("SHOW INDEX FROM faculty WHERE Key_name='uq_faculty_email'")->fetch()){
            $rows=$pdo->query('SELECT id,email FROM faculty')->fetchAll(PDO::FETCH_ASSOC);$seen=[];$updates=[];
            foreach($rows as $row){
                $email=mb_strtolower(trim((string)$row['email']));
                if($email!==''&&isset($seen[$email]))throw new RuntimeException('Existing faculty records share an email address. Resolve duplicate emails before installing the unique email index. No records were changed.');
                if($email!=='')$seen[$email]=true;
                $updates[]=[$email!==''?$email:null,(int)$row['id']];
            }
            $pdo->beginTransaction();
            try{
                $update=$pdo->prepare('UPDATE faculty SET email=? WHERE id=?');foreach($updates as $values)$update->execute($values);
                $pdo->commit();
            }catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();throw $e;}
            $pdo->exec('ALTER TABLE faculty ADD UNIQUE KEY uq_faculty_email (email)');
        }
        if($pdo->query("SHOW INDEX FROM faculty WHERE Key_name='uq_faculty_mobile'")->fetch())$pdo->exec('ALTER TABLE faculty DROP INDEX uq_faculty_mobile');
    }
}
