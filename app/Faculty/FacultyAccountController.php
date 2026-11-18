<?php
declare(strict_types=1);
namespace App\Faculty;

use App\Auth\EmailUsernameMigration;
use App\Export\XlsxExporter;
use App\Http\Request;
use App\Http\Response;
use App\Import\FacultyAccountImportService;
use App\View\View;
use PDO;
use RuntimeException;

final class FacultyAccountController
{
    public function __construct(private readonly PDO $pdo) {}

    public function handle(Request $request,string $path): Response
    {
        $session=app()->session();$actor=(int)(app()->auth()->user()['id']??0);
        $service=new FacultyAccountImportService($this->pdo);
        try{$service->assertAdmin($actor);}catch(RuntimeException $e){return Response::html('Only an administrator can manage faculty login imports.',403);}
        if($request->method()==='POST'&&!$session->validCsrf((string)$request->input('_token')))return Response::html('Your session token expired. Reload the page.',403);
        try{
            FacultyPortalMigration::apply($this->pdo);EmailUsernameMigration::apply($this->pdo);
            if($path==='/users/faculty-import/generate'&&$request->method()==='POST'){
                $rows=$service->credentialRows($actor);
                if(!$rows)throw new RuntimeException('There are no active, unlinked faculty with valid email addresses. Import faculty records first, or review existing accounts.');
                $bytes=(new XlsxExporter())->buildRegister('Faculty account credentials',['Faculty Accounts'=>['headers'=>['Name','Email','Username','Password','Role','Status'],'widths'=>[40,44,44,30,14,14],'rows'=>$rows]]);
                return Response::xlsx($bytes,'faculty-login-credentials.xlsx',true);
            }
            if($path==='/users/faculty-import'&&$request->method()==='POST'){
                $file=$_FILES['account_file']??null;
                if(!$file||$file['error']!==UPLOAD_ERR_OK||!is_uploaded_file($file['tmp_name']))throw new RuntimeException('Choose a CSV or XLSX account file.');
                if((int)$file['size']>10*1024*1024||!in_array(strtolower(pathinfo($file['name'],PATHINFO_EXTENSION)),['csv','xlsx'],true))throw new RuntimeException('Upload a CSV or XLSX file smaller than 10 MB.');
                $rows=$service->stage($file['tmp_name'],$file['name'],$actor);
                $session->put('faculty_account_import',['actor'=>$actor,'token'=>bin2hex(random_bytes(24)),'created'=>time(),'rows'=>$rows]);
                return Response::redirect(url('users/faculty-import'));
            }
            if($path==='/users/faculty-import/commit'&&$request->method()==='POST'){
                $pending=$session->get('faculty_account_import');
                if(!$pending||$pending['actor']!==$actor||time()-$pending['created']>1800||!hash_equals($pending['token'],(string)$request->input('import_token')))throw new RuntimeException('This import expired or was already completed. Upload the file again.');
                $count=$service->commit($pending['rows'],$actor);$session->forget('faculty_account_import');
                $session->flash('success',"{$count} faculty login accounts created and linked. Use the passwords from your workbook.");
                return Response::redirect(url('users'));
            }
            if($path==='/users/faculty-import'&&$request->method()==='GET'){
                $pending=$session->get('faculty_account_import');
                if($pending&&($pending['actor']!==$actor||time()-$pending['created']>1800)){$session->forget('faculty_account_import');$pending=null;}
                // Pass only display fields into the view; password hashes stay in the server session.
                $preview=$pending?array_map(static function($row){unset($row['password_hash']);return $row;},$pending['rows']):[];
                return Response::html(View::render('users/faculty-import',['rows'=>$preview,'importToken'=>$pending['token']??'','error'=>$session->pullFlash('error')]));
            }
            return Response::html('Account import page not found.',404);
        }catch(\Throwable $e){
            $message=$e instanceof \PDOException?'The account import could not be saved. Existing accounts were preserved; upload again to review conflicts.':$e->getMessage();
            $session->flash('error',$message);return Response::redirect(url('users/faculty-import'));
        }
    }
}
