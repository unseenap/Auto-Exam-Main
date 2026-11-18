<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
$base=dirname(__DIR__);
require $base.'/app/Support/helpers.php';require $base.'/app/Foundation/Environment.php';require $base.'/app/Foundation/Database.php';require $base.'/app/Auth/EmailUsernameMigration.php';
App\Foundation\Environment::load($base.'/.env');
$pdo=(new App\Foundation\Database(require $base.'/config/database.php'))->connection();
App\Auth\EmailUsernameMigration::apply($pdo);
echo "Email-length usernames enabled; existing usernames, passwords, and accounts retained.\n";
