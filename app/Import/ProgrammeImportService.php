<?php

declare(strict_types=1);

namespace App\Import;

use PDO;
use RuntimeException;

final class ProgrammeImportService
{
    public function __construct(private readonly PDO $pdo) {}

    public function stage(string $path,string $originalName,int $userId): int
    {
        $rows=(new TabularReader())->read($path,strtolower(pathinfo($originalName,PATHINFO_EXTENSION)));
        if(count($rows)<2)throw new RuntimeException('The file must contain a header and at least one programme row.');
        $headers=array_map([$this,'key'],array_shift($rows));foreach(['school_code','programme_code','programme_name','level','duration_semesters'] as $required)if(!in_array($required,$headers,true))throw new RuntimeException("Missing required column: {$required}.");
        $schools=[];foreach($this->pdo->query("SELECT id,code FROM schools WHERE status='active'") as $school)$schools[strtoupper($school['code'])]=(int)$school['id'];
        $q=$this->pdo->prepare("INSERT INTO import_batches(import_type,original_filename,stored_filename,status,uploaded_by) VALUES('programmes',:original,:stored,'validating',:user)");$q->execute(['original'=>$originalName,'stored'=>basename($path),'user'=>$userId]);$batch=(int)$this->pdo->lastInsertId();$valid=0;$invalid=0;
        $insert=$this->pdo->prepare('INSERT INTO import_rows(import_batch_id,source_row_number,source_data,normalized_data,validation_status,validation_messages) VALUES(:batch,:row,:source,:normalized,:status,:messages)');
        $levels=['undergraduate','postgraduate','integrated','doctoral','diploma','other'];$statuses=['active','inactive','unverified'];
        foreach($rows as $index=>$values){$source=[];foreach($headers as $column=>$header)if($header!=='')$source[$header]=trim((string)($values[$column]??''));$messages=[];$schoolCode=strtoupper($source['school_code']??'');$code=strtoupper($source['programme_code']??'');$name=trim($source['programme_name']??'');$level=strtolower($source['level']??'');$duration=(int)($source['duration_semesters']??0);$status=strtolower($source['status']??'active');if(!isset($schools[$schoolCode]))$messages[]='School code was not found or is inactive.';if(!preg_match('/^[A-Z]{3}$/',$code))$messages[]='Programme code must contain exactly three letters.';if($name==='')$messages[]='Programme name is required.';if(!in_array($level,$levels,true))$messages[]='Invalid programme level.';if($duration<1||$duration>20)$messages[]='Duration must be between 1 and 20 semesters.';if(!in_array($status,$statuses,true))$messages[]='Invalid status.';$duplicate=$this->pdo->prepare('SELECT COUNT(*) FROM programmes WHERE code=:code');$duplicate->execute(['code'=>$code]);if((int)$duplicate->fetchColumn())$messages[]='Programme code already exists.';$data=['school_id'=>$schools[$schoolCode]??null,'department_id'=>null,'code'=>$code,'name'=>$name,'level'=>$level,'duration_semesters'=>$duration,'lateral_entry'=>$this->flag($source['lateral_entry']??'0'),'legacy'=>$this->flag($source['legacy']??'0'),'status'=>$status];$state=$messages?'invalid':'valid';$messages?$invalid++:$valid++;$insert->execute(['batch'=>$batch,'row'=>$index+2,'source'=>json_encode($source),'normalized'=>json_encode($data),'status'=>$state,'messages'=>json_encode($messages)]);}
        $this->pdo->prepare("UPDATE import_batches SET status='review',total_rows=:total,valid_rows=:valid,invalid_rows=:invalid WHERE id=:id")->execute(['total'=>count($rows),'valid'=>$valid,'invalid'=>$invalid,'id'=>$batch]);return $batch;
    }

    public function commit(int $batchId,int $userId): int
    {
        $q=$this->pdo->prepare("SELECT id FROM import_batches WHERE id=:id AND import_type='programmes' AND status='review' FOR UPDATE");$q->execute(['id'=>$batchId]);if(!$q->fetchColumn())throw new RuntimeException('Programme import is not available for commit.');$q=$this->pdo->prepare("SELECT * FROM import_rows WHERE import_batch_id=:id AND validation_status='valid' ORDER BY source_row_number");$q->execute(['id'=>$batchId]);$insert=$this->pdo->prepare('INSERT INTO programmes(school_id,department_id,code,name,level,duration_semesters,lateral_entry,legacy,status) VALUES(:school_id,:department_id,:code,:name,:level,:duration_semesters,:lateral_entry,:legacy,:status)');$count=0;foreach($q as $row){$data=json_decode($row['normalized_data'],true,flags:JSON_THROW_ON_ERROR);$insert->execute($data);$entity=(int)$this->pdo->lastInsertId();$this->pdo->prepare('UPDATE import_rows SET committed_entity_id=:entity WHERE id=:id')->execute(['entity'=>$entity,'id'=>$row['id']]);$count++;}$this->pdo->prepare("UPDATE import_batches SET status='committed',committed_at=NOW() WHERE id=:id")->execute(['id'=>$batchId]);$this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,'programme_import.committed','import_batch',:id,:data)")->execute(['user'=>$userId,'id'=>$batchId,'data'=>json_encode(['programmes_created'=>$count])]);return $count;
    }

    private function flag(string $value): int{return in_array(strtolower(trim($value)),['1','yes','true','y'],true)?1:0;}
    private function key(string $header):string{$key=trim(preg_replace('/[^a-z0-9]+/','_',strtolower(trim($header)))??'','_');return ['school'=>'school_code','branch_code'=>'programme_code','program_code'=>'programme_code','code'=>'programme_code','programme'=>'programme_name','program_name'=>'programme_name','name'=>'programme_name','programme_level'=>'level','duration'=>'duration_semesters','semesters'=>'duration_semesters'][$key]??$key;}
}
