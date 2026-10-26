<?php

declare(strict_types=1);

namespace App\Rooms;

use PDO;
use RuntimeException;

final class SchoolRoomPolicy
{
    public function __construct(private readonly PDO $pdo) {}

    public function assertStudentRoom(int $studentId, int $roomId): void
    {
        $q=$this->pdo->prepare("SELECT COUNT(*) FROM students st JOIN programmes p ON p.id=st.programme_id JOIN rooms r ON r.school_id=p.school_id JOIN schools s ON s.id=r.school_id WHERE st.id=? AND r.id=? AND r.status='active' AND s.status='active'");
        $q->execute([$studentId,$roomId]);
        if(!(int)$q->fetchColumn())throw new RuntimeException('Choose an active room belonging to the student’s school. Cross-school seating is not allowed.');
    }

    public function assertSchool(int $schoolId): void
    {
        $q=$this->pdo->prepare("SELECT COUNT(*) FROM schools WHERE id=? AND status='active'");$q->execute([$schoolId]);
        if(!(int)$q->fetchColumn())throw new RuntimeException('Select an active school for this room.');
    }

    public function assertOwnershipChange(int $roomId, int $schoolId): void
    {
        $this->assertSchool($schoolId);
        // Initial ownership may be recorded when all historical students belong to that school.
        $q=$this->pdo->prepare("SELECT COUNT(*) FROM rooms r JOIN seating_assignments sa ON sa.room_id=r.id JOIN seating_allocations a ON a.id=sa.allocation_id JOIN students st ON st.id=sa.student_id JOIN programmes p ON p.id=st.programme_id WHERE r.id=? AND NOT(r.school_id <=> ?) AND a.status IN ('published','superseded') AND (r.school_id IS NOT NULL OR p.school_id<>?)");
        $q->execute([$roomId,$schoolId,$schoolId]);
        if((int)$q->fetchColumn())throw new RuntimeException('This room has published seating history. Its school cannot be changed.');
    }
}
