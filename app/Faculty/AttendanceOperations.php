<?php

declare(strict_types=1);

namespace App\Faculty;

use DateTimeImmutable;
use DateTimeZone;
use PDO;
use Throwable;

final class AttendanceOperations
{
    public function __construct(private readonly PDO $pdo, private readonly ?DateTimeImmutable $clock = null) {}

    private function rows(string $sql, array $arguments = []): array
    {
        $query = $this->pdo->prepare($sql);
        $query->execute($arguments);
        return $query->fetchAll(PDO::FETCH_ASSOC);
    }

    /** Persist due locks on reads and before writes. Write guards also check the deadline. */
    public function expire(?int $allocation = null, ?int $room = null): void
    {
        if ($this->pdo->inTransaction()) throw new \LogicException('Expire attendance before starting an edit transaction.');
        $now = ($this->clock ?? new DateTimeImmutable('now', new DateTimeZone('Asia/Kolkata')))
            ->setTimezone(new DateTimeZone('Asia/Kolkata'))->format('Y-m-d H:i:s');
        $end = 'DATE_ADD(TIMESTAMP(sa.exam_date,es.end_time),INTERVAL IF(es.end_time<es.start_time,1,0) DAY)';
        $this->pdo->beginTransaction();
        try {
            $this->pdo->prepare("INSERT IGNORE INTO faculty_room_sessions(allocation_id,room_id)
                SELECT DISTINCT sa.id,x.room_id FROM seating_allocations sa
                JOIN exam_shifts es ON es.id=sa.shift_id JOIN seating_assignments x ON x.allocation_id=sa.id
                WHERE sa.status='published' AND {$end}<=? AND (? IS NULL OR sa.id=?) AND (? IS NULL OR x.room_id=?)")
                ->execute([$now,$allocation,$allocation,$room,$room]);
            $due = $this->rows("SELECT fs.id,COALESCE(fs.reopened_until,{$end}) AS deadline,
                (SELECT COUNT(*) FROM attendance a WHERE a.allocation_id=fs.allocation_id AND a.room_id=fs.room_id AND a.status='unmarked') AS unmarked
                FROM faculty_room_sessions fs JOIN seating_allocations sa ON sa.id=fs.allocation_id
                JOIN exam_shifts es ON es.id=sa.shift_id
                WHERE sa.status='published' AND fs.status='draft'
                AND COALESCE(fs.reopened_until,{$end})<=?
                AND (? IS NULL OR sa.id=?) AND (? IS NULL OR fs.room_id=?) ORDER BY fs.id FOR UPDATE",
                [$now,$allocation,$allocation,$room,$room]);
            $lock = $this->pdo->prepare("UPDATE faculty_room_sessions SET status='submitted',submitted_by=NULL,
                submitted_at=?,revision=revision+1,reopened_until=NULL WHERE id=? AND status='draft'");
            $audit = $this->pdo->prepare("INSERT INTO audit_logs(action,entity_type,entity_id,new_values)
                VALUES('attendance.auto_locked','faculty_room_session',?,?)");
            foreach ($due as $session) {
                $lock->execute([$session['deadline'],$session['id']]);
                $audit->execute([$session['id'],json_encode(['locked_at'=>$session['deadline'],'unmarked'=>(int)$session['unmarked']],JSON_THROW_ON_ERROR)]);
            }
            $this->pdo->commit();
        } catch (Throwable $error) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            throw $error;
        }
    }

    public function rooms(?int $allocation = null): array
    {
        $this->expire($allocation);
        $today=($this->clock??new DateTimeImmutable('now',new DateTimeZone('Asia/Kolkata')))
            ->setTimezone(new DateTimeZone('Asia/Kolkata'))->format('Y-m-d');
        return $this->rows("SELECT totals.*,sa.cycle_id,sa.exam_date,ec.name AS cycle_name,es.name AS shift_name,
            r.code AS room_code,fs.status AS submission_status,COALESCE(fs.revision,0) AS revision,
            fs.submitted_at,fs.submitted_by,COALESCE(submitter.name,'Automatic exam-end lock') AS locked_by,
            COALESCE(fs.edited_at,totals.latest_marked_at) AS updated_at,editor.name AS updated_by,
            (SELECT GROUP_CONCAT(f.name ORDER BY f.name SEPARATOR ', ') FROM invigilation_allocations ia
                JOIN faculty f ON f.id=ia.faculty_id WHERE ia.cycle_id=sa.cycle_id AND ia.exam_date=sa.exam_date
                AND ia.shift_id=sa.shift_id AND ia.room_id=totals.room_id
                AND ia.duty_status IN ('assigned','confirmed','completed')) AS teachers
            FROM (
                SELECT x.allocation_id,x.room_id,COUNT(*) AS students,
                    SUM(COALESCE(a.status,'unmarked') NOT IN ('unmarked','absent')) AS present,
                    SUM(a.status='absent') AS absent,SUM(a.status='unfair_means') AS ufm,
                    SUM(COALESCE(a.status,'unmarked')='unmarked') AS unmarked,MAX(a.marked_at) AS latest_marked_at
                FROM seating_assignments x LEFT JOIN attendance a ON a.allocation_id=x.allocation_id
                    AND a.examination_id=x.examination_id AND a.student_id=x.student_id AND a.room_id=x.room_id
                GROUP BY x.allocation_id,x.room_id
            ) totals JOIN seating_allocations sa ON sa.id=totals.allocation_id
            JOIN exam_cycles ec ON ec.id=sa.cycle_id JOIN exam_shifts es ON es.id=sa.shift_id
            JOIN rooms r ON r.id=totals.room_id
            LEFT JOIN faculty_room_sessions fs ON fs.allocation_id=sa.id AND fs.room_id=totals.room_id
            LEFT JOIN users editor ON editor.id=fs.edited_by LEFT JOIN users submitter ON submitter.id=fs.submitted_by
            WHERE sa.status='published' AND (? IS NULL OR sa.id=?)
            ORDER BY (sa.exam_date=?) DESC,sa.exam_date DESC,es.sequence_no,r.code", [$allocation,$allocation,$today]);
    }
}
