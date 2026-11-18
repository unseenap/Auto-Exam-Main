<?php
declare(strict_types=1);
namespace App\Import;

use App\Faculty\FacultyPortalService;
use PDO;
use RuntimeException;

final class FacultyAccountImportService
{
    public function __construct(private readonly PDO $pdo) {}

    public function assertAdmin(int $actor): void
    {
        $q=$this->pdo->prepare("SELECT u.id FROM users u JOIN roles r ON r.id=u.role_id WHERE u.id=? AND u.status='active' AND r.code='admin'");$q->execute([$actor]);
        if(!$q->fetchColumn())throw new RuntimeException('Only an active administrator can import faculty accounts.');
    }

    private function identity(string $email): array
    {
        $messages=[];
        if(strlen($email)>190||!filter_var($email,FILTER_VALIDATE_EMAIL))return [null,['A valid email is required as the login ID.']];
        $q=$this->pdo->prepare('SELECT id,name,status FROM faculty WHERE email=?');$q->execute([$email]);$matches=$q->fetchAll(PDO::FETCH_ASSOC);
        $faculty=count($matches)===1?$matches[0]:null;
        if(!$faculty)$messages[]='Import the faculty record with this email first; exactly one matching record is required.';
        elseif($faculty['status']!=='active')$messages[]='The linked faculty record must be active.';
        $q=$this->pdo->prepare('SELECT id FROM users WHERE username=? OR email=?');$q->execute([$email,$email]);
        if($q->fetchColumn())$messages[]='A login already uses this email. Existing accounts will not be changed.';
        if($faculty){$q=$this->pdo->prepare('SELECT user_id FROM faculty_user_links WHERE faculty_id=?');$q->execute([$faculty['id']]);if($q->fetchColumn())$messages[]='Faculty already has a linked login.';}
        return [$faculty,$messages];
    }

    public function stage(string $path,string $filename,int $actor): array
    {
        $this->assertAdmin($actor);
        $rows=(new TabularReader())->read($path,strtolower(pathinfo($filename,PATHINFO_EXTENSION)));
        if(count($rows)<2)throw new RuntimeException('Include a header and at least one faculty account.');
        if(count($rows)>501)throw new RuntimeException('Upload at most 500 faculty accounts at a time.');
        $headers=array_map(static function($value){$key=trim(preg_replace('/[^a-z0-9]+/','_',strtolower(trim((string)$value)))??'','_');return ['email_address'=>'email','login_id'=>'username','temporary_password'=>'password','account_status'=>'status','full_name'=>'name'][$key]??$key;},array_shift($rows));
        foreach(['email','password'] as $key)if(!in_array($key,$headers,true))throw new RuntimeException('Missing required column: '.$key.'.');
        foreach(['email','password','username','role','status'] as $key)if(count(array_keys($headers,$key,true))>1)throw new RuntimeException('Duplicate column: '.$key.'.');
        $preview=[];$seen=[];
        foreach($rows as $index=>$values){
            if(!array_filter($values,static fn($v)=>trim((string)$v)!==''))continue;
            $source=[];foreach($headers as $col=>$header)if($header!=='')$source[$header]=(string)($values[$col]??'');
            $email=strtolower(trim($source['email']??''));$password=$source['password']??'';
            [$faculty,$messages]=$this->identity($email);
            if(isset($seen[$email]))$messages[]='Email is duplicated in this file.';$seen[$email]=true;
            if(isset($source['username'])&&strtolower(trim($source['username']))!==$email)$messages[]='Username must be the same as Email.';
            if(isset($source['role'])&&strtolower(trim($source['role']))!=='faculty')$messages[]='Only the faculty role is allowed in this import.';
            $status=strtolower(trim($source['status']??'active'));
            if(!in_array($status,['active','inactive'],true))$messages[]='Account status must be active or inactive.';
            if(strlen($password)<12||strlen($password)>72)$messages[]='Password must contain between 12 and 72 characters.';
            $name=$faculty['name']??trim($source['name']??'');
            if(mb_strlen($name)>150)$messages[]='Faculty name exceeds the account name limit of 150 characters.';
            // Only hashes enter the review session; neither uploads nor plaintext passwords are persisted.
            $preview[]=['row'=>$index+2,'email'=>$email,'name'=>$name,'faculty_id'=>$faculty?(int)$faculty['id']:null,'status'=>$status,'messages'=>$messages,'password_hash'=>$messages?null:password_hash($password,PASSWORD_DEFAULT)];
            unset($password,$source);
        }
        if(!$preview)throw new RuntimeException('No faculty account rows were found.');
        return $preview;
    }

    public function commit(array $rows,int $actor): int
    {
        $this->assertAdmin($actor);
        $valid=array_values(array_filter($rows,static fn($row)=>!$row['messages']&&is_string($row['password_hash'])));
        if(!$valid)throw new RuntimeException('No valid faculty accounts are available to import.');
        $role=(int)$this->pdo->query("SELECT id FROM roles WHERE code='faculty'")->fetchColumn();
        if(!$role)throw new RuntimeException('The Faculty / Invigilator role is missing.');
        $this->pdo->beginTransaction();
        try{
            $insert=$this->pdo->prepare('INSERT INTO users(role_id,username,name,email,password_hash,status) VALUES(?,?,?,?,?,?)');
            $count=0;
            foreach($valid as $row){
                $lock=$this->pdo->prepare('SELECT id FROM faculty WHERE id=? FOR UPDATE');$lock->execute([$row['faculty_id']]);
                [$faculty,$messages]=$this->identity($row['email']);
                if($messages||!$faculty||(int)$faculty['id']!==$row['faculty_id'])throw new RuntimeException('Faculty account data changed after review. Upload the file again; no accounts were created.');
                $insert->execute([$role,$row['email'],$faculty['name'],$row['email'],$row['password_hash'],$row['status']]);
                $user=(int)$this->pdo->lastInsertId();(new FacultyPortalService($this->pdo))->linkAccount($actor,$user,(int)$faculty['id']);
                $audit=$this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(?,'faculty_account.imported','user',?,?)");
                $audit->execute([$actor,$user,json_encode(['faculty_id'=>(int)$faculty['id'],'role'=>'faculty','status'=>$row['status']])]);$count++;
            }
            $this->pdo->commit();return $count;
        }catch(\Throwable $error){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $error;}
    }

    public function credentialRows(int $actor): array
    {
        $this->assertAdmin($actor);$rows=[];
        $faculty=$this->pdo->query("SELECT f.name,f.email FROM faculty f WHERE f.status='active' AND f.email IS NOT NULL AND f.email<>'' AND NOT EXISTS(SELECT 1 FROM faculty_user_links l WHERE l.faculty_id=f.id) AND NOT EXISTS(SELECT 1 FROM users u WHERE u.email=f.email OR u.username=f.email) ORDER BY f.name");
        foreach($faculty as $f){$email=strtolower(trim($f['email']));if(!filter_var($email,FILTER_VALIDATE_EMAIL)||strlen($email)>190)continue;
            $password='';$chars='ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%_-';
            for($i=0;$i<20;$i++)$password.=$chars[random_int(0,strlen($chars)-1)];
            $rows[]=[$f['name'],$email,$email,$password,'faculty','active'];
        }
        return $rows;
    }
}
