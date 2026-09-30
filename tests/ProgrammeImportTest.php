<?php

declare(strict_types=1);

define('BASE_PATH', dirname(__DIR__));
require BASE_PATH . '/app/Support/helpers.php';
spl_autoload_register(static function (string $class): void {
    $prefix = 'App\\';
    if (str_starts_with($class, $prefix)) {
        require BASE_PATH . '/app/' . str_replace('\\', '/', substr($class, strlen($prefix))) . '.php';
    }
});

use App\Import\ProgrammeImportService;

$config = require BASE_PATH . '/config/database.php';
$pdo = new PDO(
    "mysql:host={$config['host']};port={$config['port']};dbname={$config['database']};charset=utf8mb4",
    $config['username'],
    $config['password'],
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]
);

$pdo->beginTransaction();
try {
    $service = new ProgrammeImportService($pdo);
    $batchId = $service->stage(BASE_PATH . '/tests/fixtures/programmes-import.csv', 'programmes-import.csv', 1);
    $summary = $pdo->query("SELECT total_rows,valid_rows,invalid_rows FROM import_batches WHERE id={$batchId}")->fetch();
    assert((int) $summary['total_rows'] === 2);
    assert((int) $summary['valid_rows'] === 1);
    assert((int) $summary['invalid_rows'] === 1);
    assert($service->commit($batchId, 1) === 1);
    assert((int) $pdo->query("SELECT COUNT(*) FROM programmes WHERE code='TST'")->fetchColumn() === 1);
    echo "Programme import: PASS (validation, staging and commit)\n";
} finally {
    $pdo->rollBack();
}
