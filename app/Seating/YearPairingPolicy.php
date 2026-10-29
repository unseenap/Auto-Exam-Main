<?php
declare(strict_types=1);
namespace App\Seating;

final class YearPairingPolicy
{
    public static function allows(array $a,array $b): bool
    {
        $left=(int)($a['study_year']??0);$right=(int)($b['study_year']??0);
        if(!$left||!$right||$left===$right)return false;
        return ($left===1&&$right===3)||($left===3&&$right===1)
            ||($left===2&&$right>2&&$right===(int)($b['final_year']??0))
            ||($right===2&&$left>2&&$left===(int)($a['final_year']??0));
    }
}
