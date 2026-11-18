<?php

declare(strict_types=1);

namespace App\Faculty;

use DateTimeImmutable;
use PDO;
use Throwable;

final class InvigilationService
{
    public const INVIGILATORS_PER_ROOM = 2;

    public function __construct(private readonly PDO $pdo) {}

    private function rows(string $sql, array $arguments = []): array
    {
        $query = $this->pdo->prepare($sql);
        $query->execute($arguments);
        return $query->fetchAll(PDO::FETCH_ASSOC);
    }

    /** Acquire before reading duties or availability in allocation/review transactions. */
    public function lockFaculty(): void
    {
        if (!$this->pdo->inTransaction()) throw new \LogicException('Faculty locks require a transaction.');
        // One lock order serializes competing allocations and replacement approvals across cycles.
        $this->rows('SELECT id FROM faculty ORDER BY id FOR UPDATE');
    }

    public function session(string $date, int $shift): array
    {
        $row = $this->rows('SELECT start_time,end_time FROM exam_shifts WHERE id=?', [$shift])[0] ?? null;
        if (!$row) throw new PortalException('Examination shift not found.');
        return $row + ['exam_date' => $date, 'shift_id' => $shift];
    }

    private function interval(array $session): array
    {
        $start = new DateTimeImmutable($session['exam_date'].' '.$session['start_time']);
        $end = new DateTimeImmutable($session['exam_date'].' '.$session['end_time']);
        if ($end < $start) $end = $end->modify('+1 day');
        return [$start, $end];
    }

    private function overlaps(array $left, array $right): bool
    {
        [$leftStart, $leftEnd] = $this->interval($left);
        [$rightStart, $rightEnd] = $this->interval($right);
        return $leftStart < $rightEnd && $rightStart < $leftEnd;
    }

    public function dutyConflict(int $faculty, array $session): ?array
    {
        $duties = $this->rows("SELECT ia.*,es.start_time,es.end_time,r.code AS room_code
            FROM invigilation_allocations ia JOIN exam_shifts es ON es.id=ia.shift_id
            JOIN rooms r ON r.id=ia.room_id WHERE ia.faculty_id=?
            AND ia.exam_date BETWEEN DATE_SUB(?,INTERVAL 1 DAY) AND DATE_ADD(?,INTERVAL 1 DAY)
            AND ia.duty_status IN ('assigned','confirmed','completed')",
            [$faculty, $session['exam_date'], $session['exam_date']]);
        foreach ($duties as $duty) {
            if ($this->overlaps($session, $duty)) return $duty;
        }
        return null;
    }

    public function unavailable(int $faculty, array $session): bool
    {
        $entries = $this->rows("SELECT fa.exam_date,es.start_time,es.end_time
            FROM faculty_availability fa JOIN exam_shifts es ON es.id=fa.shift_id
            WHERE fa.faculty_id=? AND fa.availability='unavailable'
            AND fa.exam_date BETWEEN DATE_SUB(?,INTERVAL 1 DAY) AND DATE_ADD(?,INTERVAL 1 DAY)",
            [$faculty, $session['exam_date'], $session['exam_date']]);
        foreach ($entries as $entry) {
            if ($this->overlaps($session, $entry)) return true;
        }
        return false;
    }

    public function assertAvailable(int $faculty, array $session): void
    {
        if ($this->dutyConflict($faculty, $session)) {
            throw new PortalException('The selected faculty member already has an overlapping duty. Choose another faculty member.');
        }
        // The existing unique key retains cancelled duty history for the same shift.
        if ($this->rows('SELECT id FROM invigilation_allocations WHERE faculty_id=? AND exam_date=? AND shift_id=?',
            [$faculty, $session['exam_date'], $session['shift_id']])) {
            throw new PortalException('The selected faculty member already has a duty record in this examination session. Choose another faculty member.');
        }
        if ($this->unavailable($faculty, $session)) {
            throw new PortalException('The selected faculty member is unavailable during this examination.');
        }
    }

    public function saveAvailability(int $user, int $faculty, string $date, int $shift, string $status, string $reason): void
    {
        (new FacultyPortalService($this->pdo))->requireCoordinator($user);
        $parsed = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
        if (!$parsed || $parsed->format('Y-m-d') !== $date
            || !in_array($status, ['available','unavailable','preferred'], true) || mb_strlen($reason) > 255) {
            throw new PortalException('Choose a valid date, availability status and a reason of at most 255 characters.');
        }
        $this->pdo->beginTransaction();
        try {
            $this->lockFaculty();
            if (!$this->rows("SELECT id FROM faculty WHERE id=? AND status='active'", [$faculty])) {
                throw new PortalException('Select an active faculty member.');
            }
            if (!$this->rows('SELECT es.id FROM exam_shifts es JOIN exam_cycles ec ON ec.id=es.cycle_id
                WHERE es.id=? AND ? BETWEEN ec.start_date AND ec.end_date', [$shift, $date])) {
                throw new PortalException('Choose a shift belonging to an exam cycle on the selected date.');
            }
            $session = $this->session($date, $shift);
            if ($status === 'unavailable' && $this->dutyConflict($faculty, $session)) {
                throw new PortalException('This faculty member has an overlapping duty. Reassign the duty before marking them unavailable.');
            }
            $this->pdo->prepare('INSERT INTO faculty_availability(faculty_id,exam_date,shift_id,availability,reason)
                VALUES(?,?,?,?,?) ON DUPLICATE KEY UPDATE availability=VALUES(availability),reason=VALUES(reason)')
                ->execute([$faculty, $date, $shift, $status, trim($reason) ?: null]);
            $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values)
                VALUES(?,'faculty.availability_saved','faculty',?,?)")
                ->execute([$user, $faculty, json_encode(['date' => $date, 'shift_id' => $shift, 'availability' => $status, 'reason' => $reason], JSON_THROW_ON_ERROR)]);
            $this->pdo->commit();
        } catch (Throwable $error) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            throw $error;
        }
    }

    public function allocate(int $allocationId, int $user): int
    {
        (new FacultyPortalService($this->pdo))->requireCoordinator($user);
        $this->pdo->beginTransaction();
        try {
            $this->lockFaculty();
            $allocation = $this->rows("SELECT sa.*,es.start_time,es.end_time
                FROM seating_allocations sa JOIN exam_shifts es ON es.id=sa.shift_id AND es.cycle_id=sa.cycle_id
                WHERE sa.id=? AND sa.status='published' FOR UPDATE", [$allocationId])[0] ?? null;
            if (!$allocation) throw new PortalException('Published seating session not found.');
            $rooms = $this->rows("SELECT x.room_id, (
                    SELECT COUNT(DISTINCT ia.faculty_id) FROM invigilation_allocations ia JOIN faculty f ON f.id=ia.faculty_id
                    WHERE ia.cycle_id=? AND ia.exam_date=? AND ia.shift_id=? AND ia.room_id=x.room_id
                    AND ia.duty_status IN ('assigned','confirmed','completed')
                    AND ia.duty_role IN ('invigilator','senior_invigilator') AND f.status='active'
                ) AS assigned_count FROM seating_assignments x
                WHERE x.allocation_id=? GROUP BY x.room_id HAVING assigned_count < ? ORDER BY x.room_id",
                [$allocation['cycle_id'], $allocation['exam_date'], $allocation['shift_id'], $allocationId, self::INVIGILATORS_PER_ROOM]);
            if (!$rooms) {
                $this->pdo->commit();
                return 0;
            }
            $slots = [];
            foreach ($rooms as $room) {
                $missing = self::INVIGILATORS_PER_ROOM - (int)$room['assigned_count'];
                for ($index = 0; $index < $missing; $index++) $slots[] = (int)$room['room_id'];
            }
            $candidates = $this->rows("SELECT id FROM faculty WHERE status='active' ORDER BY duty_count,name,id");
            $available = [];
            foreach ($candidates as $candidate) {
                try {
                    $this->assertAvailable((int)$candidate['id'], $allocation);
                    $available[] = (int)$candidate['id'];
                } catch (PortalException) {
                    continue;
                }
                if (count($available) === count($slots)) break;
            }
            if (count($available) < count($slots)) {
                throw new PortalException('Not enough available faculty. '.count($slots).' teacher assignments are needed across '.count($rooms).' rooms, but only '.count($available).' faculty are free.');
            }
            $insert = $this->pdo->prepare("INSERT INTO invigilation_allocations
                (cycle_id,exam_date,shift_id,room_id,faculty_id,duty_status,assigned_by)
                VALUES(?,?,?,?,?,'assigned',?)");
            $increment = $this->pdo->prepare('UPDATE faculty SET duty_count=duty_count+1 WHERE id=?');
            foreach ($slots as $index => $roomId) {
                $insert->execute([$allocation['cycle_id'], $allocation['exam_date'], $allocation['shift_id'],
                    $roomId, $available[$index], $user]);
                $increment->execute([$available[$index]]);
            }
            $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values)
                VALUES(?,'invigilation.allocated','seating_allocation',?,?)")
                ->execute([$user, $allocationId, json_encode(['rooms' => $rooms, 'faculty_ids' => $available], JSON_THROW_ON_ERROR)]);
            $this->pdo->commit();
            return count($slots);
        } catch (Throwable $error) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            throw $error;
        }
    }
}
