<?php
declare(strict_types=1);
namespace App\Auth;

final class Username
{
    public static function valid(string $value): bool
    {
        return (strlen($value)<=190&&filter_var($value,FILTER_VALIDATE_EMAIL)!==false)
            || preg_match('/^[a-z0-9._-]{3,80}$/D',$value)===1;
    }
}
