<?php
declare(strict_types=1);
namespace App\Academic;

use App\Http\Request;
use App\Http\Response;
use App\View\View;
use PDO;
use RuntimeException;
use Throwable;

final class AcademicRolloverController
{
    public function __construct(private readonly PDO $pdo) {}

    public function handle(Request $request,string $path):Response
    {
        $service=new AcademicRollover($this->pdo);$today=date('Y-m-d');
        if($request->method()==='POST'){
            try{
                if(!app()->session()->validCsrf((string)$request->input('_token')))throw new RuntimeException('Session token expired. Reload the page.');
                $actor=(int)app()->auth()->user()['id'];
                if($path==='/academic-rollover/settings'){
                    $service->saveSettings($request->input('enabled')==='1',trim((string)$request->input('session_start')),trim((string)$request->input('even_start')),$actor);
                    app()->session()->flash('success','Academic calendar saved. Review the preview before reconciling current records.');
                }elseif($path==='/academic-rollover/run'){
                    $result=$service->run($today,$actor,'manual',true);
                    app()->session()->flash('success',!empty($result['skipped'])?'Automatic progression is disabled. Enable it before running reconciliation.':$result['updated'].' student records updated; '.$result['registrations'].' core registrations added.');
                }elseif(preg_match('#^/academic-rollover/cycles/(\d+)/session$#',$path,$m)){
                    $this->pdo->beginTransaction();
                    try{
                        $q=$this->pdo->prepare("SELECT * FROM exam_cycles WHERE id=? AND status='draft' FOR UPDATE");$q->execute([(int)$m[1]]);$cycle=$q->fetch(PDO::FETCH_ASSOC);
                        if(!$cycle)throw new RuntimeException('Only an empty draft cycle can have its session aligned.');
                        $q=$this->pdo->prepare('SELECT COUNT(*) FROM examinations WHERE cycle_id=?');$q->execute([$cycle['id']]);
                        if((int)$q->fetchColumn())throw new RuntimeException('This cycle already contains papers. Create a new correctly dated cycle instead.');
                        $session=$service->calendar()->period($cycle['start_date'])['academic_session'];
                        $this->pdo->prepare('UPDATE exam_cycles SET academic_year=? WHERE id=?')->execute([$session,$cycle['id']]);
                        $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,old_values,new_values) VALUES(?,'exam_cycle.session_aligned','exam_cycle',?,?,?)")->execute([$actor,$cycle['id'],json_encode(['academic_year'=>$cycle['academic_year']]),json_encode(['academic_year'=>$session])]);
                        $this->pdo->commit();app()->session()->flash('success','Empty draft cycle aligned to '.$session.'.');
                    }catch(Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
                }elseif(preg_match('#^/academic-rollover/students/(\d+)/control$#',$path,$m)){
                    if($request->input('mode')==='completed'&&$request->input('completion_confirmed')!=='1')throw new RuntimeException('Confirm that programme completion has been verified.');
                    $service->setControl((int)$m[1],(string)$request->input('mode'),(int)$request->input('semester_delay'),trim((string)$request->input('reason')),$actor);
                    $service->run($today,$actor,'exception',true);
                    app()->session()->flash('success','Progression rule saved and current placements reconciled.');
                    return Response::redirect(url('academic-rollover/students/'.$m[1]));
                }else return Response::html(View::render('errors/404'),404);
            }catch(Throwable $e){app()->session()->flash('error',$e->getMessage());}
            return Response::redirect(url('academic-rollover'));
        }
        if($request->method()!=='GET')return Response::html(View::render('errors/404'),404);
        $flashes=['success'=>app()->session()->pullFlash('success'),'error'=>app()->session()->pullFlash('error')];
        if(preg_match('#^/academic-rollover/students/(\d+)$#',$path,$m)){
            $q=$this->pdo->prepare('SELECT s.*,b.label AS batch_label,p.name AS programme_name FROM students s LEFT JOIN batches b ON b.id=s.batch_id LEFT JOIN programmes p ON p.id=s.programme_id WHERE s.id=?');$q->execute([(int)$m[1]]);$student=$q->fetch(PDO::FETCH_ASSOC);
            if(!$student)return Response::html(View::render('errors/404'),404);
            $q=$this->pdo->prepare('SELECT t.*,(SELECT COUNT(*) FROM student_course_registrations r WHERE r.enrollment_id=t.id) AS course_count FROM student_term_enrollments t WHERE student_id=? ORDER BY academic_session DESC,term DESC');$q->execute([$student['id']]);
            return Response::html(View::render('academic/student',compact('student')+$service->detail((int)$student['id'])+['terms'=>$q->fetchAll(PDO::FETCH_ASSOC)]+$flashes));
        }
        if($path!=='/academic-rollover')return Response::html(View::render('errors/404'),404);
        $date=(string)$request->input('preview_date',$today);
        $review=(string)$request->input('review','all');if(!in_array($review,['all','blocked','updates','missing_curriculum','held','awaiting_completion','withdrawn','completed','active','not_started'],true))$review='all';
        $page=max(1,(int)$request->input('page',1));
        try{$preview=$service->preview($date,100,$review,$page);}catch(Throwable $e){$date=$today;$preview=$service->preview($date,100,$review,$page);$flashes['error']=$e->getMessage();}
        $runs=$this->pdo->query('SELECT r.*,u.name AS actor_name FROM academic_rollover_runs r LEFT JOIN users u ON u.id=r.actor_id ORDER BY r.id DESC LIMIT 20')->fetchAll(PDO::FETCH_ASSOC);
        $cycles=[];$calendar=$service->calendar();
        foreach($this->pdo->query("SELECT id,name,start_date,academic_year FROM exam_cycles WHERE status='draft'")->fetchAll(PDO::FETCH_ASSOC) as $cycle){preg_match('/^(\d{4})/',$cycle['academic_year'],$m);if((int)($m[1]??0)!==$calendar->period($cycle['start_date'])['session_start_year'])$cycles[]=$cycle;}
        return Response::html(View::render('academic/rollover',['settings'=>$service->settings(),'preview'=>$preview,'previewDate'=>$date,'runs'=>$runs,'mismatchedCycles'=>$cycles]+$flashes));
    }
}
