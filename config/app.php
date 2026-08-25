<?php

declare(strict_types=1);

return [
    'name' => env('APP_NAME', 'GBU Examination Operations'),
    'environment' => env('APP_ENV', 'production'),
    'debug' => filter_var(env('APP_DEBUG', 'false'), FILTER_VALIDATE_BOOL),
    'url' => env('APP_URL', 'http://localhost/Auto-Exam-Main/public'),
    'timezone' => env('APP_TIMEZONE', 'Asia/Kolkata'),
    'session_timeout_minutes' => (int) env('SESSION_TIMEOUT_MINUTES', '30'),
];

