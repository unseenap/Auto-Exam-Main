<?php

declare(strict_types=1);

namespace App\Seating;

use App\Faculty\FacultyPortalMigration;
use PDO;
use RuntimeException;
use Throwable;

final class SeatingPublicationService
{
    public function __construct(private readonly PDO $pdo) {}

    private function rows(string $sql, array $arguments = []): array
    {
        $query = $this->pdo->prepare($sql);
        $query->execute($arguments);
        return $query->fetchAll(PDO::FETCH_ASSOC);
    }

    private function audit(int $user, int $allocation, string $action, array $details): void
    {
        $this->pdo->prepare('INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(?,?,\'seating_allocation\',?,?)')
            ->execute([$user, $action, $allocation, json_encode($details, JSON_THROW_ON_ERROR)]);
    }

    public function publish(int $id, int $user): int
    {
        FacultyPortalMigration::apply($this->pdo);
        $header = $this->rows('SELECT cycle_id FROM seating_allocations WHERE id=?', [$id])[0] ?? null;
        if (!$header) throw new RuntimeException('Seating plan not found.');
        $this->pdo->beginTransaction();
        try {
            $this->rows('SELECT id FROM exam_cycles WHERE id=? FOR UPDATE', [$header['cycle_id']]);
            $allocation = $this->rows('SELECT * FROM seating_allocations WHERE id=? FOR UPDATE', [$id])[0];
            if (!in_array($allocation['status'], ['draft','validated','published'], true)) {
                throw new RuntimeException('Only a current draft or published seating plan can be published.');
            }
            $validation = (new SeatingAllocator($this->pdo))->validate($id);
            if (!SeatingAllocator::publishable($validation)) {
                throw new RuntimeException('Resolve seating validation issues before publishing. Students awaiting seats can remain for later allocation.');
            }
            $assigned = $this->rows('SELECT id FROM seating_assignments WHERE allocation_id=? FOR UPDATE', [$id]);
            if (!$assigned) throw new RuntimeException('Assign at least one student before publishing.');
            $others = $this->rows("SELECT id FROM seating_allocations
                WHERE cycle_id=? AND exam_date=? AND shift_id=? AND status='published' AND id<>? FOR UPDATE",
                [$allocation['cycle_id'], $allocation['exam_date'], $allocation['shift_id'], $id]);
            foreach ($others as $old) {
                $records = $this->rows('SELECT * FROM attendance WHERE allocation_id=? FOR UPDATE', [$old['id']]);
                foreach ($records as $record) {
                    if ($record['status'] !== 'unmarked' || $record['marked_by'] !== null || $record['marked_at'] !== null
                        || $record['corrected_by'] !== null || $record['corrected_at'] !== null || trim((string)$record['remarks']) !== '') {
                        throw new RuntimeException('This session has recorded attendance. Use Allocate remaining students on its published plan.');
                    }
                }
                $sessions = $this->rows('SELECT * FROM faculty_room_sessions WHERE allocation_id=? FOR UPDATE', [$old['id']]);
                foreach ($sessions as $session) {
                    if ($session['status'] === 'submitted' || (int)$session['revision'] > 0 || $session['closing_report'] !== null) {
                        throw new RuntimeException('This session has attendance activity. Use Allocate remaining students on its published plan.');
                    }
                }
                $this->pdo->prepare('DELETE FROM attendance WHERE allocation_id=?')->execute([$old['id']]);
                $this->pdo->prepare("UPDATE seating_allocations SET status='superseded' WHERE id=?")->execute([$old['id']]);
            }
            $this->pdo->prepare("UPDATE seating_allocations SET status='published',published_at=COALESCE(published_at,NOW()) WHERE id=?")->execute([$id]);
            $this->createAttendance($id);
            if ($allocation['status'] !== 'published') {
                $this->audit($user, $id, 'seating.published', ['assigned' => count($assigned), 'remaining' => $validation['unallocated_students']]);
            }
            $this->pdo->commit();
            return $validation['unallocated_students'];
        } catch (Throwable $error) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            throw $error;
        }
    }

    private function createAttendance(int $allocation): void
    {
        $this->pdo->prepare("INSERT INTO attendance(allocation_id,examination_id,room_id,student_id,status)
            SELECT x.allocation_id,x.examination_id,x.room_id,x.student_id,'unmarked'
            FROM seating_assignments x WHERE x.allocation_id=?
            AND NOT EXISTS(SELECT 1 FROM attendance a WHERE a.examination_id=x.examination_id AND a.student_id=x.student_id)")
            ->execute([$allocation]);
        $missing = $this->rows('SELECT x.student_id FROM seating_assignments x LEFT JOIN attendance a
            ON a.allocation_id=x.allocation_id AND a.examination_id=x.examination_id AND a.student_id=x.student_id AND a.room_id=x.room_id
            WHERE x.allocation_id=? AND a.id IS NULL LIMIT 1', [$allocation]);
        if ($missing) throw new RuntimeException('Existing attendance belongs to another seating version. Resolve it before publishing this plan.');
    }

    public function allocateRemaining(int $id, int $user): array
    {
        FacultyPortalMigration::apply($this->pdo);
        $this->pdo->beginTransaction();
        try {
            $allocation = $this->rows('SELECT * FROM seating_allocations WHERE id=? FOR UPDATE', [$id])[0] ?? null;
            if (!$allocation || !in_array($allocation['status'], ['draft','published'], true)) {
                throw new RuntimeException('Open a current draft or published plan to allocate its remaining students.');
            }
            $pending = $this->rows('SELECT * FROM seating_unallocated WHERE allocation_id=? AND resolved_at IS NULL FOR UPDATE', [$id]);
            if (!$pending) {
                $this->pdo->commit();
                return ['assigned' => 0, 'remaining' => 0];
            }
            $eligible = (new SeatingRoster($this->pdo))->eligible((int)$allocation['cycle_id'], $allocation['exam_date'], (int)$allocation['shift_id']);
            $pendingKeys = [];
            foreach ($pending as $student) $pendingKeys[$student['student_id'].'/'.$student['examination_id']] = true;
            $students = array_values(array_filter($eligible, static fn(array $student): bool =>
                isset($pendingKeys[$student['student_id'].'/'.$student['examination_id']])));
            $seen = [];
            foreach ($students as $student) {
                if (isset($seen[$student['student_id']])) throw new RuntimeException('A remaining student has multiple papers in this shift. Correct the date sheet first.');
                $seen[$student['student_id']] = true;
            }
            if (!$students) throw new RuntimeException('The remaining students are no longer eligible. Review their examination registrations.');
            // New rooms keep the existing seats, room submissions and answer-book reports stable.
            $seats = $this->rows("SELECT rs.id AS seat_id,rs.room_id,r.columns_count,r.code AS room_code,
                r.usable_capacity,r.school_id,rs.row_no,rs.column_no,rs.sequence_no
                FROM room_seats rs JOIN rooms r ON r.id=rs.room_id JOIN schools sc ON sc.id=r.school_id
                WHERE rs.is_blocked=0 AND r.status='active' AND sc.status='active'
                AND NOT EXISTS(SELECT 1 FROM seating_assignments x WHERE x.allocation_id=? AND x.room_id=r.id)
                AND NOT EXISTS(SELECT 1 FROM faculty_room_sessions fs WHERE fs.allocation_id=? AND fs.room_id=r.id)
                ORDER BY r.priority,r.code,rs.sequence_no", [$id, $id]);
            $available = [];
            $counts = [];
            foreach ($seats as $seat) {
                $room = (int)$seat['room_id'];
                if (($counts[$room] ?? 0) >= (int)$seat['usable_capacity']) continue;
                $available[] = $seat;
                $counts[$room] = ($counts[$room] ?? 0) + 1;
            }
            if (!$available) throw new RuntimeException('No unused rooms have usable seats. Add or activate another room, then retry remaining allocation.');
            $plan = (new AutomaticPairedCohortPlanner())->plan($students, $available, [], false, true);
            if (!$plan['assigned']) throw new RuntimeException('No remaining students fit the unused rooms in their school. Add suitable room capacity, then retry.');
            $rules = json_decode($allocation['rule_profile'], true, 512, JSON_THROW_ON_ERROR);
            if (($rules['mode'] ?? '') === 'paired_cohorts') {
                foreach (['student_groups','student_papers','seat_groups','empty_partner_columns'] as $key) {
                    $rules[$key] = array_replace($rules[$key] ?? [], $plan['rules'][$key] ?? []);
                }
                $rules['cohorts'] = array_replace($plan['rules']['cohorts'], $rules['cohorts'] ?? []);
                $rules['pairings'] = array_merge($rules['pairings'] ?? [], $plan['rules']['pairings']);
                $rules['alternate_unmatched'] = true;
                // Manual-pair plans use room columns, while automatic plans use seat groups.
                foreach ($plan['assigned'] as $index => $student) {
                    $seat = $plan['assignmentSeats'][$index];
                    $rules['room_columns'][$seat['room_id']][$seat['column_no']] = $student['group_key'];
                }
            }
            $rules['room_ids'] = array_values(array_unique(array_merge($rules['room_ids'] ?? [],
                array_column($plan['assignmentSeats'], 'room_id'))));
            $insert = $this->pdo->prepare("INSERT INTO seating_assignments
                (allocation_id,examination_id,room_id,seat_id,student_id,is_manual_override,override_reason)
                VALUES(?,?,?,?,?,0,'Remaining allocation')");
            $resolve = $this->pdo->prepare('UPDATE seating_unallocated SET resolved_at=NOW() WHERE allocation_id=? AND student_id=? AND examination_id=? AND resolved_at IS NULL');
            foreach ($plan['assigned'] as $index => $student) {
                $seat = $plan['assignmentSeats'][$index];
                $insert->execute([$id, $student['examination_id'], $seat['room_id'], $seat['seat_id'], $student['student_id']]);
                $resolve->execute([$id, $student['student_id'], $student['examination_id']]);
            }
            $remaining = count($pending) - count($plan['assigned']);
            $rules['unallocated'] = $remaining;
            $this->pdo->prepare('UPDATE seating_allocations SET rule_profile=? WHERE id=?')
                ->execute([json_encode($rules, JSON_THROW_ON_ERROR), $id]);
            if (!SeatingAllocator::publishable((new SeatingAllocator($this->pdo))->validate($id))) {
                throw new RuntimeException('Remaining allocation failed the seating checks. Review the available rooms.');
            }
            if ($allocation['status'] === 'published') $this->createAttendance($id);
            $result = ['assigned' => count($plan['assigned']), 'remaining' => $remaining];
            $this->audit($user, $id, 'seating.remaining_allocated', $result);
            $this->pdo->commit();
            return $result;
        } catch (Throwable $error) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            throw $error;
        }
    }
}
