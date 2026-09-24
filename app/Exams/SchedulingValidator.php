<?php

declare(strict_types=1);

namespace App\Exams;

use PDO;
use RuntimeException;

final class SchedulingValidator
{
    public function __construct(private readonly PDO $pdo) {}

    public function validate(array $scope, int $userId, bool $persist = true): array
    {
        $cycleId=(int)($scope['cycle_id']??0);$schoolId=(int)($scope['school_id']??0);
        $programmeIds=array_values(array_unique(array_filter(array_map('intval',$scope['programme_ids']??[]))));
        $semesters=array_values(array_unique(array_filter(array_map('intval',$scope['semesters']??[]),static fn(int $value):bool=>$value>=1&&$value<=12)));
        $minimumGap=max(0,min(14,(int)($scope['minimum_gap_days']??1)));$maximumPerDay=max(1,min(3,(int)($scope['maximum_papers_per_day']??1)));if(!empty($scope['avoid_consecutive_days']))$minimumGap=max(1,$minimumGap);
        if($cycleId<1||$schoolId<1||!$programmeIds||!$semesters)throw new RuntimeException('Select a cycle, school, at least one programme, and at least one semester.');
        $cycle=$this->row('SELECT * FROM exam_cycles WHERE id=:id',['id'=>$cycleId]);if(!$cycle)throw new RuntimeException('Examination cycle not found.');
        $marks=implode(',',array_fill(0,count($programmeIds),'?'));$programmes=$this->query("SELECT id,code,name,school_id,duration_semesters FROM programmes WHERE id IN ({$marks}) AND status='active'",$programmeIds);
        $checks=[];$add=static function(string $group,string $state,string $code,string $message,array $details=[])use(&$checks):void{$checks[]=compact('group','state','code','message','details');};
        if(count($programmes)!==count($programmeIds)||array_filter($programmes,static fn(array $p):bool=>(int)$p['school_id']!==$schoolId))$add('Academic','blocked','scope.programmes','One or more selected programmes do not belong to the selected school.');else $add('Academic','pass','scope.programmes',count($programmes).' selected programmes belong to this school.');
        $cycleBatchRows=$this->query("SELECT b.id,b.programme_id,b.label FROM exam_cycle_batches ecb JOIN batches b ON b.id=ecb.batch_id WHERE ecb.cycle_id=? AND b.status<>'inactive'",[$cycleId]);$cycleProgrammeIds=array_values(array_unique(array_map('intval',array_column($cycleBatchRows,'programme_id'))));$outsideBatches=array_diff($programmeIds,$cycleProgrammeIds);
        if(!$cycleBatchRows)$add('Academic','warning','scope.batches','This is a legacy examination cycle without batch assignments. New cycles require batches before creation.');elseif($outsideBatches)$add('Academic','blocked','scope.batches','One or more selected programmes do not have an assigned batch in this examination cycle.');else $add('Academic','pass','scope.batches',count($cycleBatchRows).' student batch'.(count($cycleBatchRows)===1?' is':'es are').' included in this cycle.');
        $selectedBatches=array_values(array_filter($cycleBatchRows,static fn(array $batch):bool=>in_array((int)$batch['programme_id'],$programmeIds,true)));$selectedBatchIds=array_map('intval',array_column($selectedBatches,'id'));
        $params=array_merge($programmeIds,$semesters);$semesterMarks=implode(',',array_fill(0,count($semesters),'?'));$batchClause='';
        if($selectedBatchIds){$batchClause=' AND (pc.batch_id IN ('.implode(',',array_fill(0,count($selectedBatchIds),'?')).') OR pc.batch_id IS NULL)';$params=array_merge($params,$selectedBatchIds);}
        $curriculum=$this->query("SELECT pc.id,pc.programme_id,pc.batch_id,pc.semester,pc.section,pc.category,pc.subject_priority,c.code,c.name,c.status,b.label AS batch_label FROM programme_courses pc JOIN courses c ON c.id=pc.course_id LEFT JOIN batches b ON b.id=pc.batch_id WHERE pc.programme_id IN ({$marks}) AND pc.semester IN ({$semesterMarks}){$batchClause}",$params);
        $excluded=count(array_filter($curriculum,static fn(array $item):bool=>WrittenPaperPolicy::isLab($item['name'])));
        $curriculum=array_values(array_filter($curriculum,static fn(array $item):bool=>!WrittenPaperPolicy::isLab($item['name'])));
        if($excluded)$add('Academic','pass','curriculum.labs_excluded',"{$excluded} lab/practical curriculum entries excluded from the written date sheet.");
        $selectedCourseIds=array_values(array_unique(array_filter(array_map('intval',$scope['programme_course_ids']??[]))));
        if(!empty($scope['subject_selection_active'])){
            $availableIds=array_map('intval',array_column($curriculum,'id'));$invalidIds=array_diff($selectedCourseIds,$availableIds);
            if($invalidIds)$add('Academic','blocked','curriculum.selection_invalid','One or more selected subjects do not belong to the selected branch and semester scope. Refresh the page and select again.');
            $curriculum=array_values(array_filter($curriculum,static fn(array $item):bool=>in_array((int)$item['id'],$selectedCourseIds,true)));
            if(!$selectedCourseIds)$add('Academic','blocked','curriculum.selection_empty','Select at least one written subject for automatic scheduling.');
        }
        $expected=[];$batchesByProgramme=[];foreach($selectedBatches as $batch)$batchesByProgramme[(int)$batch['programme_id']][]=$batch;
        $targets=$selectedBatches?:array_map(static fn(int $programmeId):array=>['id'=>null,'programme_id'=>$programmeId,'label'=>(string)$programmeId],$programmeIds);foreach($targets as $batch)foreach($semesters as $semester){$sections=[];foreach($curriculum as $item)if((int)$item['programme_id']===(int)$batch['programme_id']&&(int)$item['semester']===$semester&&(!$item['batch_id']||(int)$item['batch_id']===(int)$batch['id']))$sections[]=$item['section'];$sections=array_values(array_unique($sections?:['ALL']));foreach($sections as $section)$expected[$batch['label'].'-semester-'.$semester.'-section-'.$section]=0;}
        foreach($curriculum as $item){if($item['batch_id']){$key=($item['batch_label']?:$item['programme_id']).'-semester-'.$item['semester'].'-section-'.$item['section'];if(array_key_exists($key,$expected))$expected[$key]++;continue;}foreach($batchesByProgramme[(int)$item['programme_id']]??[['label'=>$item['programme_id']]] as $batch){$key=$batch['label'].'-semester-'.$item['semester'].'-section-'.$item['section'];if(array_key_exists($key,$expected))$expected[$key]++;}}
        $missing=array_keys(array_filter($expected,static fn(int $count):bool=>$count===0));
        $missing?$add('Academic','blocked','curriculum.missing','Written (non-lab) curriculum subjects are missing for '.count($missing).' selected batch-semester combinations.',['combinations'=>$missing]):$add('Academic','pass','curriculum.complete',count($curriculum).' batch curriculum papers are ready for scheduling.');
        $registrationPapers=array_filter($curriculum,static fn(array $item):bool=>in_array($item['category'],['elective','back_paper'],true));if($registrationPapers)$add('Academic','warning','registration.required','Elective and back-paper registrations are handled after date-sheet scheduling. No student records are required to generate the draft.');
        $invalidPriority=array_filter($curriculum,static fn(array $item):bool=>(int)$item['subject_priority']<1||(int)$item['subject_priority']>100);
        $invalidPriority?$add('Academic','blocked','priority.invalid','Some subjects have an invalid scheduling priority.'):$add('Academic','pass','priority.valid','All selected subjects have priorities from 1 to 100.');
        $inactive=array_filter($curriculum,static fn(array $item):bool=>$item['status']!=='active');$inactive?$add('Academic','blocked','courses.inactive',count($inactive).' selected curriculum subjects are inactive.'):$add('Academic','pass','courses.active','All selected curriculum subjects are active.');
        $examDays=(int)$this->value('SELECT COUNT(*) FROM exam_calendar_dates WHERE cycle_id=:cycle AND is_exam_day=1',['cycle'=>$cycleId]);$shifts=(int)$this->value('SELECT COUNT(*) FROM exam_shifts WHERE cycle_id=:cycle',['cycle'=>$cycleId]);
        $examDays>0?$add('Calendar','pass','calendar.days',"{$examDays} enabled examination days are available."):$add('Calendar','blocked','calendar.days','No examination days remain after exclusions.');
        $shifts>0?$add('Calendar','pass','calendar.shifts',"{$shifts} examination shifts are configured."):$add('Calendar','blocked','calendar.shifts','This cycle has no examination shifts.');
        $required=count($curriculum);$preferredCapacity=$examDays*min($shifts,$maximumPerDay);$absoluteCapacity=$examDays*$shifts;$largest=max($expected?:[0]);
        if($absoluteCapacity<$largest)$add('Feasibility','blocked','slots.capacity',"The calendar has only {$absoluteCapacity} actual date-and-shift positions per branch/semester for {$largest} required papers. Add exam days or shifts.");
        elseif($preferredCapacity<$largest)$add('Feasibility','warning','slots.capacity',"The preferred daily limit provides {$preferredCapacity} positions for {$largest} papers. The scheduler will use additional configured shifts on the busiest days so every paper fits.");
        else $add('Feasibility','pass','slots.capacity',"{$preferredCapacity} preferred positions are available independently for each branch/semester. Different branches may schedule different subjects in the same session ({$required} branch-subject entries total).");
        $enabled=$this->query('SELECT exam_date FROM exam_calendar_dates WHERE cycle_id=? AND is_exam_day=1 ORDER BY exam_date',[$cycleId]);$last=null;$gapSlots=0;
        foreach($enabled as $day){if($last===null||(int)(new \DateTimeImmutable($last))->diff(new \DateTimeImmutable($day['exam_date']))->days>=$minimumGap+1){$gapSlots++;$last=$day['exam_date'];}}
        if($minimumGap===0)$gapSlots*=min($shifts,$maximumPerDay);
        $gapSlots>=$largest?$add('Feasibility','pass','gap.window','Enabled dates can accommodate every paper with the requested rest gap.'):$add('Feasibility','warning','gap.window',"Only {$gapSlots} fully separated positions are available for {$largest} papers. The scheduler will preserve as many gaps as possible for higher-priority subjects, then use consecutive working days so no valid paper is omitted.");
        $existing=(int)$this->value("SELECT COUNT(*) FROM examinations WHERE cycle_id=:cycle AND status<>'cancelled'",['cycle'=>$cycleId]);if($existing)$add('Feasibility','warning','papers.existing',"{$existing} examination records already exist and will be preserved. New branches still receive separate date-sheet rows; different branches may use the same date and shift.");else $add('Feasibility','pass','papers.existing','No existing papers need to be preserved. Each selected branch will receive its own date-sheet row.');
        $blocked=count(array_filter($checks,static fn(array $check):bool=>$check['state']==='blocked'));$warnings=count(array_filter($checks,static fn(array $check):bool=>$check['state']==='warning'));$status=$blocked?'failed':'ready';
        $snapshot=['programme_ids'=>$programmeIds,'semesters'=>$semesters,'programme_course_ids'=>array_map('intval',array_column($curriculum,'id')),'subject_selection_active'=>!empty($scope['subject_selection_active']),'minimum_gap_days'=>$minimumGap,'maximum_papers_per_day'=>$maximumPerDay,'avoid_consecutive_days'=>!empty($scope['avoid_consecutive_days']),'use_subject_priority'=>!empty($scope['use_subject_priority'])];
        $runId=null;
        if($persist){$this->pdo->beginTransaction();try{$rule=$this->pdo->prepare('INSERT INTO scheduling_rules(cycle_id,school_id,minimum_gap_days,maximum_papers_per_day,avoid_consecutive_days,use_subject_priority,created_by) VALUES(:cycle,:school,:gap,:maximum,:avoid,:priority,:user) ON DUPLICATE KEY UPDATE minimum_gap_days=VALUES(minimum_gap_days),maximum_papers_per_day=VALUES(maximum_papers_per_day),avoid_consecutive_days=VALUES(avoid_consecutive_days),use_subject_priority=VALUES(use_subject_priority),created_by=VALUES(created_by)');$rule->execute(['cycle'=>$cycleId,'school'=>$schoolId,'gap'=>$minimumGap,'maximum'=>$maximumPerDay,'avoid'=>$snapshot['avoid_consecutive_days']?1:0,'priority'=>$snapshot['use_subject_priority']?1:0,'user'=>$userId]);
            $run=$this->pdo->prepare('INSERT INTO scheduling_runs(cycle_id,school_id,status,rule_snapshot,validation_summary,created_by,completed_at) VALUES(:cycle,:school,:status,:rules,:summary,:user,NOW())');$run->execute(['cycle'=>$cycleId,'school'=>$schoolId,'status'=>$status,'rules'=>json_encode($snapshot,JSON_THROW_ON_ERROR),'summary'=>json_encode(['blocked'=>$blocked,'warnings'=>$warnings,'checks'=>$checks],JSON_THROW_ON_ERROR),'user'=>$userId]);$runId=(int)$this->pdo->lastInsertId();
            $conflict=$this->pdo->prepare('INSERT INTO scheduling_conflicts(scheduling_run_id,severity,conflict_code,message,details) VALUES(:run,:severity,:code,:message,:details)');foreach($checks as $check)$conflict->execute(['run'=>$runId,'severity'=>$check['state'],'code'=>$check['code'],'message'=>$check['message'],'details'=>$check['details']?json_encode($check['details']):null]);
            $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,'date_sheet.validation_completed','scheduling_run',:run,:data)")->execute(['user'=>$userId,'run'=>$runId,'data'=>json_encode(['cycle_id'=>$cycleId,'school_id'=>$schoolId,'blocked'=>$blocked,'warnings'=>$warnings])]);$this->pdo->commit();
        }catch(\Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}}
        return ['run_id'=>$runId,'status'=>$status,'blocked'=>$blocked,'warnings'=>$warnings,'checks'=>$checks,'scope'=>$snapshot];
    }

    private function row(string $sql,array $parameters):array|false{$statement=$this->pdo->prepare($sql);$statement->execute($parameters);return $statement->fetch(PDO::FETCH_ASSOC);}
    private function query(string $sql,array $parameters):array{$statement=$this->pdo->prepare($sql);$statement->execute($parameters);return $statement->fetchAll(PDO::FETCH_ASSOC);}
    private function value(string $sql,array $parameters):mixed{$statement=$this->pdo->prepare($sql);$statement->execute($parameters);return $statement->fetchColumn();}
}
