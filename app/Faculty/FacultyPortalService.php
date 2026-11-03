<?php
declare(strict_types=1);
namespace App\Faculty;

use DateTimeImmutable;
use DateTimeZone;
use PDO;
use Throwable;

final class FacultyPortalService
{
    public function __construct(private readonly PDO $pdo,private readonly ?DateTimeImmutable $clock=null){}
    public function now():DateTimeImmutable{return ($this->clock??new DateTimeImmutable('now',new DateTimeZone('Asia/Kolkata')))->setTimezone(new DateTimeZone('Asia/Kolkata'));}
    private function stamp():string{return $this->now()->format('Y-m-d H:i:s');}
    public function rows(string $sql,array $args=[]):array{$q=$this->pdo->prepare($sql);$q->execute($args);return $q->fetchAll(PDO::FETCH_ASSOC);}
    private function row(string $sql,array $args=[]):array{return $this->rows($sql,$args)[0]??[];}
    private function exec(string $sql,array $args=[]):void{$this->pdo->prepare($sql)->execute($args);}
    private function transaction(callable $work):mixed{$this->pdo->beginTransaction();try{$result=$work();$this->pdo->commit();return $result;}catch(Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}}
    private function audit(int $user,string $action,string $type,int $id,array $data=[]):void{$this->exec('INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(?,?,?,?,?)',[$user,$action,$type,$id,json_encode($data,JSON_THROW_ON_ERROR)]);}
    public function settings():array{return $this->row('SELECT * FROM faculty_portal_settings WHERE id=1');}
    public function faculty(int $user):array
    {
        $record=$this->row("SELECT f.*,s.name AS school_name,d.name AS department_name FROM users u JOIN roles r ON r.id=u.role_id JOIN faculty_user_links l ON l.user_id=u.id JOIN faculty f ON f.id=l.faculty_id LEFT JOIN schools s ON s.id=f.school_id LEFT JOIN departments d ON d.id=f.department_id WHERE u.id=? AND u.status='active' AND r.code='faculty' AND f.status='active'",[$user]);
        if(!$record)throw new PortalException('Your account is not linked to an active faculty record. Ask an administrator to open Users & roles and select your employee record.',403);
        return $record;
    }
    public function requireCoordinator(int $user):void
    {
        $row=$this->row("SELECT r.code FROM users u JOIN roles r ON r.id=u.role_id WHERE u.id=? AND u.status='active'",[$user]);
        if(!in_array($row['code']??'',['admin','examination_controller','invigilation_coordinator'],true))throw new PortalException('Only an authorized examination or invigilation coordinator can review faculty operations.',403);
    }
    /** Called inside the existing administrator user-save transaction. */
    public function linkAccount(int $actor,int $user,?int $faculty):void
    {
        $admin=$this->row("SELECT u.id FROM users u JOIN roles r ON r.id=u.role_id WHERE u.id=? AND u.status='active' AND r.code='admin'",[$actor]);if(!$admin)throw new PortalException('Only an active administrator can link faculty accounts.',403);
        $account=$this->row('SELECT r.code FROM users u JOIN roles r ON r.id=u.role_id WHERE u.id=?',[$user]);
        if($faculty&&($account['code']??'')!=='faculty')throw new PortalException('Select the Faculty / Invigilator role before linking an employee record.');
        if($faculty&&!$this->row("SELECT id FROM faculty WHERE id=? AND status='active'",[$faculty]))throw new PortalException('Select an active faculty employee record.');
        if($faculty&&$this->row('SELECT user_id FROM faculty_user_links WHERE faculty_id=? AND user_id<>?',[$faculty,$user]))throw new PortalException('This employee record is already linked to another login.');
        $this->exec('DELETE FROM faculty_user_links WHERE user_id=?',[$user]);
        if($faculty)$this->exec('INSERT INTO faculty_user_links(user_id,faculty_id) VALUES(?,?)',[$user,$faculty]);
        $this->audit($actor,'faculty.account_linked','user',$user,['faculty_id'=>$faculty]);
    }
    public function duties(int $user):array
    {
        $f=$this->faculty($user);
        return $this->rows("SELECT ia.*,ec.name AS cycle_name,es.name AS shift_name,es.start_time,es.end_time,r.code AS room_code,r.building,r.floor,ack.acknowledged_at,
            (SELECT COUNT(*) FROM seating_assignments x JOIN seating_allocations sa ON sa.id=x.allocation_id WHERE sa.cycle_id=ia.cycle_id AND sa.exam_date=ia.exam_date AND sa.shift_id=ia.shift_id AND sa.status='published' AND x.room_id=ia.room_id) AS students,
            (SELECT fs.status FROM faculty_room_sessions fs JOIN seating_allocations sa ON sa.id=fs.allocation_id WHERE sa.cycle_id=ia.cycle_id AND sa.exam_date=ia.exam_date AND sa.shift_id=ia.shift_id AND sa.status='published' AND fs.room_id=ia.room_id ORDER BY sa.version_no DESC LIMIT 1) AS attendance_status,
            (SELECT fs.report_at FROM faculty_room_sessions fs JOIN seating_allocations sa ON sa.id=fs.allocation_id WHERE sa.cycle_id=ia.cycle_id AND sa.exam_date=ia.exam_date AND sa.shift_id=ia.shift_id AND sa.status='published' AND fs.room_id=ia.room_id ORDER BY sa.version_no DESC LIMIT 1) AS report_at
            FROM invigilation_allocations ia JOIN exam_cycles ec ON ec.id=ia.cycle_id JOIN exam_shifts es ON es.id=ia.shift_id JOIN rooms r ON r.id=ia.room_id LEFT JOIN faculty_duty_acknowledgments ack ON ack.duty_id=ia.id AND ack.faculty_id=ia.faculty_id WHERE ia.faculty_id=? ORDER BY ia.exam_date,es.start_time",[$f['id']]);
    }
    public function duty(int $user,int $id,bool $write=false):array
    {
        $f=$this->faculty($user);
        $d=$this->row('SELECT ia.*,ec.name AS cycle_name,es.name AS shift_name,es.start_time,es.end_time,r.code AS room_code,r.building,r.floor,r.rows_count,r.columns_count,r.notes FROM invigilation_allocations ia JOIN exam_cycles ec ON ec.id=ia.cycle_id JOIN exam_shifts es ON es.id=ia.shift_id JOIN rooms r ON r.id=ia.room_id WHERE ia.id=? AND ia.faculty_id=?'.($write?' FOR UPDATE':''),[$id,$f['id']]);
        if(!$d)throw new PortalException('This duty is not assigned to your faculty account.',403);
        if($write&&in_array($d['duty_status'],['cancelled','completed'],true))throw new PortalException('Duty '.$id.' in room '.$d['room_code'].' is '.$d['duty_status'].'. Attendance changes are not allowed.',403);
        return $d;
    }
    public function session(int $allocation,int $room,bool $lock=false):array
    {
        $this->exec('INSERT IGNORE INTO faculty_room_sessions(allocation_id,room_id) VALUES(?,?)',[$allocation,$room]);
        return $this->row('SELECT fs.*,u.name AS editor_name,sub.name AS submitter_name,rep.name AS reporter_name FROM faculty_room_sessions fs LEFT JOIN users u ON u.id=fs.edited_by LEFT JOIN users sub ON sub.id=fs.submitted_by LEFT JOIN users rep ON rep.id=fs.report_by WHERE fs.allocation_id=? AND fs.room_id=?'.($lock?' FOR UPDATE':''),[$allocation,$room]);
    }
    private function allocation(array $d):array
    {
        $a=$this->row("SELECT sa.* FROM seating_allocations sa WHERE sa.cycle_id=? AND sa.exam_date=? AND sa.shift_id=? AND sa.status='published' AND EXISTS(SELECT 1 FROM seating_assignments x WHERE x.allocation_id=sa.id AND x.room_id=?) ORDER BY sa.version_no DESC LIMIT 1",[$d['cycle_id'],$d['exam_date'],$d['shift_id'],$d['room_id']]);
        if(!$a)throw new PortalException('Room '.$d['room_code'].' has no published seating for this duty. Ask the seating coordinator to publish its allocation.');
        return $a;
    }
    public function records(int $allocation,int $room):array
    {
        $period=(new \App\Seating\SeatingRoster($this->pdo))->period((int)$this->row('SELECT cycle_id FROM seating_allocations WHERE id=?',[$allocation])['cycle_id']);
        return $this->rows('SELECT a.*,rs.seat_label,rs.row_no,rs.column_no,s.roll_no_original,s.enrollment_number,s.name,p.code AS programme_code,b.label AS batch_label,COALESCE(t.semester,s.semester) AS semester,c.code AS course_code,c.name AS course_name,u.name AS marked_name FROM attendance a JOIN seating_assignments x ON x.allocation_id=a.allocation_id AND x.student_id=a.student_id AND x.examination_id=a.examination_id AND x.room_id=a.room_id JOIN room_seats rs ON rs.id=x.seat_id JOIN students s ON s.id=a.student_id LEFT JOIN student_term_enrollments t ON t.student_id=s.id AND t.academic_session=? AND t.term=? JOIN programmes p ON p.id=COALESCE(t.programme_id,s.programme_id) LEFT JOIN batches b ON b.id=COALESCE(t.batch_id,s.batch_id) JOIN examinations e ON e.id=a.examination_id JOIN courses c ON c.id=e.course_id LEFT JOIN users u ON u.id=a.marked_by WHERE a.allocation_id=? AND a.room_id=? ORDER BY rs.sequence_no',[$period['session'],$period['term'],$allocation,$room]);
    }
    public function window(array $d):array
    {
        $s=$this->settings();$zone=new DateTimeZone('Asia/Kolkata');
        $start=new DateTimeImmutable($d['exam_date'].' '.$d['start_time'],$zone);$end=new DateTimeImmutable($d['exam_date'].' '.$d['end_time'],$zone);if($end<$start)$end=$end->modify('+1 day');
        $open=$start->modify('-'.$s['attendance_before_minutes'].' minutes');$close=$end->modify('+'.$s['attendance_after_minutes'].' minutes');
        return ['open'=>$open->format('d M Y, H:i'),'close'=>$close->format('d M Y, H:i'),'allowed'=>$this->now()>=$open&&$this->now()<=$close,'reporting'=>$start->modify('-'.$s['reporting_minutes'].' minutes')->format('H:i')];
    }
    public function room(int $user,int $duty):array
    {
        $d=$this->duty($user,$duty);if($d['duty_status']==='cancelled')throw new PortalException('This duty was cancelled or reassigned. Access to its student records is no longer available.',403);
        $a=$this->allocation($d);$state=$this->session((int)$a['id'],(int)$d['room_id']);$records=$this->records((int)$a['id'],(int)$d['room_id']);
        $assigned=(int)$this->row('SELECT COUNT(*) AS n FROM seating_assignments WHERE allocation_id=? AND room_id=?',[$a['id'],$d['room_id']])['n'];
        if(count($records)!==$assigned)throw new PortalException('Room '.$d['room_code'].' has '.$assigned.' allocated students but '.count($records).' attendance entries. Ask the coordinator to repair the published attendance sheet.');
        $co=$this->rows("SELECT f.name,ia.duty_role FROM invigilation_allocations ia JOIN faculty f ON f.id=ia.faculty_id WHERE ia.cycle_id=? AND ia.exam_date=? AND ia.shift_id=? AND ia.room_id=? AND ia.id<>? AND ia.duty_status<>'cancelled'",[$d['cycle_id'],$d['exam_date'],$d['shift_id'],$d['room_id'],$duty]);
        $window=$this->window($d);if($state['reopened_until']&&$state['reopened_until']>=$this->stamp()){$window['allowed']=true;$window['close']=$state['reopened_until'];$window['open']='Coordinator-approved correction window';}
        return ['duty'=>$d,'allocation'=>$a,'state'=>$state,'records'=>$records,'window'=>$window,'seats'=>$this->rows('SELECT * FROM room_seats WHERE room_id=? ORDER BY sequence_no',[$d['room_id']]),'colleagues'=>$co,'corrections'=>$this->rows('SELECT * FROM faculty_correction_requests WHERE session_id=? ORDER BY id DESC',[$state['id']]),'replacements'=>$this->rows('SELECT * FROM replacement_requests WHERE duty_id=? ORDER BY id DESC',[$duty])];
    }
    private function editContext(int $user,int $duty,int $revision):array
    {
        $d=$this->duty($user,$duty,true);$a=$this->allocation($d);$s=$this->session((int)$a['id'],(int)$d['room_id'],true);
        if($s['status']==='submitted')throw new PortalException('Attendance for room '.$d['room_code'].' has been submitted and locked. Request a correction to reopen it.',409);
        if((int)$s['revision']!==$revision)throw new PortalException('Another invigilator updated room '.$d['room_code'].'. Reload the latest attendance before applying your change.',409);
        $window=$this->window($d);if(!$window['allowed']&&(!$s['reopened_until']||$s['reopened_until']<$this->stamp()))throw new PortalException('Attendance for room '.$d['room_code'].' is editable from '.$window['open'].' to '.$window['close'].' (Asia/Kolkata).',403);
        return [$d,$a,$s];
    }
    public function mark(int $user,int $duty,int $record,string $status,string $remarks,int $revision):array
    {
        return $this->transaction(function()use($user,$duty,$record,$status,$remarks,$revision){
            [$d,$a,$s]=$this->editContext($user,$duty,$revision);
            if(!in_array($status,['unmarked','present','absent','unfair_means','withheld','other'],true))throw new PortalException('Choose a valid attendance status.');
            if(strlen($remarks)>255)throw new PortalException('Attendance remarks must be at most 255 characters.');
            if(in_array($status,['unfair_means','withheld','other'],true)&&trim($remarks)==='')throw new PortalException('Explain the exceptional attendance status in Remarks.');
            $old=$this->row('SELECT * FROM attendance WHERE id=? AND allocation_id=? AND room_id=?',[$record,$a['id'],$d['room_id']]);if(!$old)throw new PortalException('This student attendance record is outside your assigned room.',403);
            $this->exec('UPDATE attendance SET status=?,remarks=?,marked_by=?,marked_at=? WHERE id=?',[$status,trim($remarks)?:null,$user,$this->stamp(),$record]);
            $this->exec('UPDATE faculty_room_sessions SET revision=revision+1,edited_by=?,edited_at=? WHERE id=?',[$user,$this->stamp(),$s['id']]);
            $this->audit($user,'faculty.attendance_saved','attendance',$record,['before'=>$old['status'],'after'=>$status,'remarks'=>$remarks,'duty_id'=>$duty]);
            return ['revision'=>$revision+1,'saved_at'=>$this->stamp()];
        });
    }
    public function submit(int $user,int $duty,int $revision):void
    {
        $this->transaction(function()use($user,$duty,$revision){
            [$d,$a,$s]=$this->editContext($user,$duty,$revision);$records=$this->records((int)$a['id'],(int)$d['room_id']);
            $missing=array_filter($records,static fn(array $r):bool=>$r['status']==='unmarked');
            if(!$records)throw new PortalException('This room has no attendance records to submit.');
            if($missing)throw new PortalException(count($missing).' students remain unmarked: '.implode('; ',array_map(static fn(array $r):string=>$r['roll_no_original'].' at '.$r['seat_label'],array_values($missing))).'. Mark these students before submitting.');
            $this->exec("UPDATE faculty_room_sessions SET status='submitted',revision=revision+1,submitted_by=?,submitted_at=?,edited_by=?,edited_at=? WHERE id=?",[$user,$this->stamp(),$user,$this->stamp(),$s['id']]);
            $this->audit($user,'faculty.attendance_submitted','faculty_room_session',(int)$s['id'],['students'=>count($records),'duty_id'=>$duty]);
        });
    }
    public function acknowledge(int $user,int $duty):void
    {
        $this->transaction(function()use($user,$duty){$d=$this->duty($user,$duty,true);$this->exec('INSERT IGNORE INTO faculty_duty_acknowledgments(duty_id,faculty_id,acknowledged_at) VALUES(?,?,?)',[$duty,$d['faculty_id'],$this->stamp()]);$this->audit($user,'faculty.duty_acknowledged','invigilation_allocation',$duty);});
    }
    public function replacement(int $user,int $duty,string $reason):void
    {
        $this->transaction(function()use($user,$duty,$reason){$d=$this->duty($user,$duty,true);$this->reason($reason);if($this->row("SELECT id FROM replacement_requests WHERE duty_id=? AND status='pending'",[$duty]))throw new PortalException('A replacement request is already pending for this duty.');$this->exec("INSERT INTO replacement_requests(duty_id,requested_by,reason,status) VALUES(?,?,?,'pending')",[$duty,$user,trim($reason)]);$this->audit($user,'faculty.replacement_requested','invigilation_allocation',$duty);});
    }
    private function reason(string $reason):void{if(trim($reason)===''||strlen($reason)>1000)throw new PortalException('Enter a reason of 1–1000 characters.');}
    public function correction(int $user,int $duty,string $reason):void
    {
        $this->transaction(function()use($user,$duty,$reason){$d=$this->duty($user,$duty,true);$a=$this->allocation($d);$s=$this->session((int)$a['id'],(int)$d['room_id'],true);$this->reason($reason);if($s['status']!=='submitted')throw new PortalException('Attendance is already editable; no correction request is needed.');if($this->row("SELECT id FROM faculty_correction_requests WHERE session_id=? AND status='pending'",[$s['id']]))throw new PortalException('A correction request for this room is already pending.');$this->exec("INSERT INTO faculty_correction_requests(session_id,requested_by,reason,created_at) VALUES(?,?,?,?)",[$s['id'],$user,trim($reason),$this->stamp()]);$this->audit($user,'faculty.correction_requested','faculty_room_session',(int)$s['id'],['reason'=>$reason]);});
    }
    public function closeReport(int $user,int $duty,int $revision,array $books,bool $handed,string $remarks,string $incident):void
    {
        $this->transaction(function()use($user,$duty,$revision,$books,$handed,$remarks,$incident){
            $d=$this->duty($user,$duty,true);$a=$this->allocation($d);$s=$this->session((int)$a['id'],(int)$d['room_id'],true);
            if($s['status']!=='submitted')throw new PortalException('Submit attendance before completing the room-closing report.');
            if($s['closing_report']!==null)throw new PortalException('This room report has already been submitted and is read-only.',409);
            if((int)$s['revision']!==$revision)throw new PortalException('The room changed. Reload before submitting its closing report.',409);
            if(!$handed)throw new PortalException('Confirm that the answer books have been handed over.');
            if(strlen($remarks)>2000||strlen($incident)>4000)throw new PortalException('Keep remarks within 2000 characters and incidents within 4000 characters.');
            $subjects=[];foreach($this->records((int)$a['id'],(int)$d['room_id']) as $r){$key=(int)$r['examination_id'];$subjects[$key]??=['code'=>$r['course_code'],'name'=>$r['course_name'],'expected'=>0];if(in_array($r['status'],['present','unfair_means','withheld','other'],true))$subjects[$key]['expected']++;}
            if(array_diff(array_map('intval',array_keys($books)),array_keys($subjects)))throw new PortalException('The report includes a subject outside your room.');
            foreach($subjects as $id=>&$subject){$value=(string)($books[$id]??'');if(!ctype_digit($value)||strlen($value)>6)throw new PortalException('Enter the answer-book count for '.$subject['code'].'.');$subject['collected']=(int)$value;if($subject['collected']!==$subject['expected']&&trim($remarks)==='')throw new PortalException($subject['code'].' expects '.$subject['expected'].' answer books from attendance; you entered '.$value.'. Explain the discrepancy in Remarks.');}unset($subject);
            $report=['subjects'=>$subjects,'handed_over'=>true,'remarks'=>trim($remarks),'incident'=>trim($incident)];
            $this->exec('UPDATE faculty_room_sessions SET closing_report=?,report_by=?,report_at=?,revision=revision+1 WHERE id=?',[json_encode($report,JSON_THROW_ON_ERROR),$user,$this->stamp(),$s['id']]);$this->audit($user,'faculty.room_report_submitted','faculty_room_session',(int)$s['id'],$report);
        });
    }
    public function availability(int $user,string $date,int $shift,string $value,string $reason):void
    {
        $this->transaction(function()use($user,$date,$shift,$value,$reason){$f=$this->faculty($user);$this->reason($reason);$parsed=DateTimeImmutable::createFromFormat('!Y-m-d',$date);if(!$parsed||$parsed->format('Y-m-d')!==$date||$date<$this->now()->format('Y-m-d'))throw new PortalException('Choose today or a future availability date.');
            if(!in_array($value,['available','unavailable','preferred'],true))throw new PortalException('Choose a valid availability status.');
            if(!$this->row('SELECT es.id FROM exam_shifts es JOIN exam_cycles ec ON ec.id=es.cycle_id WHERE es.id=? AND ec.start_date<=? AND ec.end_date>=?',[$shift,$date,$date]))throw new PortalException('The selected shift does not belong to an exam cycle on '.$date.'.');
            if($this->row("SELECT id FROM faculty_availability_requests WHERE faculty_id=? AND exam_date=? AND shift_id=? AND status='pending'",[$f['id'],$date,$shift]))throw new PortalException('An availability request for this date and shift is already pending.');
            $this->exec('INSERT INTO faculty_availability_requests(faculty_id,requested_by,exam_date,shift_id,availability,reason,created_at) VALUES(?,?,?,?,?,?,?)',[$f['id'],$user,$date,$shift,$value,trim($reason),$this->stamp()]);$this->audit($user,'faculty.availability_requested','faculty',(int)$f['id'],['date'=>$date,'shift'=>$shift,'availability'=>$value]);
        });
    }
    public function changePassword(int $user,string $current,string $password,string $confirm):void
    {
        $this->faculty($user);$row=$this->row('SELECT password_hash FROM users WHERE id=?',[$user]);if(!password_verify($current,$row['password_hash'])||strlen($password)<12||$password!==$confirm)throw new PortalException('Enter your correct current password and matching new passwords of at least 12 characters.');
        $this->transaction(function()use($user,$password){$this->exec('UPDATE users SET password_hash=? WHERE id=?',[password_hash($password,PASSWORD_DEFAULT),$user]);$this->audit($user,'faculty.password_changed','user',$user);});
    }
    public function review(int $user,string $kind,int $id,bool $approve,?int $replacement=null):void
    {
        $this->requireCoordinator($user);
        $this->transaction(function()use($user,$kind,$id,$approve,$replacement){
            $table=match($kind){'correction'=>'faculty_correction_requests','availability'=>'faculty_availability_requests','replacement'=>'replacement_requests',default=>throw new PortalException('Unknown request type.')};
            $r=$this->row("SELECT * FROM {$table} WHERE id=? AND status='pending' FOR UPDATE",[$id]);if(!$r)throw new PortalException('This request has already been reviewed or no longer exists.',409);
            if($approve&&$kind==='correction'){
                $s=$this->row('SELECT * FROM faculty_room_sessions WHERE id=? FOR UPDATE',[$r['session_id']]);
                $this->audit($user,'faculty.attendance_reopened','faculty_room_session',(int)$s['id'],['previous_submission'=>$s,'reason'=>$r['reason']]);
                $this->exec("UPDATE faculty_room_sessions SET status='draft',submitted_by=NULL,submitted_at=NULL,closing_report=NULL,report_by=NULL,report_at=NULL,reopened_until=?,revision=revision+1 WHERE id=?",[$this->now()->modify('+60 minutes')->format('Y-m-d H:i:s'),$s['id']]);
            }
            if($approve&&$kind==='availability'){
                $conflict=$this->row("SELECT ia.id,rm.code FROM invigilation_allocations ia JOIN rooms rm ON rm.id=ia.room_id WHERE ia.faculty_id=? AND ia.exam_date=? AND ia.shift_id=? AND ia.duty_status<>'cancelled' FOR UPDATE",[$r['faculty_id'],$r['exam_date'],$r['shift_id']]);
                if($r['availability']==='unavailable'&&$conflict)throw new PortalException('Duty #'.$conflict['id'].' in room '.$conflict['code'].' conflicts with this unavailability. Reassign the duty before approval.');
                $this->exec('INSERT INTO faculty_availability(faculty_id,exam_date,shift_id,availability,reason) VALUES(?,?,?,?,?) ON DUPLICATE KEY UPDATE availability=VALUES(availability),reason=VALUES(reason)',[$r['faculty_id'],$r['exam_date'],$r['shift_id'],$r['availability'],$r['reason']]);
            }
            if($approve&&$kind==='replacement'){
                $d=$this->row("SELECT * FROM invigilation_allocations WHERE id=? AND duty_status NOT IN ('cancelled','completed') FOR UPDATE",[$r['duty_id']]);if(!$d)throw new PortalException('The original duty is no longer active. Reject this outdated request.');
                $f=$replacement?:((int)$r['replacement_faculty_id']);if(!$f||!$this->row("SELECT id FROM faculty WHERE id=? AND status='active' FOR UPDATE",[$f]))throw new PortalException('Choose an active replacement faculty member before approval.');
                if($this->row('SELECT id FROM invigilation_allocations WHERE faculty_id=? AND exam_date=? AND shift_id=?',[$f,$d['exam_date'],$d['shift_id']]))throw new PortalException('The selected replacement already has a duty record in this examination session. Choose another faculty member.');
                if($this->row("SELECT id FROM faculty_availability WHERE faculty_id=? AND exam_date=? AND shift_id=? AND availability='unavailable'",[$f,$d['exam_date'],$d['shift_id']]))throw new PortalException('The replacement is unavailable for this date and shift.');
                $this->exec("UPDATE invigilation_allocations SET duty_status='cancelled' WHERE id=?",[$d['id']]);
                $this->exec("INSERT INTO invigilation_allocations(cycle_id,exam_date,shift_id,room_id,faculty_id,duty_role,duty_status,assigned_by) VALUES(?,?,?,?,?,?,'assigned',?)",[$d['cycle_id'],$d['exam_date'],$d['shift_id'],$d['room_id'],$f,$d['duty_role'],$user]);
                $this->exec('UPDATE faculty SET duty_count=duty_count+1 WHERE id=?',[$f]);$this->exec('UPDATE replacement_requests SET replacement_faculty_id=? WHERE id=?',[$f,$id]);
            }
            $this->exec("UPDATE {$table} SET status=?,reviewed_by=?,reviewed_at=? WHERE id=?",[$approve?'approved':'rejected',$user,$this->stamp(),$id]);$this->audit($user,'faculty.'.$kind.'_reviewed',$table,$id,['decision'=>$approve?'approved':'rejected']);
        });
    }
    public function saveSettings(int $user,array $values):void
    {
        $this->requireCoordinator($user);$fields=['reporting_minutes','attendance_before_minutes','attendance_after_minutes'];foreach($fields as $field){$v=(string)($values[$field]??'');if(!ctype_digit($v)||(int)$v>1440)throw new PortalException('Enter '.$field.' as minutes from 0 to 1440.');}
        $this->transaction(function()use($user,$values){$this->exec('UPDATE faculty_portal_settings SET reporting_minutes=?,attendance_before_minutes=?,attendance_after_minutes=? WHERE id=1',[$values['reporting_minutes'],$values['attendance_before_minutes'],$values['attendance_after_minutes']]);$this->audit($user,'faculty.settings_updated','faculty_portal_settings',1,$values);});
    }

    /** Keeps the existing coordinator sheet subject to shared revision and final locks. */
    public function coordinatorAttendance(int $user,int $allocation,array $statuses,array $revisions,array $remarks=[]):void
    {
        $this->requireCoordinator($user);
        $this->transaction(function()use($user,$allocation,$statuses,$revisions,$remarks){
            if(!$this->row("SELECT id FROM seating_allocations WHERE id=? AND status='published' FOR UPDATE",[$allocation]))throw new PortalException('Only published attendance sheets can be edited.');
            $changed=[];
            foreach($statuses as $id=>$status){
                $r=$this->row('SELECT * FROM attendance WHERE id=? AND allocation_id=? FOR UPDATE',[(int)$id,$allocation]);if(!$r)throw new PortalException('Attendance entry #'.(int)$id.' does not belong to this allocation.');
                $note=trim((string)($remarks[$id]??$r['remarks']??''));if($status===$r['status']&&$note===trim((string)$r['remarks']))continue;
                if(!in_array($status,['unmarked','present','absent','unfair_means','withheld','other'],true)||strlen($note)>255)throw new PortalException('Invalid attendance status or remarks for entry #'.(int)$id.'.');
                if(in_array($status,['unfair_means','withheld','other'],true)&&$note==='')throw new PortalException('Remarks are required for exceptional attendance entry #'.(int)$id.'.');
                $room=(int)$r['room_id'];if(!isset($changed[$room])){$s=$this->session($allocation,$room,true);if($s['status']==='submitted')throw new PortalException('Room #'.$room.' attendance is submitted. Approve a correction request in Faculty requests before editing.',409);if((int)$s['revision']!==(int)($revisions[$room]??-1))throw new PortalException('Room #'.$room.' changed after this sheet was opened. Reload before saving.',409);$changed[$room]=$s['id'];}
                $this->exec('UPDATE attendance SET status=?,remarks=?,marked_by=?,marked_at=? WHERE id=?',[$status,$note?:null,$user,$this->stamp(),$id]);$this->audit($user,'attendance.coordinator_saved','attendance',(int)$id,['before'=>$r['status'],'after'=>$status,'remarks'=>$note]);
            }
            foreach($changed as $session)$this->exec('UPDATE faculty_room_sessions SET revision=revision+1,edited_by=?,edited_at=? WHERE id=?',[$user,$this->stamp(),$session]);
        });
    }
}
