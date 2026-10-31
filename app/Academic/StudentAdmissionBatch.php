<?php
declare(strict_types=1);
namespace App\Academic;

use PDO;

final class StudentAdmissionBatch
{
    public function __construct(private readonly PDO $pdo) {}

    public function resolve(int $programmeId,string $prefix,string $admissionType='regular'):?int
    {
        if(!preg_match('/^(\d{2})/',$prefix,$match))return null;
        $start=2000+(int)$match[1]-($admissionType==='lateral'?1:0);
        $q=$this->pdo->prepare('SELECT code,duration_semesters FROM programmes WHERE id=?');$q->execute([$programmeId]);$programme=$q->fetch(PDO::FETCH_ASSOC);if(!$programme)return null;
        $end=$start+max(1,(int)ceil((int)$programme['duration_semesters']/2));
        // Reuse the regular class even if its batch has a custom display label.
        $q=$this->pdo->prepare('SELECT id FROM batches WHERE programme_id=? AND start_year=? AND end_year=? ORDER BY id LIMIT 1');$q->execute([$programmeId,$start,$end]);$existing=$q->fetchColumn();if($existing)return (int)$existing;
        $label=$programme['code'].' '.$start.'-'.$end;
        $this->pdo->prepare("INSERT INTO batches(programme_id,label,start_year,end_year,status) VALUES(?,?,?,?,'active') ON DUPLICATE KEY UPDATE start_year=VALUES(start_year),end_year=VALUES(end_year)")->execute([$programmeId,$label,$start,$end]);
        $q=$this->pdo->prepare('SELECT id FROM batches WHERE programme_id=? AND label=?');$q->execute([$programmeId,$label]);return (int)$q->fetchColumn()?:null;
    }
}
