<?php
declare(strict_types=1);
namespace App\Seating;

use PDO;
use RuntimeException;

final class SeatingDeletionService
{
    public function __construct(private readonly PDO $pdo) {}

    public function delete(int $id, int $userId): void
    {
        $this->pdo->beginTransaction();
        try {
            $q = $this->pdo->prepare('SELECT * FROM seating_allocations WHERE id=? FOR UPDATE');
            $q->execute([$id]);
            $allocation = $q->fetch(PDO::FETCH_ASSOC);
            if (!$allocation) throw new RuntimeException('Seating plan not found.');

            $q = $this->pdo->prepare('SELECT * FROM attendance WHERE allocation_id=? FOR UPDATE');
            $q->execute([$id]);
            foreach ($q->fetchAll(PDO::FETCH_ASSOC) as $record) {
                if ($record['status'] !== 'unmarked' || $record['marked_by'] !== null || $record['marked_at'] !== null || $record['corrected_by'] !== null || $record['corrected_at'] !== null || trim((string)$record['remarks']) !== '') {
                    throw new RuntimeException('This seating plan has recorded attendance and cannot be deleted.');
                }
            }
            // Duties belong to the examination session, rather than a seating version.
            // Other historical versions can be removed without affecting the current plan.
            if ($allocation['status'] === 'published') {
                $q = $this->pdo->prepare("SELECT id FROM invigilation_allocations WHERE cycle_id=? AND exam_date=? AND shift_id=? AND duty_status<>'cancelled' FOR UPDATE");
                $q->execute([$allocation['cycle_id'], $allocation['exam_date'], $allocation['shift_id']]);
                if ($q->fetchColumn()) throw new RuntimeException('Cancel active invigilation duties for this session before deleting its published seating plan.');
            }

            $this->pdo->prepare('DELETE FROM attendance WHERE allocation_id=?')->execute([$id]);
            $this->pdo->prepare('DELETE FROM seating_allocations WHERE id=?')->execute([$id]);
            $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,old_values) VALUES(?,'seating.deleted','seating_allocation',?,?)")
                ->execute([$userId, $id, json_encode($allocation, JSON_THROW_ON_ERROR)]);
            $this->pdo->commit();
        } catch (\Throwable $e) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            throw $e;
        }
    }
}
