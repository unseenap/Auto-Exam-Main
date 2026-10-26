<?php
declare(strict_types=1);
namespace App\Academic;

use PDO;
use RuntimeException;
use Throwable;

final class AcademicRollover
{
    public function __construct(private readonly PDO $pdo) {}

    public function settings():array
    {
        $row=$this->pdo->query('SELECT * FROM academic_rollover_settings WHERE id=1')->fetch(PDO::FETCH_ASSOC);
        if(!$row)throw new RuntimeException('Install the academic rollover database upgrade first.');
        return $row;
    }

    public function calendar():AcademicCalendar
    {
        $s=$this->settings();return new AcademicCalendar($s['session_start'],$s['even_start']);
    }

    public function saveSettings(bool $enabled,string $start,string $even,int $actor):void
    {
        new AcademicCalendar($start,$even);
        $this->pdo->beginTransaction();
        try{
            $old=$this->pdo->query('SELECT * FROM academic_rollover_settings WHERE id=1 FOR UPDATE')->fetch(PDO::FETCH_ASSOC);
            $this->pdo->prepare('UPDATE academic_rollover_settings SET enabled=?,session_start=?,even_start=?,last_checked=NULL WHERE id=1')->execute([(int)$enabled,$start,$even]);
            $this->audit('academic.calendar_updated',$actor,$old,['enabled'=>$enabled,'session_start'=>$start,'even_start'=>$even]);
            $this->pdo->commit();
        }catch(Throwable $e){$this->pdo->rollBack();throw $e;}
    }

    public function preview(string $date,int $limit=100,string $review='all',int $page=1):array
    {
        $calendar=$this->calendar();$rows=$this->students();$counts=['students'=>count($rows),'updates'=>0,'active'=>0,'held'=>0,'awaiting_completion'=>0,'withdrawn'=>0,'completed'=>0,'not_started'=>0,'blocked'=>0,'missing_curriculum'=>0];$items=[];$matches=0;$offset=(max(1,$page)-1)*$limit;
        foreach($rows as $student){
            $target=$this->target($student,$calendar,$date);
            if(isset($target['error'])){$counts['blocked']++;}
            else{
                $counts[$target['placement_status']]++;
                if($this->changed($student,$target))$counts['updates']++;
                if($target['placement_status']==='active'&&!$this->hasCurriculum($student,$target))$counts['missing_curriculum']++;
            }
            $missing=!isset($target['error'])&&$target['placement_status']==='active'&&!$this->hasCurriculum($student,$target);
            $include=match($review){'blocked'=>isset($target['error']),'missing_curriculum'=>$missing,'updates'=>!isset($target['error'])&&$this->changed($student,$target),'all'=>isset($target['error'])||$this->changed($student,$target)||$target['placement_status']!=='active'||$missing,default=>($target['placement_status']??'')===$review};
            if($include){if($matches>=$offset&&count($items)<$limit)$items[]=['student'=>$student,'target'=>$target,'missing_curriculum'=>$missing];$matches++;}
        }
        return ['period'=>$calendar->period($date),'counts'=>$counts,'items'=>$items,'review'=>$review,'page'=>max(1,$page),'pages'=>max(1,(int)ceil($matches/$limit)),'matches'=>$matches];
    }

    /** One daily check; forced checks also reconcile recent imports and corrections. */
    public function run(string $date,?int $actor=null,string $source='scheduled',bool $force=false):array
    {
        if($this->pdo->inTransaction())throw new RuntimeException('Rollover must run outside another transaction.');
        $this->pdo->beginTransaction();
        try{
            $settings=$this->pdo->query('SELECT * FROM academic_rollover_settings WHERE id=1 FOR UPDATE')->fetch(PDO::FETCH_ASSOC);
            $calendar=new AcademicCalendar($settings['session_start'],$settings['even_start']);$period=$calendar->period($date);
            if(!$settings['enabled']||(!$force&&$settings['last_checked']===$date)){$this->pdo->commit();return ['skipped'=>true];}
            if($settings['last_checked']&&$date<$settings['last_checked'])throw new RuntimeException('Rollover cannot move the academic clock backwards.');
            if(!$force&&$settings['last_checked']&&$calendar->period($settings['last_checked'])['start_date']===$period['start_date']){
                // No academic boundary or data invalidation: do not rescan every student each day.
                $this->pdo->prepare('UPDATE academic_rollover_settings SET last_checked=? WHERE id=1')->execute([$date]);
                $this->pdo->commit();return ['skipped'=>true];
            }
            $this->pdo->prepare('INSERT INTO academic_rollover_runs(effective_date,academic_session,trigger_source,actor_id,summary) VALUES(?,?,?,?,?)')->execute([$date,$period['academic_session'],$source,$actor,'{}']);
            $run=(int)$this->pdo->lastInsertId();$counts=['updated'=>0,'snapshots'=>0,'registrations'=>0,'blocked'=>0,'awaiting_completion'=>0,'missing_curriculum'=>0];
            foreach($this->students(true) as $student){
                if($student['mode']===null){
                    $mode=$student['status']==='completed'?'completed':($student['status']==='inactive'?'withdrawn':(in_array($student['special_status'],['repeat','not_promoted','unverified'],true)?'hold':'automatic'));
                    $this->pdo->prepare('INSERT IGNORE INTO student_progression_controls(student_id,mode,reason) VALUES(?,?,?)')->execute([$student['id'],$mode,'Initial academic progression policy']);
                    $student['mode']=$mode;
                }
                $target=$this->target($student,$calendar,$date);
                if(isset($target['error'])){$counts['blocked']++;continue;}
                // Preserve the actual pre-rollover placement. Never invent missed historical results.
                if(!$student['has_academic_history']&&preg_match('/^(\d{4})-(\d{4})$/',$student['academic_session'],$m)&&(int)$m[2]===(int)$m[1]+1&&(int)$student['semester']>0){
                    $baseline=['academic_session'=>$student['academic_session'],'term'=>((int)$student['semester']%2?1:2),'study_year'=>(int)$student['current_year_of_study'],'semester'=>(int)$student['semester'],'placement_status'=>$student['status']==='active'?'active':($student['status']==='completed'?'completed':'withdrawn')];
                    $counts['snapshots']+=$this->enroll($student,$baseline,$date,false);
                }
                $this->enroll($student,$target,$date,true);
                $termId=$this->termId((int)$student['id'],$target['academic_session'],$target['term']);
                if($target['placement_status']==='active'){
                    $curriculum=$this->curriculum($student,$target);
                    if(!$curriculum)$counts['missing_curriculum']++;
                    foreach($curriculum as $course){
                        if(!in_array($course['category'],['core','common','bridge'],true))continue;
                        $q=$this->pdo->prepare("INSERT IGNORE INTO student_course_registrations(enrollment_id,programme_course_id,source) VALUES(?,?,'core')");$q->execute([$termId,$course['id']]);$counts['registrations']+=$q->rowCount();
                    }
                }
                if($target['placement_status']==='awaiting_completion')$counts['awaiting_completion']++;
                if($this->changed($student,$target)){
                    $this->pdo->prepare('UPDATE students SET academic_session=?,current_year_of_study=?,semester=?,status=? WHERE id=?')->execute([$target['academic_session'],$target['study_year'],$target['semester'],$target['status'],$student['id']]);
                    $this->history((int)$student['id'],$run,'rollover',$student,$target,'Academic calendar progression',$actor);$counts['updated']++;
                }
            }
            // A completed batch means its normal teaching duration ended, not that every student graduated.
            $q=$this->pdo->query("SELECT b.*,p.duration_semesters FROM batches b JOIN programmes p ON p.id=b.programme_id WHERE b.status='active' AND b.start_year IS NOT NULL AND p.duration_semesters>0 FOR UPDATE");
            foreach($q->fetchAll(PDO::FETCH_ASSOC) as $b){
                if($calendar->placement($date,$b,(int)$b['duration_semesters'])['placement_status']==='awaiting_completion')$this->pdo->prepare("UPDATE batches SET status='completed' WHERE id=?")->execute([$b['id']]);
            }
            $counts['draft_eligibility_changes']=(new DraftExamEligibility($this->pdo))->refresh();
            $counts['department_electives']=(new DepartmentElectiveRegistrations($this->pdo))->synchronize();
            $this->pdo->prepare('UPDATE academic_rollover_runs SET summary=? WHERE id=?')->execute([json_encode($counts),$run]);
            $this->pdo->prepare('UPDATE academic_rollover_settings SET last_checked=? WHERE id=1')->execute([$date]);
            $this->audit('academic.rollover_completed',$actor,null,['run_id'=>$run]+$counts);
            $this->pdo->commit();return ['run_id'=>$run]+$counts;
        }catch(Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }

    public function setControl(int $id,string $mode,int $delay,string $reason,int $actor):void
    {
        if(!in_array($mode,['automatic','hold','withdrawn','completed'],true)||$delay<0||$delay>24||trim($reason)===''||strlen($reason)>500)throw new RuntimeException('Choose a progression mode, a delay from 0 to 24 semesters, and a reason of up to 500 characters.');
        $this->pdo->beginTransaction();
        try{
            $this->pdo->query('SELECT id FROM academic_rollover_settings WHERE id=1 FOR UPDATE');
            $q=$this->pdo->prepare('SELECT s.*,p.duration_semesters FROM students s LEFT JOIN programmes p ON p.id=s.programme_id WHERE s.id=? FOR UPDATE');$q->execute([$id]);$s=$q->fetch(PDO::FETCH_ASSOC);
            if(!$s)throw new RuntimeException('Student not found.');
            if($mode==='completed'&&(int)$s['semester']<(int)$s['duration_semesters'])throw new RuntimeException('Completion can only be confirmed at the programme final semester.');
            $this->pdo->prepare('INSERT INTO student_progression_controls(student_id,mode,semester_delay,reason,updated_by) VALUES(?,?,?,?,?) ON DUPLICATE KEY UPDATE mode=VALUES(mode),semester_delay=VALUES(semester_delay),reason=VALUES(reason),updated_by=VALUES(updated_by)')->execute([$id,$mode,$delay,trim($reason),$actor]);
            $this->history($id,null,'control_changed',$s,['mode'=>$mode,'semester_delay'=>$delay],$reason,$actor);
            $this->pdo->prepare('UPDATE academic_rollover_settings SET last_checked=NULL WHERE id=1')->execute();
            $this->pdo->commit();
        }catch(Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }

    public function detail(int $id):array
    {
        $q=$this->pdo->prepare('SELECT * FROM student_progression_controls WHERE student_id=?');$q->execute([$id]);$control=$q->fetch(PDO::FETCH_ASSOC)?:['mode'=>'automatic','semester_delay'=>0,'reason'=>''];
        $q=$this->pdo->prepare('SELECT * FROM student_academic_history WHERE student_id=? ORDER BY id DESC LIMIT 30');$q->execute([$id]);
        return ['progressionControl'=>$control,'academicHistory'=>$q->fetchAll(PDO::FETCH_ASSOC)];
    }

    public function invalidate():void{$this->pdo->exec('UPDATE academic_rollover_settings SET last_checked=NULL WHERE id=1');}

    private function students(bool $lock=false):array
    {
        return $this->pdo->query("SELECT s.*,b.start_year,b.end_year,b.label AS batch_label,b.programme_id AS batch_programme_id,p.duration_semesters,pc.mode,pc.semester_delay,pc.reason AS progression_reason,EXISTS(SELECT 1 FROM student_term_enrollments h WHERE h.student_id=s.id) AS has_academic_history FROM students s LEFT JOIN batches b ON b.id=s.batch_id LEFT JOIN programmes p ON p.id=s.programme_id LEFT JOIN student_progression_controls pc ON pc.student_id=s.id ORDER BY s.id".($lock?' FOR UPDATE':''))->fetchAll(PDO::FETCH_ASSOC);
    }

    private function target(array $s,AcademicCalendar $calendar,string $date):array
    {
        if(!$s['batch_id']||!$s['start_year']||!(int)$s['duration_semesters']||(int)$s['programme_id']!==(int)$s['batch_programme_id'])return ['error'=>'Assign a valid programme, duration and admission batch.'];
        $p=$calendar->placement($date,$s,(int)$s['duration_semesters'],(int)($s['semester_delay']??0));
        $mode=$s['mode']??($s['status']==='completed'?'completed':($s['status']==='inactive'?'withdrawn':'automatic'));
        // Imported repeaters require an explicit academic decision before automatic advancement.
        if($mode==='automatic'&&in_array($s['special_status'],['repeat','not_promoted','unverified'],true)&&$s['mode']===null)$mode='hold';
        if($mode!=='automatic'){
            $p['semester']=max(1,(int)$s['semester']);$p['study_year']=max(1,(int)$s['current_year_of_study']);
            $p['placement_status']=match($mode){'hold'=>'held','withdrawn'=>'withdrawn','completed'=>'completed'};
        }
        $p['status']=match($p['placement_status']){'active','held'=>'active','completed'=>'completed',default=>'inactive'};
        return $p;
    }

    private function changed(array $s,array $p):bool
    {
        return $s['academic_session']!==$p['academic_session']||(int)$s['semester']!==$p['semester']||(int)$s['current_year_of_study']!==$p['study_year']||$s['status']!==$p['status'];
    }

    private function enroll(array $s,array $p,string $date,bool $update):int
    {
        $sql='INSERT IGNORE INTO student_term_enrollments(student_id,programme_id,batch_id,academic_session,term,study_year,semester,section,placement_status,effective_date) VALUES(?,?,?,?,?,?,?,?,?,?)';
        if($update)$sql.=' ON DUPLICATE KEY UPDATE study_year=VALUES(study_year),semester=VALUES(semester),section=VALUES(section),placement_status=VALUES(placement_status),programme_id=VALUES(programme_id),batch_id=VALUES(batch_id)';
        $q=$this->pdo->prepare($sql);$q->execute([$s['id'],$s['programme_id'],$s['batch_id'],$p['academic_session'],$p['term'],$p['study_year'],$p['semester'],$s['section'],$p['placement_status'],$date]);return $q->rowCount();
    }

    private function termId(int $student,string $session,int $term):int
    {
        $q=$this->pdo->prepare('SELECT id FROM student_term_enrollments WHERE student_id=? AND academic_session=? AND term=?');$q->execute([$student,$session,$term]);return (int)$q->fetchColumn();
    }

    private array $curriculumCache=[];
    private function curriculum(array $s,array $p):array
    {
        $key=$s['programme_id'].'/'.$s['batch_id'].'/'.$p['semester'].'/'.$s['section'];
        if(!isset($this->curriculumCache[$key])){
            $q=$this->pdo->prepare("SELECT pc.id,pc.category FROM programme_courses pc JOIN courses c ON c.id=pc.course_id WHERE pc.programme_id=? AND pc.batch_id=? AND pc.semester=? AND (pc.section='ALL' OR pc.section=?) AND c.status='active'");$q->execute([$s['programme_id'],$s['batch_id'],$p['semester'],$s['section']]);$this->curriculumCache[$key]=$q->fetchAll(PDO::FETCH_ASSOC);
        }
        return $this->curriculumCache[$key];
    }
    private function hasCurriculum(array $s,array $p):bool{return (bool)$this->curriculum($s,$p);}
    private function history(int $student,?int $run,string $action,?array $old,array $new,string $reason,?int $actor):void
    {
        $keys=array_flip(['academic_session','semester','current_year_of_study','study_year','status','section','programme_id','batch_id','placement_status','mode','semester_delay']);
        $this->pdo->prepare('INSERT INTO student_academic_history(student_id,run_id,action,old_values,new_values,reason,actor_id) VALUES(?,?,?,?,?,?,?)')->execute([$student,$run,$action,$old?json_encode(array_intersect_key($old,$keys)):null,json_encode(array_intersect_key($new,$keys)),$reason,$actor]);
    }
    private function audit(string $action,?int $actor,?array $old,array $new):void
    {
        $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,old_values,new_values) VALUES(?,?,'academic_rollover',?,?)")->execute([$actor,$action,$old?json_encode($old):null,json_encode($new)]);
    }
}
