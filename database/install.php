<?php

declare(strict_types=1);

if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
$base = dirname(__DIR__);
require $base . '/app/Support/helpers.php';
require $base . '/app/Foundation/Environment.php';
App\Foundation\Environment::load($base . '/.env');
$config = require $base . '/config/database.php';
$password = $argv[2] ?? null;
if (!$password || strlen($password) < 12) {
    fwrite(STDERR, "Usage: php database/install.php <admin-username> <password-at-least-12-characters>\n"); exit(1);
}
$pdo = new PDO(sprintf('mysql:host=%s;port=%d;charset=utf8mb4', $config['host'], $config['port']),
    $config['username'], $config['password'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$databaseName = str_replace('`', '``', $config['database']);
$pdo->exec("CREATE DATABASE IF NOT EXISTS `{$databaseName}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
$pdo->exec("USE `{$databaseName}`");
$rolesTableExists = (bool) $pdo->query("SHOW TABLES LIKE 'roles'")->fetchColumn();
if (!$rolesTableExists) {
    $pdo->exec((string) file_get_contents(__DIR__ . '/schema.sql'));
}
$pdo->exec((string) file_get_contents(__DIR__ . '/seed.sql'));
$pdo->exec("USE `{$databaseName}`");
$roleId = $pdo->query("SELECT id FROM roles WHERE code='admin'")->fetchColumn();
$statement = $pdo->prepare("INSERT INTO users (role_id, username, name, password_hash, status)
    VALUES (:role_id,:username,:name,:password_hash,'active') ON DUPLICATE KEY UPDATE name=VALUES(name),password_hash=VALUES(password_hash),status='active'");
$statement->execute(['role_id' => $roleId, 'username' => $argv[1] ?? 'admin', 'name' => 'Examination Cell Administrator',
    'password_hash' => password_hash($password, PASSWORD_DEFAULT)]);
fwrite(STDOUT, "Database installed and administrator account prepared.\n");
