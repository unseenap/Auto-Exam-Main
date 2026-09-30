<?php

declare(strict_types=1);

define('BASE_PATH', dirname(__DIR__));
require BASE_PATH . '/app/Support/helpers.php';
spl_autoload_register(static function (string $class): void {
    $prefix = 'App\\';
    if (str_starts_with($class, $prefix)) require BASE_PATH . '/app/' . str_replace('\\', '/', substr($class, strlen($prefix))) . '.php';
});

use App\Import\CourseImportService;

$config = require BASE_PATH . '/config/database.php';
$pdo = new PDO("mysql:host={$config['host']};port={$config['port']};dbname={$config['database']};charset=utf8mb4", $config['username'], $config['password'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
$pdo->beginTransaction();
try {
    $service = new CourseImportService($pdo);
    $batchId = $service->stage(BASE_PATH . '/tests/fixtures/course-batch-label-alias.csv', 'course-batch-label-alias.csv', 1);
    $row = $pdo->query("SELECT validation_status,normalized_data,validation_messages FROM import_rows WHERE import_batch_id={$batchId}")->fetch();
    assert($row['validation_status'] === 'valid', $row['validation_messages']);
    $normalized = json_decode($row['normalized_data'], true, flags: JSON_THROW_ON_ERROR);
    assert($normalized['batch_label'] === 'UCS 2019-2023');
    echo "Course batch alias: PASS (UCS 2019-23 resolves to UCS 2019-2023)\n";
} finally {
    $pdo->rollBack();
}
