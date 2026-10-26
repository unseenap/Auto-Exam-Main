<?php

declare(strict_types=1);

namespace App\Import;

use RuntimeException;
use SimpleXMLElement;
use ZipArchive;

final class TabularReader
{
    public function read(string $path, string $extension): array
    {
        return match (strtolower($extension)) {
            'csv' => $this->readCsv($path),
            'xlsx' => $this->readXlsx($path),
            default => throw new RuntimeException('Only CSV and XLSX files are supported.'),
        };
    }

    private function readCsv(string $path): array
    {
        $handle = fopen($path, 'rb');
        if (!$handle) throw new RuntimeException('The uploaded CSV could not be opened.');
        $rows = [];
        while (($row = fgetcsv($handle)) !== false) $rows[] = array_map(static fn($value) => trim((string) $value), $row);
        fclose($handle);
        return $rows;
    }

    private function readXlsx(string $path): array
    {
        if (!class_exists(ZipArchive::class)) throw new RuntimeException('XLSX support requires the PHP zip extension.');
        $zip = new ZipArchive();
        if ($zip->open($path) !== true) throw new RuntimeException('The XLSX workbook could not be opened.');
        $shared = [];
        $sharedXml = $zip->getFromName('xl/sharedStrings.xml');
        if ($sharedXml !== false) {
            $xml = new SimpleXMLElement($sharedXml);
            foreach ($xml->xpath('./*[local-name()="si"]') as $item) {
                $shared[] = $this->spreadsheetText($item);
            }
        }
        $sheetXml = $zip->getFromName('xl/worksheets/sheet1.xml');
        $zip->close();
        if ($sheetXml === false) throw new RuntimeException('The first worksheet is missing.');
        $sheet = new SimpleXMLElement($sheetXml);
        $rows = [];
        // XLSX writers may use a default namespace or an explicit prefix such
        // as x:. SimpleXML property access silently misses prefixed elements.
        foreach ($sheet->xpath('./*[local-name()="sheetData"]/*[local-name()="row"]') as $row) {
            $values = [];
            foreach ($row->xpath('./*[local-name()="c"]') as $cell) {
                $reference = (string) $cell['r'];
                preg_match('/^[A-Z]+/', $reference, $match);
                $column = $this->columnIndex($match[0] ?? 'A');
                $type = (string) $cell['t'];
                $value = (string) (($cell->xpath('./*[local-name()="v"]'))[0] ?? '');
                if ($type === 's') $value = $shared[(int) $value] ?? '';
                elseif ($type === 'inlineStr') {
                    $inline = $cell->xpath('./*[local-name()="is"]');
                    $value = isset($inline[0]) ? $this->spreadsheetText($inline[0]) : '';
                }
                $values[$column] = trim($value);
            }
            if ($values) {
                $max = max(array_keys($values));
                $rows[] = array_map(static fn($value) => (string) $value, array_replace(array_fill(0, $max + 1, ''), $values));
            }
        }
        return $rows;
    }

    private function spreadsheetText(SimpleXMLElement $node): string
    {
        $parts = $node->xpath('./*[local-name()="t"] | ./*[local-name()="r"]/*[local-name()="t"]');
        return implode('', array_map(static fn(SimpleXMLElement $part): string => (string) $part, $parts));
    }

    private function columnIndex(string $letters): int
    {
        $index = 0;
        foreach (str_split($letters) as $letter) $index = $index * 26 + (ord($letter) - 64);
        return $index - 1;
    }
}

