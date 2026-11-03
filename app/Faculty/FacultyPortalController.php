<?php
declare(strict_types=1);
namespace App\Faculty;
use App\Http\Request;
use App\Http\Response;
use App\View\View;
use PDO;

final class FacultyPortalController
{
    public function __construct(private readonly PDO $pdo){}
    public function handle(Request $request,string $path):Response
    {
        $app=app();$user=(int)($app->auth()->user()['id']??0);$method=$request->method();$json=str_ends_with($path,'/snapshot')||str_ends_with($path,'/mark');
        FacultyPortalMigration::apply($this->pdo);$service=new FacultyPortalService($this->pdo);
        try{
            if(str_starts_with($path,'/faculty-operations'))return $this->operations($request,$path,$service,$user);
            $faculty=$service->faculty($user);
            if($method==='POST'&&!$app->session()->validCsrf((string)$request->input('_token')))throw new PortalException('Your session expired. Reload the page before trying again.',403);
            if(preg_match('#^/faculty-panel/duties/(\d+)(?:/(snapshot|mark|submit|acknowledge|replacement|correction|report))?$#',$path,$m)){
                $id=(int)$m[1];$action=$m[2]??'';
                if($method==='POST'){
                    $revision=(int)$request->input('revision',-1);
                    switch($action){
                        case 'mark':return Response::json(['ok'=>true]+$service->mark($user,$id,(int)$request->input('record_id'),(string)$request->input('status'),(string)$request->input('remarks'),$revision));
                        case 'submit':$service->submit($user,$id,$revision);$message='Room attendance submitted and locked.';break;
                        case 'acknowledge':$service->acknowledge($user,$id);$message='Duty acknowledged. Student attendance is unchanged.';break;
                        case 'replacement':$service->replacement($user,$id,(string)$request->input('reason'));$message='Replacement requested. Your duty remains assigned until the coordinator approves a replacement.';break;
                        case 'correction':$service->correction($user,$id,(string)$request->input('reason'));$message='Correction requested. Attendance stays locked until coordinator approval.';break;
                        case 'report':$service->closeReport($user,$id,$revision,(array)$request->input('books',[]),$request->input('handed_over')==='1',(string)$request->input('remarks'),(string)$request->input('incident'));$message='Room-closing report submitted.';break;
                        default:throw new PortalException('This action is unavailable.',404);
                    }
                    $app->session()->flash('success',$message);return Response::redirect(url('faculty-panel/duties/'.$id));
                }
                if($method==='GET'&&in_array($action,['','snapshot'],true)){
                    $duty=$service->duty($user,$id);
                    if($duty['duty_status']==='cancelled'){if($json)throw new PortalException('This duty was cancelled or reassigned. Reload your duties.',403);return $this->view('faculty-panel/cancelled',compact('faculty','duty'));}
                    $data=$service->room($user,$id);
                    if($action==='snapshot')return Response::json(['revision'=>(int)$data['state']['revision'],'state'=>$data['state'],'records'=>$data['records'],'window'=>$data['window']]);
                    return $this->view('faculty-panel/room',$data+compact('faculty'));
                }
            }
            if($path==='/faculty-panel/profile'){
                if($method==='POST'){
                    if($request->input('action')==='password'){$service->changePassword($user,(string)$request->input('current_password'),(string)$request->input('password'),(string)$request->input('password_confirmation'));$app->session()->regenerate();$message='Password changed.';}
                    elseif($request->input('action')==='availability'){$service->availability($user,(string)$request->input('exam_date'),(int)$request->input('shift_id'),(string)$request->input('availability'),(string)$request->input('reason'));$message='Availability request sent. Existing duties remain unchanged until coordinator review.';}
                    else throw new PortalException('Choose a valid profile action.');
                    $app->session()->flash('success',$message);return Response::redirect(url('faculty-panel/profile'));
                }
                $availability=$service->rows('SELECT ar.*,es.name AS shift_name FROM faculty_availability_requests ar JOIN exam_shifts es ON es.id=ar.shift_id WHERE ar.faculty_id=? ORDER BY ar.id DESC',[$faculty['id']]);
                $shifts=$service->rows("SELECT es.id,es.name,ec.name AS cycle_name,ec.start_date,ec.end_date FROM exam_shifts es JOIN exam_cycles ec ON ec.id=es.cycle_id WHERE ec.status='published' AND ec.end_date>=? ORDER BY ec.start_date,es.sequence_no",[$service->now()->format('Y-m-d')]);
                return $this->view('faculty-panel/profile',compact('faculty','availability','shifts'));
            }
            if($method==='GET'&&in_array($path,['/faculty-panel','/faculty-panel/duties','/faculty-panel/attendance','/faculty-panel/reports'],true)){
                $duties=$service->duties($user);$today=$service->now()->format('Y-m-d');$settings=$service->settings();$tab=basename($path);
                $next=null;foreach($duties as $d)if($d['exam_date']>=$today&&!in_array($d['duty_status'],['cancelled','completed'],true)&&$d['exam_date'].' '.$d['end_time']>=$service->now()->format('Y-m-d H:i:s')){$next=$d;break;}
                return $this->view('faculty-panel/home',compact('faculty','duties','today','settings','tab','next'));
            }
            throw new PortalException('Faculty page not found.',404);
        }catch(PortalException $e){
            if($json)return Response::json(['error'=>$e->getMessage()],$e->httpStatus);
            if($method==='POST'){$app->session()->flash('error',$e->getMessage());$back=preg_match('#^/faculty-panel/duties/(\d+)#',$path,$m)?'faculty-panel/duties/'.$m[1]:(str_starts_with($path,'/faculty-operations')?'faculty-operations':'faculty-panel/profile');return Response::redirect(url($back));}
            return Response::html(View::render('faculty-panel/message',['message'=>$e->getMessage(),'pageTitle'=>'Faculty access']),$e->httpStatus);
        }
    }
    private function view(string $view,array $data):Response{return Response::html(View::render($view,$data+['success'=>app()->session()->pullFlash('success'),'error'=>app()->session()->pullFlash('error')]));}
    private function operations(Request $request,string $path,FacultyPortalService $service,int $user):Response
    {
        $service->requireCoordinator($user);
        if($request->method()==='POST'){
            if(!app()->session()->validCsrf((string)$request->input('_token')))throw new PortalException('Session expired. Reload before reviewing requests.',403);
            if($path==='/faculty-operations/settings')$service->saveSettings($user,(array)$_POST);
            elseif(preg_match('#^/faculty-operations/(correction|availability|replacement)/(\d+)/(approve|reject)$#',$path,$m))$service->review($user,$m[1],(int)$m[2],$m[3]==='approve',(int)$request->input('replacement_faculty_id')?:null);
            else throw new PortalException('Review action not found.',404);
            app()->session()->flash('success','Faculty operation saved.');return Response::redirect(url('faculty-operations'));
        }
        $corrections=$service->rows('SELECT cr.*,rm.code AS room_code,sa.exam_date,u.name AS faculty_name FROM faculty_correction_requests cr JOIN faculty_room_sessions fs ON fs.id=cr.session_id JOIN seating_allocations sa ON sa.id=fs.allocation_id JOIN rooms rm ON rm.id=fs.room_id JOIN users u ON u.id=cr.requested_by ORDER BY cr.id DESC');
        $availability=$service->rows('SELECT ar.*,f.name AS faculty_name,es.name AS shift_name FROM faculty_availability_requests ar JOIN faculty f ON f.id=ar.faculty_id JOIN exam_shifts es ON es.id=ar.shift_id ORDER BY ar.id DESC');
        $replacements=$service->rows('SELECT rr.*,f.name AS faculty_name,rm.code AS room_code,ia.exam_date FROM replacement_requests rr JOIN invigilation_allocations ia ON ia.id=rr.duty_id JOIN rooms rm ON rm.id=ia.room_id JOIN faculty f ON f.id=ia.faculty_id ORDER BY rr.id DESC');
        return $this->view('faculty-panel/operations',compact('corrections','availability','replacements')+['settings'=>$service->settings(),'facultyOptions'=>$service->rows("SELECT id,name,employee_id FROM faculty WHERE status='active' ORDER BY name")]);
    }
}
