<?php
declare(strict_types=1);
namespace App\Academic;

use PDO;
use RuntimeException;

final class StudentBulkDeletion
{
    public function __construct(private readonly PDO $pdo) {}

    public function options(): array
    {
        $options=['school'=>[],'department'=>[],'branch'=>[]];
        foreach($this->pdo->query('SELECT id,code,name FROM schools ORDER BY code') as $row)$options['school'][]=['value'=>(string)$row['id'],'label'=>$row['code'].' — '.$row['name']];
        foreach($this->pdo->query('SELECT d.id,d.code,d.name,s.code AS school FROM departments d JOIN schools s ON s.id=d.school_id ORDER BY s.code,d.code') as $row)$options['department'][]=['value'=>'id:'.$row['id'],'label'=>$row['school'].' / '.$row['code'].' — '.$row['name']];
        foreach($this->pdo->query('SELECT p.id,p.code,p.name,s.code AS school FROM programmes p JOIN schools s ON s.id=p.school_id ORDER BY s.code,p.code') as $row)$options['branch'][]=['value'=>'id:'.$row['id'],'label'=>$row['school'].' / '.$row['code'].' — '.$row['name']];
        foreach(['department'=>'department_name','branch'=>'branch'] as $scope=>$column)foreach($this->pdo->query("SELECT DISTINCT `$column` AS name FROM students WHERE `$column`<>'' ORDER BY `$column`") as $row)$options[$scope][]=['value'=>'name:'.$row['name'],'label'=>$row['name'].' (student-record name, all schools)'];
        return $options;
    }

    private function filter(string $scope,string $target): array
    {
        if($scope==='review'){
            if($target!=='')throw new RuntimeException('Review students must not include a separate target.');
            return ["s.parsing_status='review'",[],'Students marked Review (all schools, including unmapped students)'];
        }
        if($scope==='all'){
            if($target!=='')throw new RuntimeException('All students must not include a separate target.');
            return ['1=1',[],'All students in the database'];
        }
        if(!in_array($scope,['school','department','branch'],true)||$target==='')throw new RuntimeException('Choose a valid deletion scope and target.');
        $match=null;foreach($this->options()[$scope] as $option)if($option['value']===$target){$match=$option;break;}
        if(!$match)throw new RuntimeException('The selected filter no longer exists. Choose it again.');
        if($scope==='school')return ['p.school_id=?',[(int)$target],'School: '.$match['label']];
        if(str_starts_with($target,'id:'))return [$scope==='department'?'p.department_id=?':'s.programme_id=?',[(int)substr($target,3)],ucfirst($scope).': '.$match['label']];
        return ['s.'.($scope==='department'?'department_name':'branch').'=?',[substr($target,5)],ucfirst($scope).': '.$match['label']];
    }

    private function rows(string $where,array $params,?array $ids=null,bool $lock=false): array
    {
        $sql='SELECT s.id,s.roll_no_original,s.name,s.department_name,s.branch,s.school_name,p.code AS programme_code,sc.code AS school_code FROM students s LEFT JOIN programmes p ON p.id=s.programme_id LEFT JOIN schools sc ON sc.id=p.school_id WHERE '.$where;
        if($ids!==null){
            $rows=[];foreach(array_chunk($ids,500) as $chunk){$q=$this->pdo->prepare($sql.' AND s.id IN ('.implode(',',array_fill(0,count($chunk),'?')).') ORDER BY s.id'.($lock?' FOR UPDATE':''));$q->execute(array_merge($params,$chunk));array_push($rows,...$q->fetchAll(PDO::FETCH_ASSOC));}return $rows;
        }
        $q=$this->pdo->prepare($sql.' ORDER BY s.id');$q->execute($params);return $q->fetchAll(PDO::FETCH_ASSOC);
    }

    /** Match the protection already enforced by individual deletion and foreign keys. */
    private function protectedIds(array $ids): array
    {
        if(!$ids)return [];
        $q=$this->pdo->query("SELECT DISTINCT k.TABLE_NAME,k.COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE k JOIN information_schema.REFERENTIAL_CONSTRAINTS r ON r.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND r.TABLE_NAME=k.TABLE_NAME AND r.CONSTRAINT_NAME=k.CONSTRAINT_NAME WHERE k.CONSTRAINT_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='students' AND r.DELETE_RULE NOT IN ('CASCADE','SET NULL')");
        $references=$q->fetchAll(PDO::FETCH_ASSOC);$protected=[];
        foreach($references as $reference){$table=str_replace('`','``',$reference['TABLE_NAME']);$column=str_replace('`','``',$reference['COLUMN_NAME']);
            foreach(array_chunk($ids,500) as $chunk){$check=$this->pdo->prepare("SELECT DISTINCT `$column` FROM `$table` WHERE `$column` IN (".implode(',',array_fill(0,count($chunk),'?')).')');$check->execute($chunk);foreach($check->fetchAll(PDO::FETCH_COLUMN) as $id)$protected[(int)$id]=true;}
        }
        return $protected;
    }

    public function preview(string $scope,string $target): array
    {
        [$where,$params,$label]=$this->filter($scope,$target);$rows=$this->rows($where,$params);$ids=array_map('intval',array_column($rows,'id'));$protected=$this->protectedIds($ids);$sample=[];
        foreach(array_slice($rows,0,50) as $row)$sample[]=['roll'=>$row['roll_no_original'],'name'=>$row['name'],'school'=>$row['school_code']??$row['school_name'],'branch'=>$row['programme_code']??$row['branch'],'department'=>$row['department_name'],'protected'=>isset($protected[(int)$row['id']])];
        return ['scope'=>$scope,'target'=>$target,'label'=>$label,'ids'=>$ids,'matched'=>count($ids),'protected'=>count($protected),'deletable'=>count($ids)-count($protected),'sample'=>$sample];
    }

    public function delete(string $scope,string $target,array $previewedIds,int $actor): array
    {
        [$where,$params,$label]=$this->filter($scope,$target);
        $ids=array_values(array_unique(array_map('intval',$previewedIds)));if(!$ids||min($ids)<1)throw new RuntimeException('Preview the students before deleting.');sort($ids);
        $this->pdo->beginTransaction();
        try{
            // Only previewed IDs still belonging to the same scope can be deleted.
            $rows=$this->rows($where,$params,$ids,true);$current=array_map('intval',array_column($rows,'id'));$protected=$this->protectedIds($current);$deleted=array_values(array_filter($current,static fn(int $id):bool=>!isset($protected[$id])));
            foreach(array_chunk($deleted,500) as $chunk){$q=$this->pdo->prepare('DELETE FROM students WHERE id IN ('.implode(',',array_fill(0,count($chunk),'?')).')');$q->execute($chunk);}
            $result=['deleted'=>count($deleted),'protected'=>count($protected),'changed'=>count($ids)-count($current)];
            $audit=$this->pdo->prepare('INSERT INTO audit_logs(user_id,action,entity_type,old_values,new_values) VALUES(?,?,?,?,?)');
            $audit->execute([$actor,'students.bulk_deleted','student',json_encode(['scope'=>$scope,'target'=>$target,'label'=>$label,'student_ids'=>$deleted],JSON_THROW_ON_ERROR),json_encode($result,JSON_THROW_ON_ERROR)]);
            $this->pdo->commit();return $result;
        }catch(\Throwable $error){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $error;}
    }
}
