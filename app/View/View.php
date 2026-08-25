<?php

declare(strict_types=1);

namespace App\View;

use RuntimeException;

final class View
{
    public static function render(string $view, array $data = []): string
    {
        $viewFile = BASE_PATH . '/resources/views/' . $view . '.php';
        if (!is_file($viewFile)) throw new RuntimeException("View not found: {$view}");
        extract($data, EXTR_SKIP);
        ob_start(); require $viewFile; $content = (string) ob_get_clean();
        if (str_starts_with($view, 'auth/') || str_starts_with($view, 'errors/')) return $content;
        ob_start(); require BASE_PATH . '/resources/views/layouts/app.php'; return (string) ob_get_clean();
    }
}

