<?php

declare(strict_types=1);

use App\Foundation\Application;

function env(string $key, ?string $default = null): ?string
{
    $value = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
    return $value === false || $value === null ? $default : (string) $value;
}

function app(): Application
{
    return Application::instance();
}

function config(string $key, mixed $default = null): mixed
{
    return app()->config($key, $default);
}

function e(?string $value): string
{
    return htmlspecialchars($value ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function url(string $path = ''): string
{
    return rtrim((string) config('app.url'), '/') . '/' . ltrim($path, '/');
}

function csrf_field(): string
{
    $token = app()->session()->csrfToken();
    return '<input type="hidden" name="_token" value="' . e($token) . '">';
}

