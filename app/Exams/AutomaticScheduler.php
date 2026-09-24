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
        $cycleBatches=$this->query("SELECT b.id,b.programme_id,b.label FROM exam_cycle_batches ecb JOIN batches b ON b.id=ecb.batch_id WHERE ecb.cycle_id=:cycle AND b.status<>'inactive' ORDER BY b.start_year",['cycle'=>$run['cycle_id']]);$batchesByProgramme=[];foreach($cycleBatches as $batch)$batchesByProgramme[(int)$batch['programme_id']][]=$batch;
        $programmeMarks=implode(',',array_fill(0,count($programmeIds),'?'));$semesterMarks=implode(',',array_fill(0,count($semesters),'?'));
        $summary=json_decode($run['validation_summary']??'{}',true)?:[];
        if(!empty($summary['regenerated_from'])){
            $previous=(int)$summary['regenerated_from'];
            $outside=$this->query("SELECT e.id FROM examinations e JOIN examination_cohorts ec ON ec.examination_id=e.id WHERE e.generated_by_run_id=? AND e.is_locked=0 AND (ec.programme_id NOT IN ({$programmeMarks}) OR ec.semester NOT IN ({$semesterMarks}))",array_merge([$previous],$programmeIds,$semesters));
            if($outside)throw new RuntimeException('A shared paper includes cohorts outside this regeneration scope. Preserve it with a lock before regenerating.');
            $this->pdo->prepare("DELETE FROM examinations WHERE generated_by_run_id=? AND is_locked=0 AND status='draft'")->execute([$previous]);
        }
        $selectedCourseIds=array_values(array_unique(array_filter(array_map('intval',$rules['programme_course_ids']??[]))));$courseClause='';$courseParameters=[];
        if(!empty($rules['subject_selection_active'])){if(!$selectedCourseIds)throw new RuntimeException('This scheduling run has no selected subjects. Validate the scope again.');$courseClause=' AND pc.id IN ('.implode(',',array_fill(0,count($selectedCourseIds),'?')).')';$courseParameters=$selectedCourseIds;}
        $cycleBatchIds=array_map('intval',array_column($cycleBatches,'id'));$batchClause='';$batchParameters=[];if($cycleBatchIds){$batchClause=' AND (pc.batch_id IN ('.implode(',',array_fill(0,count($cycleBatchIds),'?')).') OR pc.batch_id IS NULL)';$batchParameters=$cycleBatchIds;}
        $taskParameters=array_merge($programmeIds,$semesters,$courseParameters,$batchParameters,[(int)$run['cycle_id']]);$tasks=$this->query("SELECT pc.id AS programme_course_id,pc.programme_id,pc.batch_id AS curriculum_batch_id,pc.semester,pc.section,pc.category,pc.subject_priority,c.id AS course_id,c.code,c.name,pc.mid_sem_duration_minutes,pc.end_sem_duration_minutes,p.code AS programme_code,b.label AS curriculum_batch_label FROM programme_courses pc JOIN courses c ON c.id=pc.course_id JOIN programmes p ON p.id=pc.programme_id LEFT JOIN batches b ON b.id=pc.batch_id WHERE pc.programme_id IN ({$programmeMarks}) AND pc.semester IN ({$semesterMarks}){$courseClause}{$batchClause} AND c.status='active' AND NOT EXISTS(SELECT 1 FROM examinations le JOIN examination_cohorts lc ON lc.examination_id=le.id WHERE le.cycle_id=? AND le.course_id=pc.course_id AND le.is_locked=1 AND le.status<>'cancelled' AND lc.programme_id=pc.programme_id AND lc.semester=pc.semester AND lc.section=pc.section AND (pc.batch_id IS NULL OR lc.batch_id=pc.batch_id)) ORDER BY pc.subject_priority ASC,CASE pc.category WHEN 'core' THEN 0 WHEN 'common' THEN 1 ELSE 2 END,p.code,b.start_year,pc.semester,pc.section,c.code",$taskParameters);
        $expanded=[];foreach($tasks as $task){if($task['curriculum_batch_id']){$task['effective_batch_id']=(int)$task['curriculum_batch_id'];$task['batch_label']=$task['curriculum_batch_label'];$expanded[]=$task;continue;}foreach($batchesByProgramme[(int)$task['programme_id']]??[['id'=>null,'label'=>$task['programme_code']]] as $batch){$copy=$task;$copy['effective_batch_id']=$batch['id']?(int)$batch['id']:null;$copy['batch_label']=$batch['label'];$expanded[]=$copy;}}$tasks=$expanded;
        $tasks=array_values(array_filter($tasks,static fn(array $task):bool=>!WrittenPaperPolicy::isLab($task['name'])));
        $dates=$this->column('SELECT exam_date FROM exam_calendar_dates WHERE cycle_id=:cycle AND is_exam_day=1 ORDER BY exam_date',['cycle'=>$run['cycle_id']]);
        $shifts=$this->query('SELECT id,name,sequence_no,duration_minutes,start_time,end_time FROM exam_shifts WHERE cycle_id=:cycle ORDER BY sequence_no',['cycle'=>$run['cycle_id']]);
        if(!$tasks||!$dates||!$shifts)throw new RuntimeException('Validated curriculum, dates, or shifts are no longer available. Run validation again.');
        $minimumGap=max(0,(int)($rules['minimum_gap_days']??1));if(!empty($rules['avoid_consecutive_days']))$minimumGap=max(1,$minimumGap);$maximumPerDay=max(1,(int)($rules['maximum_papers_per_day']??1));
        $existing=$this->query("SELECT e.id AS examination_id,e.exam_date,e.shift_id,e.course_id,e.is_locked,e.category,e.status,ec.programme_id,ec.batch_id,ec.semester,ec.section,(SELECT pc.id FROM programme_courses pc WHERE pc.programme_id=ec.programme_id AND pc.course_id=e.course_id AND pc.semester=ec.semester AND pc.section=ec.section AND (pc.batch_id=ec.batch_id OR pc.batch_id IS NULL) ORDER BY (pc.batch_id=ec.batch_id) DESC LIMIT 1) AS programme_course_id FROM examinations e JOIN examination_cohorts ec ON ec.examination_id=e.id WHERE e.cycle_id=:cycle AND e.status<>'cancelled'",['cycle'=>$run['cycle_id']]);
        $cohortDates=[];$cohortDaily=[];$occupied=[];$cohortSlots=[];$covered=[];$commonSlots=[];foreach($existing as $paper){$key=$paper['programme_id'].'-'.($paper['batch_id']??'legacy').'-'.$paper['semester'].'-'.$paper['section'];$cohortDates[$key][]=$paper['exam_date'];$cohortDaily[$key][$paper['exam_date']]=($cohortDaily[$key][$paper['exam_date']]??0)+1;$occupied[$paper['exam_date'].'-'.$paper['shift_id'].'-'.$paper['course_id']]=(int)$paper['examination_id'];$cohortSlots[$key][$paper['exam_date'].'-'.$paper['shift_id']]=true;if($paper['category']==='regular')$covered[$key.'-'.$paper['course_id']]=true;$commonSlots[$paper['course_id']][$paper['exam_date'].'-'.$paper['shift_id']]=true;if($paper['category']!=='regular'||$paper['status']!=='draft'||$paper['is_locked'])$commonSlots[$paper['course_id']]['unavailable']=true;}
        $tasks=array_values(array_filter($tasks,static fn(array $task):bool=>!isset($covered[$task['programme_id'].'-'.($task['effective_batch_id']??'legacy').'-'.$task['semester'].'-'.$task['section'].'-'.$task['course_id']])));
        if(empty($rules['use_subject_priority']))usort($tasks,static fn(array $a,array $b):int=>strcmp($a['code'],$b['code'])?:strcmp($a['programme_code'],$b['programme_code']));
        $pendingByCourse=[];foreach($tasks as $task)$pendingByCourse[$task['course_id']][]=$task;
        $tasks=$pendingByCourse?array_merge(...array_values($pendingByCourse)):[];
        $scheduled=0;$unscheduled=0;$paperIds=[];
            $this->pdo->prepare("UPDATE scheduling_runs SET status='generating',completed_at=NULL WHERE id=:id")->execute(['id'=>$runId]);
            $addExam=$this->pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,category,status,generation_source,generated_by_run_id) VALUES(:cycle,:shift,:course,:date,'regular','draft','automatic',:run)");
            $addCohort=$this->pdo->prepare('INSERT IGNORE INTO examination_cohorts(examination_id,programme_id,batch_id,semester,section,display_label) VALUES(:exam,:programme,:batch,:semester,:section,:label)');
            $addItem=$this->pdo->prepare('INSERT INTO scheduling_run_items(scheduling_run_id,examination_id,programme_course_id,assigned_date,shift_id,item_status,score,reason) VALUES(:run,:exam,:curriculum,:date,:shift,:status,:score,:reason)');
            $addConflict=$this->pdo->prepare("INSERT INTO scheduling_conflicts(scheduling_run_id,severity,conflict_code,entity_type,entity_id,message,details) VALUES(:run,'blocked','generation.no_slot','programme_course',:entity,:message,:details)");
            foreach($existing as $fixed)if(in_array((int)$fixed['programme_id'],$programmeIds,true)&&in_array((int)$fixed['semester'],$semesters,true)&&$fixed['programme_course_id'])$addItem->execute(['run'=>$runId,'exam'=>$fixed['examination_id'],'curriculum'=>$fixed['programme_course_id'],'date'=>$fixed['exam_date'],'shift'=>$fixed['shift_id'],'status'=>$fixed['is_locked']?'locked':'scheduled','score'=>1000,'reason'=>'Existing placement preserved from the previous run.']);
            foreach($tasks as $task){
                $cohortKey=$task['programme_id'].'-'.($task['effective_batch_id']??'legacy').'-'.$task['semester'].'-'.$task['section'];$chosen=null;$datePosition=0;
                // Preferences are relaxed progressively, but the hard rule remains:
                // one paper per cohort in a single date/shift position.
                $strategies=[['gap'=>$minimumGap,'daily'=>$maximumPerDay]];
                if($minimumGap>0)$strategies[]=['gap'=>0,'daily'=>$maximumPerDay];
                $physicalDailyCapacity=count($shifts);
                if($physicalDailyCapacity>$maximumPerDay)$strategies[]=['gap'=>0,'daily'=>$physicalDailyCapacity];
                foreach($strategies as $strategy){$appliedGap=$strategy['gap'];$appliedDailyMaximum=$strategy['daily'];
                  $datePosition=0;
                  foreach($dates as $date){$datePosition++;
                    foreach($shifts as $shift){
                        $slot=$date.'-'.$shift['id'];
                        $duration=max(array_column($pendingByCourse[$task['course_id']],$run['exam_type']==='mid_sem'?'mid_sem_duration_minutes':'end_sem_duration_minutes'));
                        if($duration>min((int)$shift['duration_minutes'],(strtotime($shift['end_time'])-strtotime($shift['start_time']))/60))continue;
                        if(isset($commonSlots[$task['course_id']]) && (count($commonSlots[$task['course_id']])!==1 || !isset($commonSlots[$task['course_id']][$slot])))continue;
                        $valid=true;
                        foreach($pendingByCourse[$task['course_id']] as $affected){
                            $key=$affected['programme_id'].'-'.($affected['effective_batch_id']??'legacy').'-'.$affected['semester'].'-'.$affected['section'];
                            if(isset($covered[$key.'-'.$task['course_id']]))continue;
                            if(($cohortDaily[$key][$date]??0)>=$appliedDailyMaximum||isset($cohortSlots[$key][$slot])){$valid=false;break;}
                            foreach($cohortDates[$key]??[] as $placed){
                                $difference=(int)(new DateTimeImmutable($date))->diff(new DateTimeImmutable($placed))->days;
                                if(($difference===0&&$appliedGap>0)||($difference>0&&$difference<=$appliedGap)){$valid=false;break;}
                            }
                            if(!$valid)break;
                        }
                        if($valid){$chosen=['date'=>$date,'shift_id'=>(int)$shift['id'],'score'=>1000-$datePosition*10-(int)$shift['sequence_no'],'gap_relaxed'=>$appliedGap<$minimumGap,'daily_relaxed'=>$appliedDailyMaximum>$maximumPerDay];break;}
                    }
                    if($chosen)break;
                  }
                  if($chosen)break;
                }
                if(!$chosen){$reason='No unused date-and-shift position satisfies the hard cohort and paper-duration constraints. Add an exam day or shift.';$addItem->execute(['run'=>$runId,'exam'=>null,'curriculum'=>$task['programme_course_id'],'date'=>null,'shift'=>null,'status'=>'unscheduled','score'=>null,'reason'=>$reason]);$addConflict->execute(['run'=>$runId,'entity'=>$task['programme_course_id'],'message'=>$task['programme_code'].' Semester '.$task['semester'].' '.$task['code'].' could not be scheduled.','details'=>json_encode(['reason'=>$reason])]);$unscheduled++;continue;}
                $slotKey=$chosen['date'].'-'.$chosen['shift_id'].'-'.$task['course_id'];
                if(isset($occupied[$slotKey])){$examId=$occupied[$slotKey];}else{$addExam->execute(['cycle'=>$run['cycle_id'],'shift'=>$chosen['shift_id'],'course'=>$task['course_id'],'date'=>$chosen['date'],'run'=>$runId]);$examId=(int)$this->pdo->lastInsertId();}$label=$task['batch_label'].' Semester '.$task['semester'].($task['section']==='ALL'?'':' Section '.$task['section']);$addCohort->execute(['exam'=>$examId,'programme'=>$task['programme_id'],'batch'=>$task['effective_batch_id'],'semester'=>$task['semester'],'section'=>$task['section'],'label'=>$label]);$placementReason=$chosen['daily_relaxed']?'Scheduled in an additional shift because the number of papers exceeds the preferred one-paper-per-day pattern.':($chosen['gap_relaxed']?'Scheduled after relaxing the preferred rest gap because the calendar has no spare separated slot.':'Scheduled with the requested rest gap; higher-priority subjects receive available spacing first.');$addItem->execute(['run'=>$runId,'exam'=>$examId,'curriculum'=>$task['programme_course_id'],'date'=>$chosen['date'],'shift'=>$chosen['shift_id'],'status'=>'scheduled','score'=>$chosen['score'],'reason'=>$placementReason]);
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
