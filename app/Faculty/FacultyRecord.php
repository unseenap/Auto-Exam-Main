<?php

declare(strict_types=1);

namespace App\Faculty;

use PDO;

final class FacultyRecord
{
    public static function normalize(array $input): array
    {
        $data=['school_id'=>(int)($input['school_id']??0)];
        foreach(['name','designation','email','phone','status'] as $field)$data[$field]=trim((string)($input[$field]??''));
        $data['email']=mb_strtolower($data['email']);
        $data['phone']=self::mobile($data['phone']);
        if($data['phone']==='')$data['phone']=null;
        $data['status']=strtolower($data['status']);
        return $data;
    }

    public static function mobile(string $value): string
    {
        // Indian mobile numbers use one stored representation, including +91 / 0 inputs.
        $value=trim($value);
        if(!preg_match('/^[+0-9\s().-]*$/D',$value))return $value;
        $value=preg_replace('/[^0-9]/','',$value)??'';
        if(strlen($value)===12&&str_starts_with($value,'91'))$value=substr($value,2);
        elseif(strlen($value)===11&&str_starts_with($value,'0'))$value=substr($value,1);
        return $value;
    }

    public static function errors(PDO $pdo,array $data,?int $excludeId=null): array
    {
        $errors=[];
        $school=$pdo->prepare("SELECT COUNT(*) FROM schools WHERE id=? AND status='active'");$school->execute([$data['school_id']]);
        if(!(int)$school->fetchColumn())$errors['school_id']='Select an active school.';
        foreach(['name'=>'Name','designation'=>'Designation'] as $key=>$label)if($data[$key]==='')$errors[$key]=$label.' is required.';
        foreach(['name'=>190,'designation'=>120,'email'=>190,'phone'=>30] as $key=>$limit)if(mb_strlen($data[$key]??'')>$limit)$errors[$key]=ucfirst($key)." must be at most {$limit} characters.";
        if(!filter_var($data['email'],FILTER_VALIDATE_EMAIL))$errors['email']='A valid email address is required.';
        else{
            $existing=$pdo->prepare('SELECT COUNT(*) FROM faculty WHERE email=? AND id<>?');$existing->execute([$data['email'],$excludeId??0]);
            if((int)$existing->fetchColumn())$errors['email']='Email already belongs to another faculty record.';
        }
        if($data['phone']!==null&&!preg_match('/^[6-9][0-9]{9}$/D',$data['phone']))$errors['phone']='Enter a valid 10-digit Indian mobile number or leave it blank.';
        if(!in_array($data['status'],['active','inactive'],true))$errors['status']='Status must be active or inactive.';
        return $errors;
    }

    public static function employeeId(): string
    {
        return 'FAC-'.strtoupper(bin2hex(random_bytes(12)));
    }
}
