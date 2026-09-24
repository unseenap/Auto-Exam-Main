<?php

declare(strict_types=1);

namespace App\Import;

use PDO;
use RuntimeException;

final class CourseImportService
{
    public function __construct(private readonly PDO $pdo) {}

    public function stage(string $path, string $originalName, int $userId): int
    {
        $rows=(new TabularReader())->read($path,strtolower(pathinfo($originalName,PATHINFO_EXTENSION)));
        if(count($rows)<2)throw new RuntimeException('The file must contain a header and at least one subject row.');
        $headers=array_map([$this,'key'],array_shift($rows));
        foreach(['course_code','course_name','programme_code','batch','semester'] as $required)if(!in_array($required,$headers,true))throw new RuntimeException("Missing required column: {$required}.");
        $programmes=[];foreach($this->pdo->query("SELECT id,code,duration_semesters FROM programmes WHERE status<>'inactive'") as $p)$programmes[strtoupper($p['code'])]=$p;
        $batches=[];foreach($this->pdo->query("SELECT b.id,b.programme_id,b.label FROM batches b WHERE b.status<>'inactive'") as $b)$batches[strtoupper($b['label'])]=$b;
        $q=$this->pdo->prepare("INSERT INTO import_batches(import_type,original_filename,stored_filename,status,uploaded_by) VALUES('courses',:original,:stored,'validating',:user)");
        $q->execute(['original'=>$originalName,'stored'=>basename($path),'user'=>$userId]);$batch=(int)$this->pdo->lastInsertId();$valid=0;$invalid=0;$seen=[];
        $insert=$this->pdo->prepare('INSERT INTO import_rows(import_batch_id,source_row_number,source_data,normalized_data,validation_status,validation_messages) VALUES(:batch,:row,:source,:normalized,:status,:messages)');
        foreach($rows as $index=>$values){$source=[];foreach($headers as $column=>$header)if($header!=='')$source[$header]=trim((string)($values[$column]??''));$messages=[];
            $code=strtoupper(trim($source['course_code']??''));$name=trim($source['course_name']??'');$programmeCode=strtoupper(trim($source['programme_code']??''));$batchLabel=strtoupper(trim($source['batch']??''));$semester=(int)($source['semester']??0);$section=strtoupper(trim($source['section']??''))?:'ALL';$category=strtolower(trim($source['category']??''))?:'core';$status=strtolower(trim($source['status']??''))?:'active';$priority=(int)($source['subject_priority']??50);$credits=(float)($source['course_credits']??0);$level=strtoupper(trim($source['course_level']??''))?:'UG';$year=(int)($source['course_year']??max(1,(int)ceil($semester/2)));$midMinutes=(int)round((float)($source['mid_sem_hours']??1.5)*60);$endMinutes=(int)round((float)($source['end_sem_hours']??3)*60);
            if($code==='')$messages[]='Course code is required.';if($name==='')$messages[]='Course name is required.';if(!preg_match('/^[A-Z0-9][A-Z0-9-]{1,39}$/',$code))$messages[]='Course code may contain letters, numbers, and hyphens.';
            $programme=$programmes[$programmeCode]??null;if(!$programme)$messages[]='Programme code was not found.';$max=(int)($programme['duration_semesters']??12)?:12;if($semester<1||$semester>$max)$messages[]="Semester must be between 1 and {$max} for this programme.";
            $courseBatch=$batches[$batchLabel]??null;if(!$courseBatch)$messages[]='Batch label was not found.';elseif($programme&&(int)$courseBatch['programme_id']!==(int)$programme['id'])$messages[]='Batch does not belong to the programme code.';
            if(!preg_match('/^[A-Z0-9-]{1,20}$/',$section))$messages[]='Section must contain only letters, numbers, or hyphens; use ALL for the complete batch.';if(!in_array($category,['core','elective','bridge','common','back_paper','other'],true))$messages[]='Invalid course category.';if(!in_array($status,['active','inactive'],true))$messages[]='Invalid status.';if($priority<1||$priority>100)$messages[]='Subject priority must be between 1 and 100.';if($credits<0||$credits>99.9)$messages[]='Course credits must be between 0 and 99.9.';if(!in_array($level,['UG','PG'],true))$messages[]='Course level must be UG or PG.';if($year<1||$year>6)$messages[]='Course year must be between 1 and 6.';if($midMinutes<30||$midMinutes>360)$messages[]='Mid-semester exam hours must be between 0.5 and 6.';if($endMinutes<30||$endMinutes>480)$messages[]='End-semester exam hours must be between 0.5 and 8.';
            $unique=$programmeCode.'|'.$batchLabel.'|'.$semester.'|'.$section.'|'.$code;if(isset($seen[$unique]))$messages[]='This programme, batch, semester, section, and course is duplicated in the file.';$seen[$unique]=true;
            $data=['code'=>$code,'name'=>$name,'programme_id'=>(int)($programme['id']??0),'programme_code'=>$programmeCode,'batch_id'=>(int)($courseBatch['id']??0),'batch_label'=>$courseBatch['label']??$batchLabel,'semester'=>$semester,'section'=>$section,'category'=>$category,'status'=>$status,'subject_priority'=>$priority,'course_credits'=>$credits,'course_level'=>$level,'course_year'=>$year,'mid_sem_duration_minutes'=>$midMinutes,'end_sem_duration_minutes'=>$endMinutes];
            $validation=$messages?'invalid':'valid';$messages?$invalid++:$valid++;$insert->execute(['batch'=>$batch,'row'=>$index+2,'source'=>json_encode($source),'normalized'=>json_encode($data),'status'=>$validation,'messages'=>json_encode($messages)]);
        }
        $this->pdo->prepare("UPDATE import_batches SET status='review',total_rows=:total,valid_rows=:valid,invalid_rows=:invalid WHERE id=:id")->execute(['total'=>count($rows),'valid'=>$valid,'invalid'=>$invalid,'id'=>$batch]);return $batch;
    }

    public function commit(int $batchId,int $userId): int
    {
        $q=$this->pdo->prepare("SELECT * FROM import_batches WHERE id=:id AND import_type='courses' AND status='review' FOR UPDATE");$q->execute(['id'=>$batchId]);if(!$q->fetch())throw new RuntimeException('Course import is not available for commit.');
        $q=$this->pdo->prepare("SELECT * FROM import_rows WHERE import_batch_id=:id AND validation_status='valid' ORDER BY source_row_number");$q->execute(['id'=>$batchId]);$count=0;
        foreach($q as $row){$data=json_decode($row['normalized_data'],true,flags:JSON_THROW_ON_ERROR);$find=$this->pdo->prepare('SELECT id FROM courses WHERE code=:code');$find->execute(['code'=>$data['code']]);$courseId=(int)$find->fetchColumn();
            if(!$courseId){$add=$this->pdo->prepare('INSERT INTO courses(code,name,status) VALUES(:code,:name,:status)');$add->execute(['code'=>$data['code'],'name'=>$data['name'],'status'=>$data['status']]);$courseId=(int)$this->pdo->lastInsertId();}
            else{$this->pdo->prepare('UPDATE courses SET name=:name,status=:status WHERE id=:id')->execute(['name'=>$data['name'],'status'=>$data['status'],'id'=>$courseId]);}
            $map=$this->pdo->prepare('INSERT INTO programme_courses(programme_id,batch_id,course_id,semester,section,category,course_credits,course_level,course_year,mid_sem_duration_minutes,end_sem_duration_minutes,subject_priority) VALUES(:programme,:batch,:course,:semester,:section,:category,:credits,:level,:year,:mid,:end,:priority) ON DUPLICATE KEY UPDATE category=VALUES(category),course_credits=VALUES(course_credits),course_level=VALUES(course_level),course_year=VALUES(course_year),mid_sem_duration_minutes=VALUES(mid_sem_duration_minutes),end_sem_duration_minutes=VALUES(end_sem_duration_minutes),subject_priority=VALUES(subject_priority)');$map->execute(['programme'=>$data['programme_id'],'batch'=>$data['batch_id'],'course'=>$courseId,'semester'=>$data['semester'],'section'=>$data['section'],'category'=>$data['category'],'credits'=>$data['course_credits'],'level'=>$data['course_level'],'year'=>$data['course_year'],'mid'=>$data['mid_sem_duration_minutes'],'end'=>$data['end_sem_duration_minutes'],'priority'=>$data['subject_priority']]);
            $this->pdo->prepare('UPDATE import_rows SET committed_entity_id=:entity WHERE id=:id')->execute(['entity'=>$courseId,'id'=>$row['id']]);$count++;}
        $this->pdo->prepare("UPDATE import_batches SET status='committed',committed_at=NOW() WHERE id=:id")->execute(['id'=>$batchId]);
        $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,'course_import.committed','import_batch',:id,:data)")->execute(['user'=>$userId,'id'=>$batchId,'data'=>json_encode(['curriculum_rows_created'=>$count])]);return $count;
    }

    private function key(string $header):string{$key=trim(preg_replace('/[^a-z0-9]+/','_',strtolower(trim($header)))??'','_');return ['subject_code'=>'course_code','subject_name'=>'course_name','branch_code'=>'programme_code','programme'=>'programme_code','branch'=>'programme_code','batch_label'=>'batch','admission_batch'=>'batch','sem'=>'semester','type'=>'category','credits'=>'course_credits','course_ug_pg'=>'course_level','ug_pg'=>'course_level','year'=>'course_year','mid_sem_exam_hours'=>'mid_sem_hours','end_sem_exam_hours'=>'end_sem_hours'][$key]??$key;}
}
