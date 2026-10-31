<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Support/helpers.php';
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function pairedCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
function pairedReject(callable $call,string $message):void{$caught=false;try{$call();}catch(RuntimeException $e){$caught=true;}pairedCheck($caught,$message);}
$config=require BASE_PATH.'/config/database.php';$db='gbu_paired_seating_'.bin2hex(random_bytes(4));
if(!preg_match('/^gbu_paired_seating_[a-f0-9]{8}$/',$db))throw new RuntimeException('Unsafe test database.');
$server=new PDO("mysql:host={$config['host']};port={$config['port']};charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try{
    $server->exec(str_replace('gbu_exam_operations',$db,file_get_contents(BASE_PATH.'/database/schema.sql')));
    $pdo=new PDO("mysql:host={$config['host']};port={$config['port']};dbname=$db;charset=utf8mb4",$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false]);
    $pdo->exec("INSERT INTO roles(code,name) VALUES('admin','Admin'); INSERT INTO users(role_id,username,name,password_hash) VALUES(1,'test','Tester','unused'); INSERT INTO schools(code,name,short_name) VALUES('ICT','School of ICT','SOICT'),('SOE','School of Engineering','SOE'); INSERT INTO programmes(school_id,code,name,level,duration_semesters) VALUES(1,'UCS','B.Tech Computer Science and Engineering','undergraduate',8),(1,'UAI','B.Tech Artificial Intelligence','undergraduate',8),(2,'CIV','B.Tech Civil Engineering','undergraduate',8); INSERT INTO batches(programme_id,label,start_year,end_year) VALUES(1,'UCS 2026-2030',2026,2030),(1,'UCS 2024-2028',2024,2028),(2,'UAI 2024-2028',2024,2028),(3,'CIV 2026-2030',2026,2030); INSERT INTO courses(code,name) VALUES('CS101','Computing Fundamentals'),('CS301','Graph Theory'),('AI301','Machine Learning'),('CE101','Engineering Mathematics'); INSERT INTO programme_courses(programme_id,batch_id,course_id,semester,category) VALUES(1,1,1,1,'core'),(1,2,2,5,'core'),(2,3,3,5,'core'),(3,4,4,1,'core')");
    $q=$pdo->prepare("INSERT INTO students(programme_id,batch_id,roll_no_original,normalized_roll_no,name,academic_session,current_year_of_study,semester,section,status) VALUES(?,?,?,?,?,'2026-2027',?,?,'A','active')");
    foreach([[1,1,1,35,'265UCS'],[1,2,5,35,'245UCS'],[2,3,5,4,'245UAI'],[3,4,1,2,'265CIV']] as [$programme,$batch,$semester,$count,$prefix])for($i=1;$i<=$count;$i++){$roll=$prefix.sprintf('%03d',$i);$q->execute([$programme,$batch,$roll,$roll,'Demo '.$roll,(int)ceil($semester/2),$semester]);}
    $exam=new App\Exams\ExamService($pdo);$cycle=$exam->createCycle(['name'=>'Paired seating demonstration','academic_year'=>'2026-2027','exam_type'=>'mid_sem','start_date'=>'2026-10-26','end_date'=>'2026-10-27','duration'=>90,'shifts'=>[['name'=>'Morning','start'=>'10:00','end'=>'11:30','duration'=>90]]],1);$shift=(int)$pdo->query('SELECT id FROM exam_shifts')->fetchColumn();
    foreach(['2026-10-26','2026-10-27'] as $date)foreach([[1,1,1,'UCS 2026-2030'],[1,2,5,'UCS 2024-2028'],[2,3,5,'UAI 2024-2028'],[3,4,1,'CIV 2026-2030']] as [$programme,$course,$semester,$batch]){if($date==='2026-10-26'&&$programme!==1)continue;$exam->schedule(['cycle_id'=>$cycle,'shift_id'=>$shift,'course_id'=>$course,'exam_date'=>$date,'category'=>'regular','programme_id'=>$programme,'semester'=>$semester,'batch_label'=>$batch]);}
    $q=$pdo->prepare("INSERT INTO rooms(school_id,code,building,rows_count,columns_count,physical_capacity,usable_capacity,seat_order) VALUES(?,?,'ICT Block',6,12,72,72,'column_major')");
    $rooms=[];foreach([[1,'IL-101'],[1,'IL-102'],[2,'SOE-101']] as [$school,$code]){$q->execute([$school,$code]);$id=(int)$pdo->lastInsertId();$rooms[]=$id;$blocked=[];for($r=1;$r<=6;$r++)foreach([2,5,8,11] as $c)$blocked[]=$r.'-'.$c;(new App\Rooms\RoomSeatGenerator($pdo))->regenerate($id,6,12,'column_major',$blocked);}
    $pair=['left'=>'1:1:1','right'=>'1:2:5','room_ids'=>[$rooms[0],$rooms[1]]];$options=['mode'=>'paired_cohorts','pairings'=>[$pair]];$allocator=new App\Seating\SeatingAllocator($pdo);
    $result=$allocator->generate($cycle,'2026-10-26',$shift,[$rooms[0],$rooms[1]],1,'same-branch-years',$options);$id=$result['allocation_id'];
    pairedCheck($result['assigned']===70&&$result['unallocated']===0,'First/third-year pairing of the same branch failed.');pairedCheck($allocator->validate($id)['valid'],'Complete paired plan failed validation.');
    $rules=json_decode($pdo->query('SELECT rule_profile FROM seating_allocations WHERE id='.$id)->fetchColumn(),true);
    pairedCheck($rules['room_columns'][$rooms[0]][1]==='1:1:1'&&$rules['room_columns'][$rooms[0]][3]==='1:2:5','Fully disabled columns disrupted alternating groups.');
    $rolls=$pdo->query("SELECT st.normalized_roll_no FROM seating_assignments a JOIN students st ON st.id=a.student_id JOIN room_seats rs ON rs.id=a.seat_id WHERE a.allocation_id=$id AND a.room_id={$rooms[0]} AND rs.column_no=1 ORDER BY rs.row_no")->fetchAll(PDO::FETCH_COLUMN);pairedCheck($rolls===array_map(static fn(int $n):string=>'265UCS'.sprintf('%03d',$n),range(1,6)),'Roll order does not run down each desk column.');
    $limited=$allocator->generate($cycle,'2026-10-27',$shift,[$rooms[0],$rooms[1]],1,'unselected-students',$options);pairedCheck($limited['assigned']===70&&$limited['unallocated']===6,'An unselected third group was added to paired rooms or silently omitted.');
    $different=['left'=>'1:1:1','right'=>'2:3:5','room_ids'=>[$rooms[0]]];$diff=$allocator->generate($cycle,'2026-10-27',$shift,[$rooms[0]],1,'different-branches',['mode'=>'paired_cohorts','pairings'=>[$different]]);pairedCheck($diff['assigned']===28,'Two different branches did not retain their separate column capacity.');
    $bad=$pair;$bad['room_ids']=[$rooms[2]];pairedReject(fn()=>$allocator->generate($cycle,'2026-10-26',$shift,[$rooms[2]],1,'bad-school',['mode'=>'paired_cohorts','pairings'=>[$bad]]),'Wrong-school pairing room accepted.');
    $bad=$pair;$bad['right']=$bad['left'];pairedReject(fn()=>$allocator->generate($cycle,'2026-10-26',$shift,[$rooms[0]],1,'same-group',['mode'=>'paired_cohorts','pairings'=>[$bad]]),'Identical cohorts accepted.');
    pairedReject(fn()=>$allocator->generate($cycle,'2026-10-26',$shift,[$rooms[0],$rooms[1]],1,'duplicate-room',['mode'=>'paired_cohorts','pairings'=>[$pair,$pair]]),'Room reused by two pairings.');
    $roster=(new App\Seating\SeatingRoster($pdo))->eligible($cycle,'2026-10-27',$shift);$seats=$pdo->query('SELECT rs.id AS seat_id,rs.room_id,rs.column_no,rs.row_no,r.school_id FROM room_seats rs JOIN rooms r ON r.id=rs.room_id WHERE rs.is_blocked=0')->fetchAll();$cross=$pair;$cross['right']='3:4:1';pairedReject(fn()=>(new App\Seating\PairedCohortPlanner())->plan($roster,$seats,[$cross]),'Groups from different schools accepted.');
    $wrong=(int)$pdo->query('SELECT id FROM room_seats WHERE room_id='.$rooms[0].' AND column_no=3 AND row_no=1')->fetchColumn();pairedReject(fn()=>$allocator->assertPairingSeat($id,1,$wrong),'Manual move into other group column accepted.');
    $document=(new App\Seating\SeatingPlanDocument($pdo))->build($id);pairedCheck(count($document['rooms'])===2&&$document['rooms'][0]['assigned_count']===48,'Room document lost its geometry or total.');pairedCheck($document['rooms'][0]['summary'][0]['count']===24,'Room summary count incorrect.');
    pairedCheck(App\Seating\SeatingPlanDocument::rollRanges(['A001','A002','A004'])==='A001 to A002, A004','Roll ranges falsely include a missing student.');
    $bytes=(new App\Export\SeatingPlanXlsx())->build($document);$out=BASE_PATH.'/outputs/seating-redesign-20261024';if(!is_dir($out))mkdir($out,0770,true);file_put_contents($out.'/app-generated-paired-seating.xlsx',$bytes);file_put_contents($out.'/sample-document.json',json_encode($document,JSON_PRETTY_PRINT|JSON_THROW_ON_ERROR));
    $zip=new ZipArchive();pairedCheck($zip->open($out.'/app-generated-paired-seating.xlsx')===true,'Export is not a valid ZIP.');
    foreach(range(1,3) as $sheet){$xml=$zip->getFromName('xl/worksheets/sheet'.$sheet.'.xml');$dom=new DOMDocument();pairedCheck($dom->loadXML($xml),'Invalid worksheet XML.');$xp=new DOMXPath($dom);$xp->registerNamespace('s','http://schemas.openxmlformats.org/spreadsheetml/2006/main');$seen=[];foreach($xp->query('//s:c') as $cell){$ref=$cell->getAttribute('r');pairedCheck(!isset($seen[$ref]),'Duplicate exported cell '.$ref);$seen[$ref]=true;}pairedCheck(str_contains($xml,'orientation="landscape"'),'Landscape print layout missing.');}
    $roomXml=$zip->getFromName('xl/worksheets/sheet2.xml');foreach(['WHITE BOARD','Left Side of Invigilator','Right Side of Invigilator','Student Detail','No. of Student','DESK-1'] as $label)pairedCheck(str_contains($roomXml,$label),'Reference label missing: '.$label);pairedCheck($zip->getFromName('xl/drawings/drawing2.xml')!==false,'Original invigilator marker missing.');$zip->close();
    // Check actual correction, publication, view and export handlers against this isolated database.
    $app=new App\Foundation\Application(BASE_PATH);$app->boot();$database=new App\Foundation\Database(array_merge($config,['database'=>$db]));(new ReflectionProperty($database,'connection'))->setValue($database,$pdo);(new ReflectionProperty($app,'database'))->setValue($app,$database);(new ReflectionProperty($app,'auth'))->setValue($app,new App\Auth\Auth($database,$app->session()));$app->session()->put('user',['id'=>1,'name'=>'Tester','role_code'=>'admin','role_name'=>'Admin']);
    $_GET=['cycle_id'=>$cycle];$_POST=[];$request=App\Http\Request::capture();$invoke=static fn(string $method,...$args):mixed=>(new ReflectionMethod($app,$method))->invoke($app,...$args);
    set_error_handler(static function(int $severity,string $message,string $file,int $line):never{throw new ErrorException($message,0,$severity,$file,$line);});
    try{$generate=$invoke('seatingGenerateData',$request);$preview=$invoke('seatingPreviewData',$id);$html=App\View\View::render('seating/preview',$preview);file_put_contents($out.'/sample-preview.html',$html);file_put_contents($out.'/sample-generator.html',App\View\View::render('seating/generate',$generate));pairedCheck(str_contains($html,'Download Excel'),'Excel download action missing.');}finally{restore_error_handler();}
    $response=$invoke('seatingPlanXlsx',$id);pairedCheck(strlen((new ReflectionProperty($response,'content'))->getValue($response))>1000,'Excel route did not return workbook bytes.');
    $roomResponse=$invoke('roomLayoutXlsx',$rooms[0]);pairedCheck(strlen((new ReflectionProperty($roomResponse,'content'))->getValue($roomResponse))>1000,'Room geometry Excel handler did not return workbook bytes.');
    $roomView=App\View\View::render('rooms/layout',$invoke('roomLayoutData',$rooms[0]));pairedCheck(str_contains($roomView,'/layout.xlsx'),'Room layout download action is missing.');
    $roomDirectory=$invoke('roomData',$request);foreach(['active','inactive','maintenance'] as $i=>$roomStatus)$roomDirectory['rooms'][$i]['status']=$roomStatus;
    $directoryHtml=App\View\View::render('rooms/index',$roomDirectory);file_put_contents($out.'/sample-rooms.html',$directoryHtml);
    foreach(['active','inactive','maintenance'] as $roomStatus)pairedCheck(str_contains($directoryHtml,'data-room-status="'.$roomStatus.'"'),'Room directory did not render '.$roomStatus.' status.');
    $roomDirectory['rooms']=[];file_put_contents($out.'/sample-rooms-empty.html',App\View\View::render('rooms/index',$roomDirectory));
    $_POST=['_token'=>$app->session()->csrfToken(),'cycle_id'=>$cycle,'exam_date'=>'2026-10-26','shift_id'=>$shift,'pairings'=>[$pair]];
    $invoke('generateSeating',$request);pairedCheck(str_contains($app->session()->pullFlash('success',''),'70 students assigned'),'Generation form did not submit pairings correctly.');
    $generatedRules=json_decode($pdo->query('SELECT rule_profile FROM seating_allocations ORDER BY id DESC LIMIT 1')->fetchColumn(),true);pairedCheck($generatedRules['mode']==='paired_cohorts','Generation form saved legacy rules.');
    $pending=$pdo->query('SELECT * FROM seating_unallocated WHERE allocation_id='.$limited['allocation_id'].' AND student_id=71')->fetch();$vacant=(int)$pdo->query('SELECT id FROM room_seats WHERE room_id='.$rooms[1].' AND column_no=12 AND row_no=6')->fetchColumn();
    $_POST=['_token'=>$app->session()->csrfToken(),'unallocated_id'=>$pending['id'],'seat_id'=>$vacant];$invoke('assignUnallocated',$request,$limited['allocation_id']);pairedCheck(str_contains($app->session()->pullFlash('error',''),'pairing'),'Unallocated form bypassed saved pairing.');
    $row=$pdo->query("SELECT * FROM seating_assignments WHERE allocation_id=$id AND student_id=1")->fetch();$_POST=['_token'=>$app->session()->csrfToken(),'assignment_id'=>$row['id'],'seat_id'=>$wrong,'reason'=>'Pairing check'];$invoke('moveSeating',$request,$id);pairedCheck(str_contains($app->session()->pullFlash('error',''),'pairing'),'Manual form bypassed pairing rule.');
    // Automatic pairing uses balanced reservations, shared rooms, and optional final cohorts.
    $automaticPairs=[['left'=>'1:1:1','right'=>'2:3:5','room_ids'=>[$rooms[0]]]];
    pairedReject(fn()=>$allocator->generate($cycle,'2026-10-27',$shift,$rooms,1,'same-branch-blocked',['mode'=>'paired_cohorts','allocation_mode'=>'automatic_pairs','pairings'=>[$pair]]),'Automatic generation accepted same-branch batches.');
    $auto=$allocator->generate($cycle,'2026-10-27',$shift,$rooms,1,'automatic-carry-over',['mode'=>'paired_cohorts','allocation_mode'=>'automatic_pairs','pairings'=>$automaticPairs,'seat_remaining'=>true]);
    pairedCheck($auto['assigned']===10&&$auto['unallocated']===66,'Automatic branch separation or final remaining cohort allocation failed.');
    $autoChecks=$allocator->validate($auto['allocation_id']);
    pairedCheck($autoChecks['same_paper_neighbours']===0,'Generated seats violated paper separation.');
    pairedCheck($autoChecks['same_branch_neighbours']===0&&!$autoChecks['valid'],'Branch-separated draft validation failed to report its shortages.');
    $profile=$pdo->query('SELECT rule_profile FROM seating_allocations WHERE id='.$auto['allocation_id'])->fetchColumn();$tampered=json_decode($profile,true);$tampered['cohorts']['2:3:5']['programme_id']=1;
    $pdo->prepare('UPDATE seating_allocations SET rule_profile=? WHERE id=?')->execute([json_encode($tampered),$auto['allocation_id']]);
    pairedCheck($allocator->validate($auto['allocation_id'])['same_branch_neighbours']>0,'Publication check missed same-branch neighbours.');
    $pdo->prepare('UPDATE seating_allocations SET rule_profile=? WHERE id=?')->execute([$profile,$auto['allocation_id']]);
    // Separate examination records for different branches can still share one paper.
    $sharedExam=(int)$pdo->query("SELECT id FROM examinations WHERE cycle_id=$cycle AND exam_date='2026-10-27' AND course_id=3")->fetchColumn();
    $pdo->prepare("UPDATE examinations SET course_id=1,category='back_paper' WHERE id=?")->execute([$sharedExam]);
    pairedCheck($allocator->validate($auto['allocation_id'])['same_paper_neighbours']>0,'Publication missed a shared paper across branches.');
    $ownSeat=(int)$pdo->query('SELECT seat_id FROM seating_assignments WHERE allocation_id='.$auto['allocation_id'].' AND student_id=1')->fetchColumn();
    pairedReject(fn()=>$allocator->assertPairingSeat($auto['allocation_id'],1,$ownSeat),'Manual correction allowed a neighbour with the same paper.');
    pairedReject(fn()=>$allocator->generate($cycle,'2026-10-27',$shift,$rooms,1,'shared-paper-blocked',['mode'=>'paired_cohorts','allocation_mode'=>'automatic_pairs','pairings'=>$automaticPairs]),'Automatic generation accepted a shared paper across branches.');
    $pdo->prepare("UPDATE examinations SET course_id=3,category='regular' WHERE id=?")->execute([$sharedExam]);
    // An afternoon paper must also prevent unsafe pairing in the morning.
    $pdo->prepare("INSERT INTO exam_shifts(cycle_id,name,start_time,end_time,duration_minutes,sequence_no) VALUES(?,'Afternoon','14:00','15:30',90,2)")->execute([$cycle]);$afternoon=(int)$pdo->lastInsertId();
    $pdo->prepare("INSERT INTO examinations(cycle_id,shift_id,course_id,exam_date,category) VALUES(?,?,1,'2026-10-27','back_paper')")->execute([$cycle,$afternoon]);$dayExam=(int)$pdo->lastInsertId();
    $pdo->prepare("INSERT INTO exam_eligibility(examination_id,student_id,source) VALUES(?,71,'manual')")->execute([$dayExam]);
    $morning=(new App\Seating\SeatingRoster($pdo))->eligible($cycle,'2026-10-27',$shift);$dayGroups=App\Seating\SeatingRoster::groups($morning);
    pairedCheck(count($morning)===76&&in_array('course:1',$dayGroups['2:3:5']['paper_ids'],true),'Morning roster lost its whole-day paper restriction or included afternoon students.');
    pairedReject(fn()=>$allocator->generate($cycle,'2026-10-27',$shift,$rooms,1,'afternoon-paper-conflict',['mode'=>'paired_cohorts','allocation_mode'=>'automatic_pairs','pairings'=>$automaticPairs]),'Morning generation ignored an afternoon shared paper.');
    pairedCheck($allocator->validate($auto['allocation_id'])['same_paper_neighbours']>0,'Publication ignored a shared paper in another shift.');
    pairedReject(fn()=>$allocator->assertPairingSeat($auto['allocation_id'],1,$ownSeat),'Manual correction ignored a shared paper in another shift.');
    $pdo->prepare("UPDATE examinations SET exam_date='2026-10-26' WHERE id=?")->execute([$dayExam]);
    pairedCheck($allocator->validate($auto['allocation_id'])['same_paper_neighbours']===0,'A paper on a different day incorrectly blocked the plan.');
    $pdo->prepare('DELETE FROM examinations WHERE id=?')->execute([$dayExam]);$pdo->prepare('DELETE FROM exam_shifts WHERE id=?')->execute([$afternoon]);
    $autoDocument=(new App\Seating\SeatingPlanDocument($pdo))->build($auto['allocation_id']);
    pairedCheck(strlen((new App\Export\SeatingPlanXlsx())->build($autoDocument))>1000,'Automatic pairing Excel export failed.');
    $autoPreview=$invoke('seatingPreviewData',$auto['allocation_id']);
    pairedCheck(str_contains(App\View\View::render('seating/preview',$autoPreview),'Delete seating'),'Automatic seating preview did not render.');
    $_POST=['_token'=>$app->session()->csrfToken(),'cycle_id'=>$cycle,'exam_date'=>'2026-10-27','shift_id'=>$shift,'allocation_mode'=>'automatic_pairs','seat_remaining'=>'1','pairings'=>array_map(static fn(array $p):array=>['left'=>$p['left'],'right'=>$p['right']],$automaticPairs)];
    $invoke('generateSeating',$request);
    pairedCheck(str_contains($app->session()->pullFlash('success',''),'10 students assigned'),'Automatic form did not enforce branch separation.');
    $fallback=$allocator->generate($cycle,'2026-10-26',$shift,$rooms,1,'no-pair-alternate',['mode'=>'paired_cohorts','allocation_mode'=>'automatic_pairs','pairings'=>[],'alternate_unmatched'=>true]);
    pairedCheck($fallback['assigned']===48&&$fallback['unallocated']===22,'No-pair generation did not reserve empty partner columns.');
    $fallbackChecks=$allocator->validate($fallback['allocation_id']);pairedCheck($fallbackChecks['occupied_empty_partner_columns']===0,'Generated fallback occupied an empty partner column.');
    $fallbackDocument=(new App\Seating\SeatingPlanDocument($pdo))->build($fallback['allocation_id']);$fallbackFile=$out.'/empty-partner-seating.xlsx';file_put_contents($fallbackFile,(new App\Export\SeatingPlanXlsx())->build($fallbackDocument));
    $fallbackZip=new ZipArchive();pairedCheck($fallbackZip->open($fallbackFile)===true,'Fallback allocation export failed.');$fallbackSheet=new DOMDocument();$fallbackSheet->loadXML($fallbackZip->getFromName('xl/worksheets/sheet2.xml'));$fallbackPath=new DOMXPath($fallbackSheet);$fallbackPath->registerNamespace('s','http://schemas.openxmlformats.org/spreadsheetml/2006/main');
    pairedCheck($fallbackPath->evaluate('string(//s:c[@r="A4"]/s:is/s:t)')!==''&&$fallbackPath->evaluate('string(//s:c[@r="C4"]/s:is/s:t)')==='','Excel did not show an allocated column beside its empty partner.');$fallbackZip->close();
    $reservedSeat=(int)$pdo->query('SELECT id FROM room_seats WHERE room_id='.$rooms[0].' AND row_no=1 AND column_no=3')->fetchColumn();
    pairedReject(fn()=>$allocator->assertPairingSeat($fallback['allocation_id'],1,$reservedSeat),'Manual correction filled a reserved partner column.');
    $fallbackAssignment=$pdo->query('SELECT id,seat_id FROM seating_assignments WHERE allocation_id='.$fallback['allocation_id'].' AND student_id=1')->fetch();
    $pdo->prepare('UPDATE seating_assignments SET seat_id=? WHERE id=?')->execute([$reservedSeat,$fallbackAssignment['id']]);
    pairedCheck($allocator->validate($fallback['allocation_id'])['occupied_empty_partner_columns']===1,'Publication missed a reserved-column violation.');
    $pdo->prepare('UPDATE seating_assignments SET seat_id=? WHERE id=?')->execute([$fallbackAssignment['seat_id'],$fallbackAssignment['id']]);
    $_POST=['_token'=>$app->session()->csrfToken(),'cycle_id'=>$cycle,'exam_date'=>'2026-10-26','shift_id'=>$shift,'allocation_mode'=>'automatic_pairs','seat_remaining'=>'2','pairings'=>[]];$invoke('generateSeating',$request);
    pairedCheck(str_contains($app->session()->pullFlash('success',''),'48 students assigned'),'No-pair form did not generate an alternating-column draft.');
    $_POST=['_token'=>$app->session()->csrfToken(),'cycle_id'=>$cycle,'exam_date'=>'2026-10-26','shift_id'=>$shift,'allocation_mode'=>'automatic_pairs','seat_remaining'=>'2','pairings'=>[$pair]];$invoke('generateSeating',$request);
    pairedCheck(str_contains($app->session()->pullFlash('success',''),'48 students assigned'),'A stale same-branch form still blocked alternating-column generation.');
    // Tampering outside the normal form must still prevent publication.
    $pdo->prepare('UPDATE seating_assignments SET student_id=71 WHERE id=?')->execute([$row['id']]);$checks=$allocator->validate($id);pairedCheck($checks['pairing_mismatches']===1&&!$checks['valid'],'Third cohort was not detected by publication validation.');$_POST=['_token'=>$app->session()->csrfToken()];$invoke('publishSeating',$request,$id);pairedCheck($pdo->query('SELECT status FROM seating_allocations WHERE id='.$id)->fetchColumn()==='draft','Invalid paired version published.');
    echo "Paired seating: PASS (same/different branches, years, room continuity, disabled columns, roll order, shortages, school isolation, manual guards, publication, HTML and Excel)\n";
}finally{if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack();$server->exec("DROP DATABASE IF EXISTS `$db`");}
