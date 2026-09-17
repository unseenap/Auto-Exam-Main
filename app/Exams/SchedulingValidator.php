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
        $params=array_merge($programmeIds,$semesters);$semesterMarks=implode(',',array_fill(0,count($semesters),'?'));
        $curriculum=$this->query("SELECT pc.id,pc.programme_id,pc.semester,pc.category,pc.subject_priority,c.code,c.name,c.status FROM programme_courses pc JOIN courses c ON c.id=pc.course_id WHERE pc.programme_id IN ({$marks}) AND pc.semester IN ({$semesterMarks})",$params);
        $excluded=count(array_filter($curriculum,static fn(array $item):bool=>WrittenPaperPolicy::isLab($item['name'])));
        $curriculum=array_values(array_filter($curriculum,static fn(array $item):bool=>!WrittenPaperPolicy::isLab($item['name'])));
        if($excluded)$add('Academic','pass','curriculum.labs_excluded',"{$excluded} lab/practical curriculum entries excluded from the written date sheet.");
        $expected=[];foreach($programmeIds as $programmeId)foreach($semesters as $semester)$expected[$programmeId.'-'.$semester]=0;foreach($curriculum as $item)$expected[$item['programme_id'].'-'.$item['semester']]++;
        $missing=array_keys(array_filter($expected,static fn(int $count):bool=>$count===0));
        $missing?$add('Academic','blocked','curriculum.missing','Written (non-lab) curriculum subjects are missing for '.count($missing).' selected programme-semester combinations.',['combinations'=>$missing]):$add('Academic','pass','curriculum.complete',count($curriculum).' curriculum papers are ready for scheduling.');
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
        $snapshot=['programme_ids'=>$programmeIds,'semesters'=>$semesters,'minimum_gap_days'=>$minimumGap,'maximum_papers_per_day'=>$maximumPerDay,'avoid_consecutive_days'=>!empty($scope['avoid_consecutive_days']),'use_subject_priority'=>!empty($scope['use_subject_priority'])];
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
