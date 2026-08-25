<?php

declare(strict_types=1);

namespace App\Auth;

use App\Foundation\Database;
use App\Foundation\Session;
use PDO;

final class Auth
{
    public function __construct(private readonly Database $database, private readonly Session $session) {}

    public function attempt(string $username, string $password): bool
    {
        if (trim($username) === '' || $password === '') return false;
        $statement = $this->database->connection()->prepare("SELECT u.id, u.username, u.name, u.password_hash, u.status,
            r.code AS role_code, r.name AS role_name FROM users u JOIN roles r ON r.id=u.role_id WHERE u.username=:username LIMIT 1");
        $statement->execute(['username' => trim($username)]);
        $user = $statement->fetch(PDO::FETCH_ASSOC);
        if (!$user || $user['status'] !== 'active' || !password_verify($password, $user['password_hash'])) return false;
        unset($user['password_hash'], $user['status']);
        $this->session->regenerate();
        $this->session->put('user', $user);
        $this->database->connection()->prepare('UPDATE users SET last_login_at=NOW() WHERE id=:id')->execute(['id' => $user['id']]);
        return true;
    }

    public function check(): bool { return is_array($this->session->get('user')); }
    public function user(): ?array { $user = $this->session->get('user'); return is_array($user) ? $user : null; }
    public function can(string $permission):bool {return $this->check()&&RolePolicy::allows((string)($this->user()['role_code']??''),$permission);}
    public function logout(): void { $this->session->invalidate(); }
}
