<?php

declare(strict_types=1);

namespace App\Http;

final class Request
{
    private function __construct(
        private readonly string $method,
        private readonly string $path,
    ) {
    }

    public static function capture(): self
    {
        $uri = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
        $scriptDirectory = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? ''));
        if ($scriptDirectory !== '/' && $scriptDirectory !== '.' && str_starts_with($uri, $scriptDirectory)) {
            $uri = substr($uri, strlen($scriptDirectory)) ?: '/';
        }

        return new self(strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET'), '/' . ltrim($uri, '/'));
    }

    public function method(): string
    {
        return $this->method;
    }

    public function path(): string
    {
        return $this->path;
    }

    public function input(string $key, mixed $default = null): mixed
    {
        return $_POST[$key] ?? $_GET[$key] ?? $default;
    }
}
