<?php

declare(strict_types=1);

define('BASE_PATH', dirname(__DIR__));
spl_autoload_register(static function (string $class): void {
    $prefix='App\\';if(str_starts_with($class,$prefix))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,strlen($prefix))).'.php';
});

use App\Export\XlsxExporter;

$bytes=(new XlsxExporter())->build(
    'End Semester Examination Date Sheet',
    'School of Information and Communication Technology',
    '06 October 2026 to 16 October 2026',
    ['Programme / Branch, Batch and Semester','06 Oct 2026','08 Oct 2026'],
    [[
        'UCS — B.Tech Computer Science and Engineering · UCS 2023-2027 · Semester 7',
        "CS-701 — Machine Learning\nMorning Shift · 10:00-13:00",
        "CS-703 — Cloud Computing\nMorning Shift · 10:00-13:00",
    ]],
    [30,22,22],
    file_get_contents(BASE_PATH.'/public/assets/images/gbu-emblem.png')?:null
);
assert(str_starts_with($bytes,'PK'));
assert(str_contains($bytes,'xl/worksheets/sheet1.xml'));
assert(str_contains($bytes,'UCS — B.Tech Computer Science and Engineering'));
assert(str_contains($bytes,'UCS 2023-2027'));
assert(str_contains($bytes,'Programme / Branch, Batch and Semester'));
assert(str_contains($bytes,'CS-701 — Machine Learning'));
assert(str_contains($bytes,'School of Information and Communication Technology'));
assert(str_contains($bytes,'xl/media/gbu-emblem.png'));
if(isset($argv[1]))file_put_contents($argv[1],$bytes);
echo "Excel export: PASS (valid date-sheet matrix with programme, batch, semester and date columns)\n";
