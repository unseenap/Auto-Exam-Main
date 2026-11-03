<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function fpCheck(bool $value,string $message):void{if(!$value)throw new RuntimeException($message);}
function fpReject(callable $call,string $text='',?int $status=null):void{try{$call();}catch(App\Faculty\PortalException $e){fpCheck($text===''||str_contains($e->getMessage(),$text),'Wrong error: '.$e->getMessage());fpCheck($status===null||$e->httpStatus===$status,'Wrong error status');return;}throw new RuntimeException('Forbidden operation succeeded: '.$text);}
$c=require BASE_PATH.'/config/database.php';$db='gbu_faculty_portal_'.bin2hex(random_bytes(4));
$server=new PDO("mysql:host={$c['host']};port={$c['port']};charset=utf8mb4",$c['username'],$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$c['host']};port={$c['port']};dbname=$db;charset=utf8mb4",$c['username'],$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false]);
    App\Faculty\FacultyPortalMigration::apply($pdo);App\Faculty\FacultyPortalMigration::apply($pdo);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'),('faculty','Faculty / Invigilator'),('invigilation_coordinator','Invigilation coordinator'),('viewer','Viewer'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'admin','Administrator','unused'),(2,'fac.a','Dr Aditi Sharma','unused'),(2,'fac.b','Dr Bharat Singh','unused'),(2,'fac.other','Other Invigilator','unused'),(2,'fac.unlinked','Unlinked Faculty','unused'),(3,'coordinator','Coordinator','unused'),(4,'viewer','Viewer','unused'),(2,'fac.replacement','Replacement Faculty','unused'); INSERT INTO schools(code,name) VALUES('ICT','School of ICT'); INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','Computer Science','undergraduate',8),(1,'UAI','Artificial Intelligence','undergraduate',8); INSERT INTO batches(programme_id,label,start_year,end_year) VALUES(1,'UCS 2023-2027',2023,2027),(2,'UAI 2023-2027',2023,2027); INSERT INTO faculty(school_id,employee_id,name,email) VALUES(1,'F001','Dr Aditi Sharma','a@example.test'),(1,'F002','Dr Bharat Singh','b@example.test'),(1,'F003','Other Invigilator','other@example.test'),(1,'F004','Replacement Faculty','replace@example.test'); INSERT INTO courses(code,name) VALUES('CS301','Algorithms'),('AI301','Machine Learning'); INSERT INTO rooms(school_id,code,building,floor,rows_count,columns_count,physical_capacity,usable_capacity) VALUES(1,'IL-202','ICT Block','2',2,3,6,5),(1,'IL-203','ICT Block','2',1,1,1,1)");
    $pdo->prepare('UPDATE users SET password_hash=?')->execute([password_hash('SyntheticPassword12!',PASSWORD_DEFAULT)]);
    $clock=new DateTimeImmutable('2026-11-03 10:00:00',new DateTimeZone('Asia/Kolkata'));$service=new App\Faculty\FacultyPortalService($pdo,$clock);
    foreach([2=>1,3=>2,4=>3,8=>4] as $user=>$faculty){$pdo->beginTransaction();$service->linkAccount(1,$user,$faculty);$pdo->commit();}
    fpReject(fn()=>$service->faculty(5),'not linked',403);fpReject(fn()=>$service->linkAccount(6,5,4),'administrator',403);fpReject(fn()=>$service->linkAccount(1,5,1),'already linked');fpReject(fn()=>$service->linkAccount(1,7,1),'role');
    $insert=$pdo->prepare("INSERT INTO students(programme_id,batch_id,roll_no_original,normalized_roll_no,enrollment_number,name,academic_session,current_year_of_study,semester,section,parsing_status,admission_type) VALUES(?,?,?,?,?,?,'2026-2027',4,7,'A','verified',?)");
    foreach([[1,1,'235UCS001','0000100001','Aarav Kumar','regular'],[1,1,'245LCS001','0000100002','Ananya Singh','lateral'],[2,2,'235UAI001','0000100003','Kabir Verma','regular'],[1,1,'235UCS004','0000100004','Other room student','regular']] as [$programme,$batch,$roll,$enroll,$name,$type])$insert->execute([$programme,$batch,$roll,$roll,$enroll,$name,$type]);
    $exams=new App\Exams\ExamService($pdo);$cycle=$exams->createCycle(['name'=>'End Semester Examination 2026','academic_year'=>'2026-2027','exam_type'=>'end_sem','start_date'=>'2026-11-03','end_date'=>'2026-11-04','duration'=>180,'batch_ids'=>[1,2],'shifts'=>[['name'=>'Morning','start'=>'09:30','end'=>'12:30','duration'=>180]]],1);$shift=(int)$pdo->query('SELECT id FROM exam_shifts LIMIT 1')->fetchColumn();
    $pdo->exec("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,status) VALUES($cycle,$shift,1,'2026-11-03','published'),($cycle,$shift,2,'2026-11-03','published'); INSERT INTO seating_allocations(cycle_id,exam_date,shift_id,version_no,seed_value,rule_profile,status,generated_by,generated_at) VALUES($cycle,'2026-11-03',$shift,1,'test','{}','published',1,'2026-11-03 08:00:00')");
    (new App\Rooms\RoomSeatGenerator($pdo))->regenerate(1,2,3,'row_major',['1-2']);(new App\Rooms\RoomSeatGenerator($pdo))->regenerate(2,1,1,'row_major',[]);
    $seats=$pdo->query('SELECT id FROM room_seats WHERE room_id=1 AND is_blocked=0 ORDER BY sequence_no')->fetchAll(PDO::FETCH_COLUMN);
    $otherSeat=(int)$pdo->query('SELECT id FROM room_seats WHERE room_id=2')->fetchColumn();
    foreach([[1,1,1,$seats[0]],[2,1,1,$seats[1]],[3,2,1,$seats[2]],[4,1,2,$otherSeat]] as [$student,$exam,$room,$seat]){
        $pdo->prepare('INSERT INTO seating_assignments(allocation_id,examination_id,student_id,room_id,seat_id) VALUES(1,?,?,?,?)')->execute([$exam,$student,$room,$seat]);
        $pdo->prepare('INSERT INTO attendance(allocation_id,examination_id,student_id,room_id) VALUES(1,?,?,?)')->execute([$exam,$student,$room]);
    }
    foreach([[1,1],[2,1],[3,2]] as [$faculty,$room])$pdo->prepare("INSERT INTO invigilation_allocations(cycle_id,exam_date,shift_id,room_id,faculty_id,assigned_by) VALUES(?,'2026-11-03',?,?,?,1)")->execute([$cycle,$shift,$room,$faculty]);
    fpCheck(count($service->duties(2))===1,'Faculty sees other assignments');fpReject(fn()=>$service->room(2,3),'not assigned',403);
    $data=$service->room(2,1);fpCheck(count($data['records'])===3&&count($data['seats'])===6,'Room geometry or student scope incorrect');fpCheck($data['window']['reporting']==='09:00','Reporting interval wrong');
    // Render real pages for browser verification, using only synthetic records.
    $app=new App\Foundation\Application(BASE_PATH);$app->boot();$database=new App\Foundation\Database(array_merge($c,['database'=>$db]));(new ReflectionProperty($database,'connection'))->setValue($database,$pdo);(new ReflectionProperty($app,'database'))->setValue($app,$database);(new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));
    $login=function(int $id,string $role='faculty')use($app){$app->session()->put('user',['id'=>$id,'username'=>'synthetic','name'=>$id===2?'Dr Aditi Sharma':'Synthetic user','role_code'=>$role,'role_name'=>ucfirst($role)]);};$login(2);
    $out=BASE_PATH.'/outputs/faculty-panel';if(!is_dir($out))mkdir($out,0770,true);$_SERVER['REQUEST_URI']='/faculty-panel/duties/1';
    file_put_contents($out.'/room.html',App\View\View::render('faculty-panel/room',$data+['faculty'=>$service->faculty(2),'success'=>null,'error'=>null]));
    file_put_contents($out.'/snapshot.json',json_encode(['revision'=>0,'state'=>$data['state'],'records'=>$data['records'],'window'=>$data['window']],JSON_THROW_ON_ERROR));
    file_put_contents($out.'/home.html',App\View\View::render('faculty-panel/home',['faculty'=>$service->faculty(2),'duties'=>$service->duties(2),'today'=>'2026-11-03','settings'=>$service->settings(),'tab'=>'faculty-panel','next'=>$service->duties(2)[0],'success'=>null,'error'=>null]));
    $service->acknowledge(2,1);fpCheck((int)$pdo->query('SELECT COUNT(*) FROM faculty_duty_acknowledgments')->fetchColumn()===1,'Acknowledgment missing');
    fpReject(fn()=>$service->mark(2,1,4,'present','',0),'outside your assigned room',403);
    $service->mark(2,1,1,'present','',0);fpReject(fn()=>$service->mark(3,2,2,'absent','',0),'Another invigilator',409);
    fpReject(fn()=>$service->mark(2,1,3,'unfair_means','',1),'Remarks');
    fpReject(fn()=>$service->submit(2,1,1),'245LCS001');
    $service->mark(3,2,2,'absent','',1);$service->mark(2,1,3,'withheld','Answer book held for review',2);$service->submit(2,1,3);
    fpReject(fn()=>$service->mark(2,1,1,'absent','',4),'locked',409);
    fpReject(fn()=>$service->coordinatorAttendance(6,1,[1=>'absent'],[1=>4]),'submitted',409);
    fpReject(fn()=>$service->closeReport(2,1,4,[1=>'1',2=>'1'],false,'',''),'handed over');
    fpReject(fn()=>$service->closeReport(2,1,4,[1=>'2',2=>'1'],true,'',''),'CS301 expects 1');
    $service->closeReport(2,1,4,[1=>'1',2=>'1'],true,'','');fpReject(fn()=>$service->closeReport(2,1,5,[1=>'1',2=>'1'],true,'',''),'read-only',409);
    file_put_contents($out.'/submitted.html',App\View\View::render('faculty-panel/room',$service->room(2,1)+['faculty'=>$service->faculty(2),'success'=>null,'error'=>null]));
    $late=new App\Faculty\FacultyPortalService($pdo,new DateTimeImmutable('2026-11-04 10:00:00',new DateTimeZone('Asia/Kolkata')));
    $late->correction(2,1,'Correct absent student after verified paper handover');$correction=(int)$pdo->query('SELECT id FROM faculty_correction_requests LIMIT 1')->fetchColumn();fpReject(fn()=>$late->review(7,'correction',$correction,true),'authorized',403);$late->review(6,'correction',$correction,true);
    fpCheck($late->room(2,1)['window']['allowed'],'Approved correction window did not reopen');$late->mark(2,1,2,'present','Verified by coordinator',6);
    fpCheck($pdo->query('SELECT closing_report FROM faculty_room_sessions WHERE id=1')->fetchColumn()===null,'Old closing report remained valid after correction');
    $expired=new App\Faculty\FacultyPortalService($pdo,new DateTimeImmutable('2026-11-04 12:00:00',new DateTimeZone('Asia/Kolkata')));fpReject(fn()=>$expired->mark(2,1,2,'absent','',7),'editable from',403);
    $service->availability(2,'2026-11-03',$shift,'unavailable','Medical appointment');$availability=(int)$pdo->query('SELECT id FROM faculty_availability_requests LIMIT 1')->fetchColumn();fpReject(fn()=>$service->review(6,'availability',$availability,true),'Reassign');$service->review(6,'availability',$availability,false);
    $service->availability(2,'2026-11-04',$shift,'unavailable','Medical appointment');$availability2=(int)$pdo->query('SELECT MAX(id) FROM faculty_availability_requests')->fetchColumn();$service->review(6,'availability',$availability2,true);fpCheck((int)$pdo->query('SELECT COUNT(*) FROM faculty_availability')->fetchColumn()===1,'Availability not applied');
    $service->replacement(2,1,'Cannot attend the shift');$request=(int)$pdo->query('SELECT id FROM replacement_requests LIMIT 1')->fetchColumn();fpCheck($service->duty(2,1)['duty_status']==='assigned','Pending replacement removed original duty');fpReject(fn()=>$service->review(6,'replacement',$request,true),'Choose an active');$service->review(6,'replacement',$request,true,4);
    fpReject(fn()=>$service->room(2,1),'cancelled',403);fpReject(fn()=>$service->mark(2,1,1,'absent','',7),'cancelled',403);fpCheck(count($service->duties(8))===1,'Approved replacement did not receive new duty');
    fpReject(fn()=>$service->coordinatorAttendance(7,1,[1=>'absent'],[1=>7]),'authorized',403);
    $service->changePassword(8,'SyntheticPassword12!','NewSyntheticPassword12!','NewSyntheticPassword12!');fpCheck(password_verify('NewSyntheticPassword12!',$pdo->query('SELECT password_hash FROM users WHERE id=8')->fetchColumn()),'Password change failed');
    // Exercise real route permission checks, CSRF and object ownership.
    $call=function(string $path,array $post=[])use($app){$_POST=$post;$_GET=[];$_SERVER['REQUEST_METHOD']=$post?'POST':'GET';$_SERVER['REQUEST_URI']=$path;$_SERVER['SCRIPT_NAME']='/index.php';return $app->handle(App\Http\Request::capture());};
    $login(2);foreach(['/seating','/attendance/1','/users','/faculty-operations','/faculty-panel/duties/3/snapshot'] as $path){$response=$call($path);fpCheck((new ReflectionProperty($response,'status'))->getValue($response)===403,'Unauthorized route exposed: '.$path);}
    $login(3);$response=$call('/faculty-panel/duties/2/mark',['_token'=>'bad','record_id'=>1,'status'=>'present','revision'=>7]);fpCheck((new ReflectionProperty($response,'status'))->getValue($response)===403,'CSRF bypass');
    $login(5);$response=$call('/faculty-panel');fpCheck((new ReflectionProperty($response,'status'))->getValue($response)===403,'Unlinked account admitted');
    $login(8);$pdo->exec("UPDATE users SET status='locked' WHERE id=8");fpReject(fn()=>$service->room(8,4),'not linked',403);
    $login(1,'admin');$_SERVER['REQUEST_URI']='/users';$users=(new ReflectionMethod($app,'userData'))->invoke($app);file_put_contents($out.'/users.html',App\View\View::render('users/index',$users));
    $_POST=['_token'=>$app->session()->csrfToken(),'username'=>'new.faculty','name'=>'New Faculty','role_id'=>2,'status'=>'active','password'=>'NewFacultyPassword12!','faculty_id'=>null];
    $pdo->exec("INSERT INTO faculty(school_id,employee_id,name) VALUES(1,'F005','New Faculty')");$_POST['faculty_id']=5;$_SERVER['REQUEST_METHOD']='POST';$_SERVER['REQUEST_URI']='/users';
    (new ReflectionMethod($app,'saveUser'))->invoke($app,App\Http\Request::capture());
    $newUser=(int)$pdo->query("SELECT id FROM users WHERE username='new.faculty'")->fetchColumn();fpCheck($newUser>0&&$service->faculty($newUser)['employee_id']==='F005','Administrator create form did not link faculty account');
    $login(3);$_SERVER['REQUEST_URI']='/faculty-panel/profile';$controller=new App\Faculty\FacultyPortalController($pdo);$_SERVER['REQUEST_METHOD']='GET';$_POST=[];
    $profile=$controller->handle(App\Http\Request::capture(),'/faculty-panel/profile');file_put_contents($out.'/profile.html',(new ReflectionProperty($profile,'content'))->getValue($profile));
    $login(6,'invigilation_coordinator');$_SERVER['REQUEST_URI']='/faculty-operations';$operations=$controller->handle(App\Http\Request::capture(),'/faculty-operations');file_put_contents($out.'/operations.html',(new ReflectionProperty($operations,'content'))->getValue($operations));
    // Coordinator saves must still work on another editable room and reject stale forms.
    $service->session(1,2);$service->coordinatorAttendance(6,1,[4=>'present'],[2=>0]);fpReject(fn()=>$service->coordinatorAttendance(6,1,[4=>'absent'],[2=>0]),'changed',409);
    fpCheck((int)$pdo->query("SELECT COUNT(*) FROM audit_logs WHERE action='faculty.attendance_submitted'")->fetchColumn()===1,'Submission audit missing');
    echo "Faculty portal: PASS (migration, account links, room ownership, CSRF/routes, attendance/revision conflicts, final locks, report counts, corrections, replacements, availability conflicts, password and audit)\n";
}finally{if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();$server->exec("DROP DATABASE IF EXISTS `$db`");}
