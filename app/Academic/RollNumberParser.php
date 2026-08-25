<?php

declare(strict_types=1);

namespace App\Academic;

final class RollNumberParser
{
    /** @param array<string, array{id:int, lateral_entry:int, legacy:int}> $programmes */
    public function parse(string $original, array $programmes): array
    {
        $display = trim($original);
        $upper = strtoupper($display);
        $special = false;

        if (preg_match('/^R[\s-]*/', $upper) === 1) {
            $special = true;
            $upper = (string) preg_replace('/^R[\s-]*/', '', $upper, 1);
        }

        $normalized = preg_replace('/[^A-Z0-9]/', '', $upper) ?? '';
        $normalizedWithStatus = ($special ? 'R-' : '') . $normalized;
        if ($normalized === '') {
            return $this->result($display, $normalizedWithStatus, null, null, null, null, $special, 'invalid', 'Roll number is empty or contains no letters or numbers.');
        }

        uksort($programmes, static fn(string $a, string $b): int => strlen($b) <=> strlen($a));
        foreach ($programmes as $code => $programme) {
            $position = strpos($normalized, strtoupper($code));
            if ($position === false) continue;

            $prefix = substr($normalized, 0, $position);
            $sequence = substr($normalized, $position + strlen($code));
            if ($prefix === '' || $sequence === '' || !ctype_digit($sequence)) continue;

            $admissionType = ((int) $programme['lateral_entry'] === 1) ? 'lateral'
                : (((int) $programme['legacy'] === 1) ? 'legacy' : 'regular');
            return $this->result($display, $normalizedWithStatus, (int) $programme['id'], $prefix, strtoupper($code), $sequence,
                $special, 'verified', null, $admissionType);
        }

        if (preg_match('/^([0-9]+)([A-Z]+)([0-9]+)$/', $normalized, $parts) === 1) {
            return $this->result($display, $normalizedWithStatus, null, $parts[1], $parts[2], $parts[3], $special,
                'review', 'Unknown or unverified programme code. Manual mapping is required.');
        }

        return $this->result($display, $normalizedWithStatus, null, null, null, null, $special, 'invalid',
            'The roll number format could not be parsed.');
    }

    private function result(string $original, string $normalized, ?int $programmeId, ?string $prefix, ?string $code,
        ?string $sequence, bool $special, string $status, ?string $message, string $admissionType = 'unknown'): array
    {
        return [
            'roll_no_original' => $original,
            'normalized_roll_no' => $normalized,
            'programme_id' => $programmeId,
            'registration_prefix' => $prefix,
            'programme_code_detected' => $code,
            'student_sequence' => $sequence,
            'special_status' => $special ? 'repeat' : 'none',
            'admission_type' => $admissionType,
            'parsing_status' => $status,
            'message' => $message,
        ];
    }
}

