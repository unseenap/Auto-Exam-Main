<?php
declare(strict_types=1);

namespace App\Exams;

final class WrittenPaperPolicy
{
    public static function isLab(string $name): bool
    {
        return preg_match('/\b(lab|labs|laboratory|laboratories|practical|practicals)\b/i', $name) === 1;
    }
}
