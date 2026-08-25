<?php

declare(strict_types=1);

require dirname(__DIR__) . '/bootstrap/app.php';

use App\Http\Request;

$app->handle(Request::capture())->send();

