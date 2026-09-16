<?php

declare(strict_types=1);

namespace App\Exams;

use DateTimeImmutable;
use PDO;
use RuntimeException;

final class AutomaticScheduler
{
    public function __construct(private readonly PDO $pdo) {}

    public function generate(int $runId,int $userId):array
    {
        $this->pdo->beginTransaction();try{
        $run=$this->row("SELECT sr.*,ec.status AS cycle_status,ec.exam_type FROM scheduling_runs sr JOIN exam_cycles ec ON ec.id=sr.cycle_id WHERE sr.id=:id FOR UPDATE",['id'=>$runId]);
        if(!$run)throw new RuntimeException('Scheduling validation run not found.');
        if($run['status']!=='ready')throw new RuntimeException('Only a successful readiness run can generate a draft.');
        if($run['cycle_status']!=='draft')throw new RuntimeException('Automatic generation is allowed only while the examination cycle is in draft status.');
        $rules=json_decode($run['rule_snapshot'],true,flags:JSON_THROW_ON_ERROR);$programmeIds=array_map('intval',$rules['programme_ids']??[]);$semesters=array_map('intval',$rules['semesters']??[]);
        if(!$programmeIds||!$semesters)throw new RuntimeException('The validated scheduling scope is empty.');
        $programmeMarks=implode(',',array_fill(0,count($programmeIds),'?'));$semesterMarks=implode(',',array_fill(0,count($semesters),'?'));
        $summary=json_decode($run['validation_summary']??'{}',true)?:[];
        if(!empty($summary['regenerated_from'])){
            $previous=(int)$summary['regenerated_from'];
            $outside=$this->query("SELECT e.id FROM examinations e JOIN examination_cohorts ec ON ec.examination_id=e.id WHERE e.generated_by_run_id=? AND e.is_locked=0 AND (ec.programme_id NOT IN ({$programmeMarks}) OR ec.semester NOT IN ({$semesterMarks}))",array_merge([$previous],$programmeIds,$semesters));
            if($outside)throw new RuntimeException('A shared paper includes cohorts outside this regeneration scope. Preserve it with a lock before regenerating.');
            $this->pdo->prepare("DELETE FROM examinations WHERE generated_by_run_id=? AND is_locked=0 AND status='draft'")->execute([$previous]);
        }
        $taskParameters=array_merge($programmeIds,$semesters,[(int)$run['cycle_id']]);$tasks=$this->query("SELECT pc.id AS programme_course_id,pc.programme_id,pc.semester,pc.category,pc.subject_priority,c.id AS course_id,c.code,c.name,pc.mid_sem_duration_minutes,pc.end_sem_duration_minutes,p.code AS programme_code FROM programme_courses pc JOIN courses c ON c.id=pc.course_id JOIN programmes p ON p.id=pc.programme_id WHERE pc.programme_id IN ({$programmeMarks}) AND pc.semester IN ({$semesterMarks}) AND c.status='active' AND NOT EXISTS(SELECT 1 FROM examinations le JOIN examination_cohorts lc ON lc.examination_id=le.id WHERE le.cycle_id=? AND le.course_id=pc.course_id AND le.is_locked=1 AND le.status<>'cancelled' AND lc.programme_id=pc.programme_id AND lc.semester=pc.semester) ORDER BY pc.subject_priority ASC,CASE pc.category WHEN 'core' THEN 0 WHEN 'common' THEN 1 ELSE 2 END,p.code,pc.semester,c.code",$taskParameters);
        $tasks=array_values(array_filter($tasks,static fn(array $task):bool=>!WrittenPaperPolicy::isLab($task['name'])));
        $dates=$this->column('SELECT exam_date FROM exam_calendar_dates WHERE cycle_id=:cycle AND is_exam_day=1 ORDER BY exam_date',['cycle'=>$run['cycle_id']]);
        $shifts=$this->query('SELECT id,name,sequence_no,duration_minutes,start_time,end_time FROM exam_shifts WHERE cycle_id=:cycle ORDER BY sequence_no',['cycle'=>$run['cycle_id']]);
        if(!$tasks||!$dates||!$shifts)throw new RuntimeException('Validated curriculum, dates, or shifts are no longer available. Run validation again.');
        $minimumGap=max(0,(int)($rules['minimum_gap_days']??1));if(!empty($rules['avoid_consecutive_days']))$minimumGap=max(1,$minimumGap);$maximumPerDay=max(1,(int)($rules['maximum_papers_per_day']??1));
        $existing=$this->query("SELECT e.id AS examination_id,e.exam_date,e.shift_id,e.course_id,e.is_locked,e.category,e.status,ec.programme_id,ec.semester,(SELECT pc.id FROM programme_courses pc WHERE pc.programme_id=ec.programme_id AND pc.course_id=e.course_id AND pc.semester=ec.semester LIMIT 1) AS programme_course_id FROM examinations e JOIN examination_cohorts ec ON ec.examination_id=e.id WHERE e.cycle_id=:cycle AND e.status<>'cancelled'",['cycle'=>$run['cycle_id']]);
        $cohortDates=[];$cohortDaily=[];$occupied=[];$cohortSlots=[];$covered=[];$commonSlots=[];foreach($existing as $paper){$key=$paper['programme_id'].'-'.$paper['semester'];$cohortDates[$key][]=$paper['exam_date'];$cohortDaily[$key][$paper['exam_date']]=($cohortDaily[$key][$paper['exam_date']]??0)+1;$occupied[$paper['exam_date'].'-'.$paper['shift_id'].'-'.$paper['course_id']]=(int)$paper['examination_id'];$cohortSlots[$key][$paper['exam_date'].'-'.$paper['shift_id']]=true;if($paper['category']==='regular')$covered[$key.'-'.$paper['course_id']]=true;$commonSlots[$paper['course_id']][$paper['exam_date'].'-'.$paper['shift_id']]=true;if($paper['category']!=='regular'||$paper['status']!=='draft'||$paper['is_locked'])$commonSlots[$paper['course_id']]['unavailable']=true;}
        $tasks=array_values(array_filter($tasks,static fn(array $task):bool=>!isset($covered[$task['programme_id'].'-'.$task['semester'].'-'.$task['course_id']])));
        if(empty($rules['use_subject_priority']))usort($tasks,static fn(array $a,array $b):int=>strcmp($a['code'],$b['code'])?:strcmp($a['programme_code'],$b['programme_code']));
        $pendingByCourse=[];foreach($tasks as $task)$pendingByCourse[$task['course_id']][]=$task;
        $tasks=$pendingByCourse?array_merge(...array_values($pendingByCourse)):[];
        $scheduled=0;$unscheduled=0;$paperIds=[];
            $this->pdo->prepare("UPDATE scheduling_runs SET status='generating',completed_at=NULL WHERE id=:id")->execute(['id'=>$runId]);
            $addExam=$this->pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,category,status,generation_source,generated_by_run_id) VALUES(:cycle,:shift,:course,:date,'regular','draft','automatic',:run)");
            $addCohort=$this->pdo->prepare('INSERT INTO examination_cohorts(examination_id,programme_id,batch_id,semester,display_label) VALUES(:exam,:programme,NULL,:semester,:label)');
            $addItem=$this->pdo->prepare('INSERT INTO scheduling_run_items(scheduling_run_id,examination_id,programme_course_id,assigned_date,shift_id,item_status,score,reason) VALUES(:run,:exam,:curriculum,:date,:shift,:status,:score,:reason)');
            $addConflict=$this->pdo->prepare("INSERT INTO scheduling_conflicts(scheduling_run_id,severity,conflict_code,entity_type,entity_id,message,details) VALUES(:run,'blocked','generation.no_slot','programme_course',:entity,:message,:details)");
            foreach($existing as $fixed)if(in_array((int)$fixed['programme_id'],$programmeIds,true)&&in_array((int)$fixed['semester'],$semesters,true)&&$fixed['programme_course_id'])$addItem->execute(['run'=>$runId,'exam'=>$fixed['examination_id'],'curriculum'=>$fixed['programme_course_id'],'date'=>$fixed['exam_date'],'shift'=>$fixed['shift_id'],'status'=>$fixed['is_locked']?'locked':'scheduled','score'=>1000,'reason'=>'Existing placement preserved from the previous run.']);
            foreach($tasks as $task){
                $cohortKey=$task['programme_id'].'-'.$task['semester'];$chosen=null;$datePosition=0;
                foreach($dates as $date){$datePosition++;
                    foreach($shifts as $shift){
                        $slot=$date.'-'.$shift['id'];
                        $duration=max(array_column($pendingByCourse[$task['course_id']],$run['exam_type']==='mid_sem'?'mid_sem_duration_minutes':'end_sem_duration_minutes'));
                        if($duration>min((int)$shift['duration_minutes'],(strtotime($shift['end_time'])-strtotime($shift['start_time']))/60))continue;
                        if(isset($commonSlots[$task['course_id']]) && (count($commonSlots[$task['course_id']])!==1 || !isset($commonSlots[$task['course_id']][$slot])))continue;
                        $valid=true;
                        foreach($pendingByCourse[$task['course_id']] as $affected){
                            $key=$affected['programme_id'].'-'.$affected['semester'];
                            if(isset($covered[$key.'-'.$task['course_id']]))continue;
                            if(($cohortDaily[$key][$date]??0)>=$maximumPerDay||isset($cohortSlots[$key][$slot])){$valid=false;break;}
                            foreach($cohortDates[$key]??[] as $placed){
                                $difference=(int)(new DateTimeImmutable($date))->diff(new DateTimeImmutable($placed))->days;
                                if(($difference===0&&$minimumGap>0)||($difference>0&&$difference<=$minimumGap)){$valid=false;break;}
                            }
                            if(!$valid)break;
                        }
                        if($valid){$chosen=['date'=>$date,'shift_id'=>(int)$shift['id'],'score'=>1000-$datePosition*10-(int)$shift['sequence_no']];break;}
                    }
                    if($chosen)break;
                }
                if(!$chosen){$reason="No common date and shift satisfies all affected cohorts, paper duration, existing placements, the {$minimumGap}-day gap and daily-paper limit.";$addItem->execute(['run'=>$runId,'exam'=>null,'curriculum'=>$task['programme_course_id'],'date'=>null,'shift'=>null,'status'=>'unscheduled','score'=>null,'reason'=>$reason]);$addConflict->execute(['run'=>$runId,'entity'=>$task['programme_course_id'],'message'=>$task['programme_code'].' Semester '.$task['semester'].' '.$task['code'].' could not be scheduled.','details'=>json_encode(['reason'=>$reason])]);$unscheduled++;continue;}
                $slotKey=$chosen['date'].'-'.$chosen['shift_id'].'-'.$task['course_id'];
                if(isset($occupied[$slotKey])){$examId=$occupied[$slotKey];}else{$addExam->execute(['cycle'=>$run['cycle_id'],'shift'=>$chosen['shift_id'],'course'=>$task['course_id'],'date'=>$chosen['date'],'run'=>$runId]);$examId=(int)$this->pdo->lastInsertId();}$label=$task['programme_code'].' Semester '.$task['semester'];$addCohort->execute(['exam'=>$examId,'programme'=>$task['programme_id'],'semester'=>$task['semester'],'label'=>$label]);$addItem->execute(['run'=>$runId,'exam'=>$examId,'curriculum'=>$task['programme_course_id'],'date'=>$chosen['date'],'shift'=>$chosen['shift_id'],'status'=>'scheduled','score'=>$chosen['score'],'reason'=>'Earliest valid slot for this branch/semester. Different branches may use this session concurrently.']);
                $cohortDates[$cohortKey][]=$chosen['date'];$cohortDaily[$cohortKey][$chosen['date']]=($cohortDaily[$cohortKey][$chosen['date']]??0)+1;$occupied[$slotKey]=$examId;$covered[$cohortKey.'-'.$task['course_id']]=true;$cohortSlots[$cohortKey][$chosen['date'].'-'.$chosen['shift_id']]=true;$commonSlots[$task['course_id']][$chosen['date'].'-'.$chosen['shift_id']]=true;$paperIds[]=$examId;$scheduled++;
            }
            $this->pdo->prepare("UPDATE scheduling_runs SET status='generated',generated_paper_count=:count,completed_at=NOW() WHERE id=:id")->execute(['count'=>$scheduled,'id'=>$runId]);
            $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,'date_sheet.draft_generated','scheduling_run',:run,:data)")->execute(['user'=>$userId,'run'=>$runId,'data'=>json_encode(['scheduled'=>$scheduled,'unscheduled'=>$unscheduled,'paper_ids'=>$paperIds])]);$this->pdo->commit();
        }catch(\Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
        return compact('scheduled','unscheduled','paperIds');
    }

    private function row(string $sql,array $parameters):array|false{$q=$this->pdo->prepare($sql);$q->execute($parameters);return $q->fetch(PDO::FETCH_ASSOC);}
    private function query(string $sql,array $parameters):array{$q=$this->pdo->prepare($sql);$q->execute($parameters);return $q->fetchAll(PDO::FETCH_ASSOC);}
    private function column(string $sql,array $parameters):array{$q=$this->pdo->prepare($sql);$q->execute($parameters);return $q->fetchAll(PDO::FETCH_COLUMN);}
}
