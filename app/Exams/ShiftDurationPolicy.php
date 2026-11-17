<?php
declare(strict_types=1);

namespace App\Exams;

final class ShiftDurationPolicy
{
    public static function clockMinutes(array $shift): int
    {
        return max(0, (int) ((strtotime($shift['end_time']) - strtotime($shift['start_time'])) / 60));
    }

    public static function availableMinutes(array $shift): int
    {
        return min((int) $shift['duration_minutes'], self::clockMinutes($shift));
    }

    public static function describe(array $shifts): string
    {
        return implode('; ', array_map(static fn(array $shift): string =>
            $shift['name'].' '.substr($shift['start_time'], 0, 5).'–'.substr($shift['end_time'], 0, 5).
            ' ('.self::availableMinutes($shift).' usable minutes)', $shifts));
    }

    public static function blockedReason(int $required, array $shifts): string
    {
        return "This paper requires {$required} minutes, but no shift is long enough. Available shifts: ".
            self::describe($shifts).'. Open Exam calendar and extend the shift start/end times and configured duration to fit the paper, then validate again. Adding exam days alone will not fix this.';
    }
}
