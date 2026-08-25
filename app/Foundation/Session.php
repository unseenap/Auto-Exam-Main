<?php

declare(strict_types=1);

namespace App\Foundation;

final class Session
{
    public function __construct(private readonly int $timeoutMinutes)
    {
    }

    public function start(): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            return;
        }

        session_name('gbu_exam_session');
        // Shared hosts provide their own writable session location. Only override
        // it when an explicit, writable path is configured for a local server.
        $configuredPath = trim((string) env('SESSION_SAVE_PATH', ''));
        if ($configuredPath !== '' && is_dir($configuredPath) && is_writable($configuredPath)) {
            session_save_path($configuredPath);
        }
        session_set_cookie_params([
            'lifetime' => 0,
            'path' => '/',
            'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
            'httponly' => true,
            'samesite' => 'Lax',
        ]);
        session_start();

        $lastActivity = (int) ($_SESSION['_last_activity'] ?? time());
        if (time() - $lastActivity > $this->timeoutMinutes * 60) {
            $this->invalidate();
            session_start();
            $_SESSION['_expired'] = true;
        }
        $_SESSION['_last_activity'] = time();
    }

    public function get(string $key, mixed $default = null): mixed
    {
        return $_SESSION[$key] ?? $default;
    }

    public function put(string $key, mixed $value): void
    {
        $_SESSION[$key] = $value;
    }

    public function forget(string $key): void
    {
        unset($_SESSION[$key]);
    }

    public function flash(string $key, mixed $value): void
    {
        $_SESSION['_flash'][$key] = $value;
    }

    public function pullFlash(string $key, mixed $default = null): mixed
    {
        $value = $_SESSION['_flash'][$key] ?? $default;
        unset($_SESSION['_flash'][$key]);
        return $value;
    }

    public function csrfToken(): string
    {
        if (empty($_SESSION['_token'])) {
            $_SESSION['_token'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['_token'];
    }

    public function validCsrf(?string $token): bool
    {
        return is_string($token) && hash_equals($this->csrfToken(), $token);
    }

    public function regenerate(): void
    {
        session_regenerate_id(true);
    }

    public function invalidate(): void
    {
        $_SESSION = [];
        if (session_status() === PHP_SESSION_ACTIVE) {
            session_destroy();
        }
    }
}
