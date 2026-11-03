<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
require dirname(__DIR__).'/bootstrap/app.php';
App\Faculty\FacultyPortalMigration::apply($app->database()->connection());
echo "Faculty portal schema is ready. Existing accounts, passwords, attendance and seating allocations were retained.\n";
