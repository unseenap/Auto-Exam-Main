<?php

declare(strict_types=1);

namespace App\Exams;

use PDO;

/** Read-only, bounded queries for the course register. */
final class CourseRegister
{
    public function __construct(private readonly PDO $pdo) {}

    public function load(array $filters, array $programmes): array
    {
        $filterAvailability=[];
        foreach($this->pdo->query('SELECT DISTINCT programme_id,batch_id,semester FROM programme_courses WHERE batch_id IS NOT NULL') as $row){
            $filterAvailability[(int)$row['programme_id']][(int)$row['batch_id']][(int)$row['semester']]=true;
        }
        $ids=array_column($programmes,'id','code');
        $programmeFilter=is_scalar($filters['programme']??'')?(string)($filters['programme']??''):'';
        $batchFilter=max(0,(int)($filters['batch_id']??0));
        $semesterFilter=max(0,(int)($filters['semester']??0));
        if(!isset($ids[$programmeFilter])){
            $programmeFilter='';$batchFilter=0;$semesterFilter=0;
        }else{
            $available=$filterAvailability[(int)$ids[$programmeFilter]]??[];
            if(!isset($available[$batchFilter]))$batchFilter=0;
            $semesters=[];
            foreach($batchFilter?[$available[$batchFilter]]:$available as $values)$semesters+= $values;
            if(!isset($semesters[$semesterFilter]))$semesterFilter=0;
        }
        $from=' FROM programme_courses pc JOIN courses c ON c.id=pc.course_id JOIN programmes p ON p.id=pc.programme_id LEFT JOIN batches b ON b.id=pc.batch_id LEFT JOIN departments d ON d.id=p.department_id JOIN schools s ON s.id=p.school_id';
        $conditions=[];$params=[];
        if($programmeFilter!==''){$conditions[]='pc.programme_id=?';$params[]=(int)$ids[$programmeFilter];}
        if($batchFilter){$conditions[]='pc.batch_id=?';$params[]=$batchFilter;}
        if($semesterFilter){$conditions[]='pc.semester=?';$params[]=$semesterFilter;}
        $where=$conditions?' WHERE '.implode(' AND ',$conditions):'';
        $count=$this->pdo->prepare('SELECT COUNT(*)'.$from.$where);$count->execute($params);
        $total=(int)$count->fetchColumn();$pageSize=50;$pages=max(1,(int)ceil($total/$pageSize));
        $page=max(1,min($pages,(int)($filters['page']??1)));$offset=($page-1)*$pageSize;
        $query=$this->pdo->prepare('SELECT c.*,pc.id AS mapping_id,pc.batch_id,pc.semester,pc.section,pc.category,pc.course_credits,pc.course_level,pc.course_year,pc.mid_sem_duration_minutes,pc.end_sem_duration_minutes,pc.subject_priority,p.id AS programme_id,p.code AS programme_code,p.name AS programme_name,b.label AS batch_label,d.name AS department_name,s.short_name AS school_name'.$from.$where.' ORDER BY p.code,b.start_year,pc.semester,pc.section,pc.subject_priority,c.code,pc.id LIMIT '.$pageSize.' OFFSET '.$offset);
        $query->execute($params);
        $courseStats=$this->pdo->query('SELECT COUNT(*) AS mappings,COUNT(DISTINCT NULLIF(pc.batch_id,0)) AS batches,COUNT(DISTINCT c.id) AS subjects'.$from)->fetch(PDO::FETCH_ASSOC);
        return compact('filterAvailability','programmeFilter','batchFilter','semesterFilter','courseStats','total','page','pages','pageSize','offset')+['courses'=>$query->fetchAll(PDO::FETCH_ASSOC)];
    }
}
