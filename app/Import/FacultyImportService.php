<?php

declare(strict_types=1);

namespace App\Import;

use App\Faculty\FacultyRecord;
use PDO;
use RuntimeException;

final class FacultyImportService
{
    public function __construct(private readonly PDO $pdo) {}

    public function stage(string $path,string $originalName,int $userId): int
    {
        $rows=(new TabularReader())->read($path,strtolower(pathinfo($originalName,PATHINFO_EXTENSION)));
        if(count($rows)<2)throw new RuntimeException('The file must contain a header and at least one faculty row.');
        $headers=array_map([$this,'headerKey'],array_shift($rows));foreach(['name','school_code','designation','email','status'] as $required)if(!in_array($required,$headers,true))throw new RuntimeException("Missing required column: {$required}.");
        $schools=[];foreach($this->pdo->query("SELECT id,code,name,short_name FROM schools WHERE status='active'") as $s)foreach(['code','name','short_name'] as $key)if(trim((string)$s[$key])!=='')$schools[mb_strtolower(trim($s[$key]))]=(int)$s['id'];
        $q=$this->pdo->prepare("INSERT INTO import_batches(import_type,original_filename,stored_filename,status,uploaded_by) VALUES('faculty',:original,:stored,'validating',:user)");$q->execute(['original'=>$originalName,'stored'=>basename($path),'user'=>$userId]);$batch=(int)$this->pdo->lastInsertId();$valid=0;$invalid=0;$seen=[];
        $insert=$this->pdo->prepare("INSERT INTO import_rows(import_batch_id,source_row_number,source_data,normalized_data,validation_status,validation_messages) VALUES(:batch,:row,:source,:normalized,:status,:messages)");
        foreach($rows as $index=>$values){
            $source=[];foreach($headers as $column=>$header)if(in_array($header,['name','school_code','designation','email','phone','status'],true))$source[$header]=trim((string)($values[$column]??''));
            $school=mb_strtolower(trim($source['school_code']??''));
            $data=FacultyRecord::normalize($source+['school_id'=>$schools[$school]??0]);
            $messages=array_values(FacultyRecord::errors($this->pdo,$data));
            if($data['email']!==''&&isset($seen[$data['email']]))$messages[]='Email is duplicated in this file.';
            if($data['email']!=='')$seen[$data['email']]=true;
            $data['department_id']=null;$data['employee_id']=FacultyRecord::employeeId();
            $status=$messages?'invalid':'valid';$messages?$invalid++:$valid++;
            $insert->execute(['batch'=>$batch,'row'=>$index+2,'source'=>json_encode($source),'normalized'=>json_encode($data),'status'=>$status,'messages'=>json_encode($messages)]);
        }
        $this->pdo->prepare("UPDATE import_batches SET status='review',total_rows=:total,valid_rows=:valid,invalid_rows=:invalid WHERE id=:id")->execute(['total'=>count($rows),'valid'=>$valid,'invalid'=>$invalid,'id'=>$batch]);return $batch;
    }

    public function commit(int $batchId,int $userId): int
    {
        $q=$this->pdo->prepare("SELECT * FROM import_batches WHERE id=:id AND import_type='faculty' AND status='review' FOR UPDATE");$q->execute(['id'=>$batchId]);if(!$q->fetch())throw new RuntimeException('Faculty import is not available for commit.');$q=$this->pdo->prepare("SELECT * FROM import_rows WHERE import_batch_id=:id AND validation_status='valid'");$q->execute(['id'=>$batchId]);$insert=$this->pdo->prepare('INSERT INTO faculty(school_id,department_id,employee_id,name,designation,email,phone,status) VALUES(:school_id,:department_id,:employee_id,:name,:designation,:email,:phone,:status)');$count=0;foreach($q as $row){$data=json_decode($row['normalized_data'],true,flags:JSON_THROW_ON_ERROR);$errors=FacultyRecord::errors($this->pdo,$data);if($errors)throw new RuntimeException(implode(' ',array_values($errors)));$insert->execute($data);$entity=(int)$this->pdo->lastInsertId();$this->pdo->prepare('UPDATE import_rows SET committed_entity_id=:entity WHERE id=:id')->execute(['entity'=>$entity,'id'=>$row['id']]);$count++;}$this->pdo->prepare("UPDATE import_batches SET status='committed',committed_at=NOW() WHERE id=:id")->execute(['id'=>$batchId]);$this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,'faculty_import.committed','import_batch',:id,:data)")->execute(['user'=>$userId,'id'=>$batchId,'data'=>json_encode(['faculty_created'=>$count])]);return $count;
    }

    private function headerKey(string $header): string
    {
        $key=trim(preg_replace('/[^a-z0-9]+/','_',strtolower(trim($header)))??'','_');$aliases=['employee_code'=>'employee_id','faculty_id'=>'employee_id','faculty_name'=>'name','school'=>'school_code','school_name'=>'school_code','degignation'=>'designation','phone_no'=>'phone','phone_number'=>'phone','mobile'=>'phone','mobile_no'=>'phone','mobile_number'=>'phone','mobile_no_'=>'phone'];return $aliases[$key]??$key;
    }
}
