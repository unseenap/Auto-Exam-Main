<?php

declare(strict_types=1);

namespace App\Foundation;

use App\Auth\Auth;
use App\Auth\RolePolicy;
use App\Academic\RollNumberParser;
use App\Academic\StudentRepository;
use App\Import\StudentImportService;
use App\Import\FacultyImportService;
use App\Import\DateSheetImportService;
use App\Import\RoomImportService;
use App\Import\CourseImportService;
use App\Rooms\RoomSeatGenerator;
use App\Exams\ExamService;
use App\Seating\SeatingAllocator;
use App\Http\Request;
use App\Http\Response;
use App\View\View;
use PDO;
use Throwable;

final class Application
{
    private static self $instance;
    private array $configuration = [];
    private Database $database;
    private Session $session;
    private Auth $auth;

    public function __construct(private readonly string $basePath)
    {
        self::$instance = $this;
    }

    public static function instance(): self { return self::$instance; }

    public function boot(): void
    {
        $this->configuration['app'] = require $this->basePath . '/config/app.php';
        $this->configuration['database'] = require $this->basePath . '/config/database.php';
        date_default_timezone_set($this->configuration['app']['timezone']);
        $this->database = new Database($this->configuration['database']);
        $this->session = new Session($this->configuration['app']['session_timeout_minutes']);
        $this->session->start();
        $this->auth = new Auth($this->database, $this->session);
    }

    public function config(string $key, mixed $default = null): mixed
    {
        $value = $this->configuration;
        foreach (explode('.', $key) as $segment) {
            if (!is_array($value) || !array_key_exists($segment, $value)) return $default;
            $value = $value[$segment];
        }
        return $value;
    }

    public function database(): Database { return $this->database; }
    public function session(): Session { return $this->session; }
    public function auth(): Auth { return $this->auth; }

    public function handle(Request $request): Response
    {
        try {
            return $this->dispatch($request);
        } catch (Throwable $exception) {
            if ($this->config('app.debug', false)) return Response::html('<pre>' . e((string) $exception) . '</pre>', 500);
            return Response::html(View::render('errors/500'), 500);
        }
    }

    private function dispatch(Request $request): Response
    {
        $method = $request->method();
        $path = rtrim($request->path(), '/') ?: '/';

        if ($path === '/health') {
            return Response::json(['status' => 'ok', 'application' => $this->config('app.name'), 'php' => PHP_VERSION,
                'database' => $this->database->available() ? 'connected' : 'unavailable', 'time' => date(DATE_ATOM)]);
        }
        if ($path === '/login' && $method === 'GET') {
            return $this->auth->check() ? Response::redirect(url('dashboard')) : Response::html(View::render('auth/login'));
        }
        if ($path === '/login' && $method === 'POST') {
            $username=trim((string)$request->input('username'));$this->session->flash('login_username',$username);$blockedUntil=(int)$this->session->get('login_blocked_until',0);
            if($blockedUntil>time()){$this->session->flash('error','Too many unsuccessful attempts. Try again in '.($blockedUntil-time()).' seconds.');}
            elseif (!$this->session->validCsrf((string) $request->input('_token'))) {
                $this->session->flash('error', 'Your session token expired. Please try again.');
            } elseif ($this->auth->attempt($username, (string) $request->input('password'))) {
                $this->session->forget('login_failures');$this->session->forget('login_blocked_until');$this->session->forget('login_username');
                return Response::redirect(url('dashboard'));
            } else {
                $failures=(int)$this->session->get('login_failures',0)+1;$this->session->put('login_failures',$failures);if($failures>=5){$this->session->put('login_blocked_until',time()+60);$this->session->put('login_failures',0);$this->session->flash('error','Too many unsuccessful attempts. Sign-in is paused for 60 seconds.');}else{$this->session->flash('error','The username or password is incorrect. '.(5-$failures).' attempts remain before a short security pause.');}
            }
            return Response::redirect(url('login'));
        }
        if ($path === '/logout' && $method === 'POST') {
            if ($this->session->validCsrf((string) $request->input('_token'))) $this->auth->logout();
            return Response::redirect(url('login'));
        }
        if ($path === '/') return Response::redirect($this->auth->check() ? url('dashboard') : url('login'));
        if (!$this->auth->check()) {
            $this->session->flash('error', 'Please sign in to continue.');
            return Response::redirect(url('login'));
        }
        $required=$this->requiredPermission($path);
        if($required!==null&&!$this->auth->can($required))return Response::html(View::render('errors/403'),403);

        if ($path === '/students' && $method === 'POST') return $this->saveStudent($request);
        if ($path === '/students/import' && $method === 'POST') return $this->stageStudentImport($request);
        if (preg_match('#^/students/import/(\d+)/commit$#', $path, $matches) === 1 && $method === 'POST') {
            return $this->commitStudentImport($request, (int) $matches[1]);
        }
        if (preg_match('#^/students/import/(\d+)$#', $path, $matches) === 1 && $method === 'GET') {
            return Response::html(View::render('students/import-preview', $this->studentImportPreview((int) $matches[1])));
        }
        if (preg_match('#^/students/(\d+)$#', $path, $matches) === 1 && $method === 'POST') {
            return $this->saveStudent($request, (int) $matches[1]);
        }
        if (preg_match('#^/students/(\d+)/edit$#', $path, $matches) === 1 && $method === 'GET') {
            return Response::html(View::render('students/form', $this->studentFormData((int) $matches[1])));
        }
        if ($path === '/faculty' && $method === 'POST') return $this->saveFaculty($request);
        if ($path === '/faculty/import' && $method === 'POST') return $this->stageFacultyImport($request);
        if (preg_match('#^/faculty/import/(\d+)/commit$#', $path, $matches) === 1 && $method === 'POST') return $this->commitFacultyImport($request,(int)$matches[1]);
        if (preg_match('#^/faculty/import/(\d+)$#', $path, $matches) === 1 && $method === 'GET') return Response::html(View::render('faculty/import-preview',$this->facultyImportPreview((int)$matches[1])));
        if (preg_match('#^/faculty/(\d+)$#', $path, $matches) === 1 && $method === 'POST') return $this->saveFaculty($request,(int)$matches[1]);
        if (preg_match('#^/faculty/(\d+)/edit$#', $path, $matches) === 1 && $method === 'GET') return Response::html(View::render('faculty/form',$this->facultyFormData((int)$matches[1])));
        if ($path === '/rooms' && $method === 'POST') return $this->saveRoom($request);
        if ($path === '/rooms/import/template.csv' && $method === 'GET') return $this->roomImportTemplate();
        if ($path === '/rooms/import' && $method === 'POST') return $this->stageRoomImport($request);
        if (preg_match('#^/rooms/import/(\d+)/commit$#', $path, $matches) === 1 && $method === 'POST') return $this->commitRoomImport($request,(int)$matches[1]);
        if (preg_match('#^/rooms/import/(\d+)$#', $path, $matches) === 1 && $method === 'GET') return Response::html(View::render('rooms/import-preview',$this->roomImportPreview((int)$matches[1])));
        if (preg_match('#^/rooms/(\d+)$#', $path, $matches) === 1 && $method === 'POST') return $this->saveRoom($request,(int)$matches[1]);
        if (preg_match('#^/rooms/(\d+)/edit$#', $path, $matches) === 1 && $method === 'GET') return Response::html(View::render('rooms/form',$this->roomFormData((int)$matches[1])));
        if (preg_match('#^/rooms/(\d+)/layout$#', $path, $matches) === 1 && $method === 'GET') return Response::html(View::render('rooms/layout',$this->roomLayoutData((int)$matches[1])));
        if($path==='/exam-cycles'&&$method==='POST')return $this->saveExamCycle($request);
        if($path==='/courses'&&$method==='POST')return $this->saveCourse($request);
        if($path==='/courses/import/template.csv'&&$method==='GET')return $this->courseImportTemplate();
        if($path==='/courses/import'&&$method==='POST')return $this->stageCourseImport($request);
        if(preg_match('#^/courses/import/(\d+)/commit$#',$path,$matches)===1&&$method==='POST')return $this->commitCourseImport($request,(int)$matches[1]);
        if(preg_match('#^/courses/import/(\d+)$#',$path,$matches)===1&&$method==='GET')return Response::html(View::render('exams/course-import-preview',$this->courseImportPreview((int)$matches[1])));
        if(preg_match('#^/date-sheets/(\d+)/papers$#',$path,$matches)===1&&$method==='POST')return $this->schedulePaper($request,(int)$matches[1]);
        if(preg_match('#^/date-sheets/(\d+)/import$#',$path,$matches)===1&&$method==='POST')return $this->stageDateSheetImport($request,(int)$matches[1]);
        if(preg_match('#^/date-sheets/(\d+)/import/(\d+)/commit$#',$path,$matches)===1&&$method==='POST')return $this->commitDateSheetImport($request,(int)$matches[1],(int)$matches[2]);
        if(preg_match('#^/date-sheets/(\d+)/import/(\d+)$#',$path,$matches)===1&&$method==='GET')return Response::html(View::render('exams/import-preview',$this->dateSheetImportPreview((int)$matches[1],(int)$matches[2])));
        if(preg_match('#^/date-sheets/(\d+)/import$#',$path,$matches)===1&&$method==='GET')return Response::html(View::render('exams/import',['cycleId'=>(int)$matches[1],'error'=>$this->session->pullFlash('error')]));
        if(preg_match('#^/date-sheets/(\d+)/schedule$#',$path,$matches)===1&&$method==='GET')return Response::html(View::render('exams/schedule',$this->scheduleData((int)$matches[1])));
        if(preg_match('#^/date-sheets/(\d+)$#',$path,$matches)===1&&$method==='GET')return Response::html(View::render('exams/date-sheet',$this->dateSheetData((int)$matches[1])));
        if($path==='/seating/generate'&&$method==='POST')return $this->generateSeating($request);
        if(preg_match('#^/seating/(\d+)/publish$#',$path,$matches)===1&&$method==='POST')return $this->publishSeating($request,(int)$matches[1]);
        if(preg_match('#^/seating/(\d+)/move$#',$path,$matches)===1&&$method==='POST')return $this->moveSeating($request,(int)$matches[1]);
        if(preg_match('#^/seating/(\d+)/assign-unallocated$#',$path,$matches)===1&&$method==='POST')return $this->assignUnallocated($request,(int)$matches[1]);
        if(preg_match('#^/seating/(\d+)$#',$path,$matches)===1&&$method==='GET')return Response::html(View::render('seating/preview',$this->seatingPreviewData((int)$matches[1])));
        if(preg_match('#^/attendance/(\d+)$#',$path,$matches)===1&&$method==='GET')return Response::html(View::render('attendance/sheet',$this->attendanceSheetData((int)$matches[1])));
        if(preg_match('#^/attendance/(\d+)$#',$path,$matches)===1&&$method==='POST')return $this->saveAttendance($request,(int)$matches[1]);
        if(preg_match('#^/invigilation/allocate/(\d+)$#',$path,$matches)===1&&$method==='POST')return $this->allocateInvigilators($request,(int)$matches[1]);
        if($path==='/replacements'&&$method==='POST')return $this->requestReplacement($request);
        if(preg_match('#^/replacements/(\d+)/(approve|reject)$#',$path,$matches)===1&&$method==='POST')return $this->reviewReplacement($request,(int)$matches[1],$matches[2]);
        if($path==='/reports/students.csv'&&$method==='GET')return $this->studentCsv();
        if($path==='/reports/attendance.csv'&&$method==='GET')return $this->attendanceCsv();
        if($path==='/reports/invigilation.csv'&&$method==='GET')return $this->invigilationCsv();
        if($path==='/reports/unallocated.csv'&&$method==='GET')return $this->unallocatedCsv();
        if($path==='/masters/schools'&&$method==='POST')return $this->saveSchool($request);
        if($path==='/masters/programmes'&&$method==='POST')return $this->saveProgramme($request);
        if($path==='/faculty/availability'&&$method==='POST')return $this->saveFacultyAvailability($request);
        if($path==='/users'&&$method==='POST')return $this->saveUser($request);
        if(preg_match('#^/users/(\d+)$#',$path,$matches)===1&&$method==='POST')return $this->saveUser($request,(int)$matches[1]);

        return match ($path) {
            '/dashboard' => Response::html(View::render('dashboard', $this->dashboardData())),
            '/masters/schools' => Response::html(View::render('masters/schools', $this->schoolData())),
            '/masters/programmes' => Response::html(View::render('masters/programmes', $this->programmeData())),
            '/students' => Response::html(View::render('students/index', $this->studentData($request))),
            '/students/create' => Response::html(View::render('students/form', $this->studentFormData())),
            '/students/import' => Response::html(View::render('students/import')),
            '/faculty' => Response::html(View::render('faculty/index',$this->facultyData($request))),
            '/faculty/create' => Response::html(View::render('faculty/form',$this->facultyFormData())),
            '/faculty/import' => Response::html(View::render('faculty/import')),
            '/rooms' => Response::html(View::render('rooms/index',$this->roomData($request))),
            '/rooms/create' => Response::html(View::render('rooms/form',$this->roomFormData())),
            '/rooms/import' => Response::html(View::render('rooms/import')),
            '/exam-cycles' => Response::html(View::render('exams/cycles',$this->examCycleData())),
            '/exam-cycles/create' => Response::html(View::render('exams/cycle-form')),
            '/courses' => Response::html(View::render('exams/courses',$this->courseData())),
            '/courses/import' => Response::html(View::render('exams/course-import',['error'=>$this->session->pullFlash('error')])),
            '/seating' => Response::html(View::render('seating/index',$this->seatingData())),
            '/seating/generate' => Response::html(View::render('seating/generate',$this->seatingGenerateData($request))),
            '/attendance' => Response::html(View::render('attendance/index',$this->attendanceData())),
            '/invigilation' => Response::html(View::render('invigilation/index',$this->invigilationData())),
            '/replacements' => Response::html(View::render('invigilation/replacements',$this->replacementData())),
            '/reports' => Response::html(View::render('reports/index',$this->reportData())),
            '/audit-logs' => Response::html(View::render('reports/audit',$this->auditData())),
            '/faculty/availability' => Response::html(View::render('faculty/availability',$this->facultyAvailabilityData())),
            '/users' => Response::html(View::render('users/index',$this->userData())),
            default => Response::html(View::render('errors/404'), 404),
        };
    }

    private function requiredPermission(string $path):?string
    {
        if($path==='/dashboard')return 'dashboard.view';
        if(str_starts_with($path,'/users'))return 'users.manage';
        if(str_starts_with($path,'/audit-logs'))return 'audit.view';
        if(str_starts_with($path,'/reports'))return 'reports.view';
        if(str_starts_with($path,'/faculty/availability')||str_starts_with($path,'/invigilation')||str_starts_with($path,'/replacements'))return 'invigilation.manage';
        if(str_starts_with($path,'/attendance'))return 'attendance.manage';
        if(str_starts_with($path,'/seating'))return 'seating.manage';
        if(str_starts_with($path,'/exam-cycles')||str_starts_with($path,'/date-sheets'))return 'exams.manage';
        if(str_starts_with($path,'/rooms'))return 'rooms.manage';
        if(str_starts_with($path,'/faculty'))return 'faculty.manage';
        if(str_starts_with($path,'/students'))return 'students.manage';
        if(str_starts_with($path,'/masters')||str_starts_with($path,'/courses'))return 'academic.manage';
        return null;
    }

    private function dashboardData(): array
    {
        $pdo = $this->database->connection();
        $counts = [];
        foreach (['students', 'faculty', 'rooms', 'exam_cycles'] as $table) $counts[$table] = (int) $pdo->query("SELECT COUNT(*) FROM {$table}")->fetchColumn();
        $programmes = (int) $pdo->query("SELECT COUNT(*) FROM programmes WHERE status='active'")->fetchColumn();
        $schools = (int) $pdo->query("SELECT COUNT(*) FROM schools WHERE status='active'")->fetchColumn();
        $workflow=['usable_seats'=>(int)$pdo->query("SELECT COALESCE(SUM(usable_capacity),0) FROM rooms WHERE status='active'")->fetchColumn(),
            'published_plans'=>(int)$pdo->query("SELECT COUNT(*) FROM seating_allocations WHERE status='published'")->fetchColumn(),
            'unallocated'=>(int)$pdo->query("SELECT COUNT(*) FROM seating_unallocated WHERE resolved_at IS NULL")->fetchColumn(),
            'pending_replacements'=>(int)$pdo->query("SELECT COUNT(*) FROM replacement_requests WHERE status='pending'")->fetchColumn(),
            'attendance_unmarked'=>(int)$pdo->query("SELECT COUNT(*) FROM attendance WHERE status='unmarked'")->fetchColumn(),
            'student_imports'=>(int)$pdo->query("SELECT COUNT(*) FROM import_batches WHERE import_type='students' AND status='committed'")->fetchColumn()];
        $upcoming = $pdo->query("SELECT ec.name, e.exam_date, es.name AS shift_name,es.start_time,es.end_time,c.code AS course_code,c.name AS course_name,
            (SELECT COUNT(*) FROM exam_eligibility ee WHERE ee.examination_id=e.id AND ee.eligibility_status='eligible') AS eligible_count
            FROM examinations e JOIN exam_cycles ec ON ec.id=e.cycle_id JOIN exam_shifts es ON es.id=e.shift_id
            JOIN courses c ON c.id=e.course_id WHERE e.exam_date >= CURDATE() AND e.status <> 'cancelled'
            ORDER BY e.exam_date, es.sequence_no LIMIT 6")->fetchAll(PDO::FETCH_ASSOC);
        return compact('counts','programmes','schools','upcoming','workflow');
    }

    private function schoolData(): array
    {
        $schools = $this->database->connection()->query("SELECT s.*, COUNT(p.id) AS programme_count FROM schools s
            LEFT JOIN programmes p ON p.school_id=s.id GROUP BY s.id ORDER BY s.name")->fetchAll(PDO::FETCH_ASSOC);
        return compact('schools')+['success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function programmeData(): array
    {
        $programmes = $this->database->connection()->query("SELECT p.*, s.short_name AS school_short_name, s.name AS school_name
            FROM programmes p JOIN schools s ON s.id=p.school_id ORDER BY s.name, p.name")->fetchAll(PDO::FETCH_ASSOC);
        $schools=$this->database->connection()->query("SELECT id,code,name FROM schools WHERE status='active' ORDER BY name")->fetchAll(PDO::FETCH_ASSOC);
        return compact('programmes','schools')+['success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function studentData(Request $request): array
    {
        $search = trim((string) $request->input('search', ''));
        $programmeId = (int) $request->input('programme_id', 0) ?: null;
        $page = max(1, (int) $request->input('page', 1));
        $repository = new StudentRepository($this->database->connection());
        $result = $repository->paginate($search, $programmeId, $page);
        $programmes = $this->programmeOptions();
        return compact('result', 'search', 'programmeId', 'programmes');
    }

    private function studentFormData(?int $id = null): array
    {
        $student = $id ? (new StudentRepository($this->database->connection()))->find($id) : null;
        if ($id && !$student) throw new \RuntimeException('Student record not found.');
        return ['student' => $student, 'programmes' => $this->programmeOptions(),
            'old' => $this->session->pullFlash('old', []), 'errors' => $this->session->pullFlash('errors', [])];
    }

    private function saveStudent(Request $request, ?int $id = null): Response
    {
        if (!$this->session->validCsrf((string) $request->input('_token'))) {
            $this->session->flash('error', 'Your session token expired. Please try again.');
            return Response::redirect(url('students'));
        }

        $input = ['roll_no_original' => trim((string) $request->input('roll_no_original')),'enrollment_number'=>trim((string)$request->input('enrollment_number'))?:null,
            'academic_session'=>trim((string)$request->input('academic_session')),'name' => trim((string) $request->input('name')),
            'branch'=>trim((string)$request->input('branch')),'mobile_number'=>trim((string)$request->input('mobile_number')),'address'=>trim((string)$request->input('address')),
            'department_name'=>trim((string)$request->input('department_name')),'school_name'=>trim((string)$request->input('school_name')),'current_year_of_study'=>(int)$request->input('current_year_of_study'), 'semester' => (int) $request->input('semester'),
            'section' => trim((string) $request->input('section')), 'status' => (string) $request->input('status', 'active')];
        $errors = [];
        if ($input['roll_no_original'] === '') $errors['roll_no_original'] = 'Roll number is required.';
        if ($input['name'] === '') $errors['name'] = 'Student name is required.';
        if(!preg_match('/^\d{4}-\d{4}$/',$input['academic_session']))$errors['academic_session']='Use YYYY-YYYY format.';
        elseif((int)substr($input['academic_session'],5)!==(int)substr($input['academic_session'],0,4)+1)$errors['academic_session']='Academic session must cover consecutive years.';
        foreach(['branch'=>'Branch','mobile_number'=>'Mobile number','address'=>'Address','department_name'=>'Department','school_name'=>'School','section'=>'Section'] as $field=>$label)if($input[$field]==='')$errors[$field]="{$label} is required.";
        if($input['current_year_of_study']<1||$input['current_year_of_study']>8)$errors['current_year_of_study']='Year of study must be between 1 and 8.';
        if($input['mobile_number']!==''&&!preg_match('/^[0-9+() -]{7,20}$/',$input['mobile_number']))$errors['mobile_number']='Enter a valid mobile number.';
        if ($input['semester'] < 1 || $input['semester'] > 12) $errors['semester'] = 'Semester must be between 1 and 12.';
        if (!in_array($input['status'], ['active','inactive','completed'], true)) $errors['status'] = 'Select a valid status.';

        $programmeMap = [];
        foreach ($this->programmeOptions() as $programme) $programmeMap[$programme['code']] = $programme;
        $parsed = (new RollNumberParser())->parse($input['roll_no_original'], $programmeMap);
        $manualProgrammeId = (int) $request->input('programme_id', 0) ?: null;
        if ($manualProgrammeId) { $parsed['programme_id'] = $manualProgrammeId; $parsed['parsing_status'] = 'verified'; }
        if ($parsed['parsing_status'] === 'invalid') $errors['roll_no_original'] = $parsed['message'];

        if ($errors) {
            $this->session->flash('errors', $errors); $this->session->flash('old', array_merge($input, ['programme_id' => $manualProgrammeId]));
            return Response::redirect($id ? url("students/{$id}/edit") : url('students/create'));
        }

        $payload = array_merge($input, $parsed, ['batch_id' => null]);
        unset($payload['message']);
        $pdo = $this->database->connection();
        try {
            $pdo->beginTransaction();
            $repository = new StudentRepository($pdo);
            $old = $id ? $repository->find($id) : null;
            $savedId = $repository->save($payload, $id);
            $audit = $pdo->prepare("INSERT INTO audit_logs (user_id,action,entity_type,entity_id,old_values,new_values,ip_address,user_agent)
                VALUES (:user_id,:action,'student',:entity_id,:old_values,:new_values,:ip,:agent)");
            $audit->execute(['user_id' => $this->auth->user()['id'], 'action' => $id ? 'student.updated' : 'student.created',
                'entity_id' => $savedId, 'old_values' => $old ? json_encode($old) : null, 'new_values' => json_encode($payload),
                'ip' => $_SERVER['REMOTE_ADDR'] ?? null, 'agent' => substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 255)]);
            $pdo->commit();
            $this->session->flash('success', $id ? 'Student record updated.' : 'Student record created.');
        } catch (\PDOException $exception) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            $this->session->flash('errors', ['roll_no_original' => str_contains($exception->getMessage(), 'Duplicate')
                ? 'This normalized roll number already exists.' : 'The student could not be saved.']);
            $this->session->flash('old', array_merge($input, ['programme_id' => $manualProgrammeId]));
            return Response::redirect($id ? url("students/{$id}/edit") : url('students/create'));
        }
        return Response::redirect(url('students'));
    }

    private function programmeOptions(): array
    {
        return $this->database->connection()->query("SELECT id,code,name,lateral_entry,legacy FROM programmes
            WHERE status IN ('active','unverified') ORDER BY code")->fetchAll(PDO::FETCH_ASSOC);
    }

    private function stageStudentImport(Request $request): Response
    {
        if (!$this->session->validCsrf((string) $request->input('_token'))) {
            $this->session->flash('error', 'Your session token expired.'); return Response::redirect(url('students/import'));
        }
        $file = $_FILES['student_file'] ?? null;
        if (!$file || $file['error'] !== UPLOAD_ERR_OK) {
            $this->session->flash('error', 'Choose a CSV or XLSX file to upload.'); return Response::redirect(url('students/import'));
        }
        $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        if (!in_array($extension, ['csv','xlsx'], true) || (int) $file['size'] > 10 * 1024 * 1024) {
            $this->session->flash('error', 'Upload a CSV or XLSX file smaller than 10 MB.'); return Response::redirect(url('students/import'));
        }
        $stored = sprintf('%s_%s.%s', date('Ymd_His'), bin2hex(random_bytes(6)), $extension);
        $destination = BASE_PATH . '/storage/imports/' . $stored;
        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            // Shared hosting may disallow persistent PHP writes. The uploaded
            // temporary file remains available for validation during this request.
            $destination = (string) $file['tmp_name'];
        }
        try {
            $batchId = (new StudentImportService($this->database->connection()))->stage($destination, $file['name'], (int) $this->auth->user()['id']);
            return Response::redirect(url("students/import/{$batchId}"));
        } catch (\Throwable $exception) {
            $this->session->flash('error', $exception->getMessage()); return Response::redirect(url('students/import'));
        }
    }

    private function studentImportPreview(int $id): array
    {
        $pdo = $this->database->connection();
        $statement = $pdo->prepare("SELECT * FROM import_batches WHERE id=:id AND import_type='students'");
        $statement->execute(['id' => $id]); $batch = $statement->fetch(PDO::FETCH_ASSOC);
        if (!$batch) throw new \RuntimeException('Import batch not found.');
        $rows = $pdo->prepare('SELECT *, source_row_number AS row_number FROM import_rows WHERE import_batch_id=:id ORDER BY source_row_number');
        $rows->execute(['id' => $id]);
        return ['batch' => $batch, 'rows' => $rows->fetchAll(PDO::FETCH_ASSOC)];
    }

    private function commitStudentImport(Request $request, int $id): Response
    {
        if (!$this->session->validCsrf((string) $request->input('_token'))) return Response::redirect(url("students/import/{$id}"));
        $pdo = $this->database->connection();
        try {
            $pdo->beginTransaction();
            $result = (new StudentImportService($pdo))->commit($id, (int) $this->auth->user()['id']);
            $pdo->commit();
            $this->session->flash('success', $result['created'] . ' student records imported.');
            return Response::redirect(url('students'));
        } catch (\Throwable $exception) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            $this->session->flash('error', $exception->getMessage()); return Response::redirect(url("students/import/{$id}"));
        }
    }

    private function facultyData(Request $request): array
    {
        $search=trim((string)$request->input('search',''));$params=[];$where='1=1';
        if($search!==''){$where='(f.name LIKE :search OR f.employee_id LIKE :search)';$params['search']='%'.$search.'%';}
        $statement=$this->database->connection()->prepare("SELECT f.*,s.short_name AS school_name,d.name AS department_name FROM faculty f
            JOIN schools s ON s.id=f.school_id LEFT JOIN departments d ON d.id=f.department_id WHERE {$where} ORDER BY f.name");
        $statement->execute($params);return ['faculty'=>$statement->fetchAll(PDO::FETCH_ASSOC),'search'=>$search];
    }

    private function stageFacultyImport(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token'))){$this->session->flash('error','Your session token expired.');return Response::redirect(url('faculty/import'));}
        $file=$_FILES['faculty_file']??null;
        if(!$file||$file['error']!==UPLOAD_ERR_OK){$this->session->flash('error','Choose a CSV or XLSX file to upload.');return Response::redirect(url('faculty/import'));}
        $extension=strtolower(pathinfo($file['name'],PATHINFO_EXTENSION));
        if(!in_array($extension,['csv','xlsx'],true)||(int)$file['size']>10*1024*1024){$this->session->flash('error','Upload a CSV or XLSX file smaller than 10 MB.');return Response::redirect(url('faculty/import'));}
        $stored=sprintf('faculty_%s_%s.%s',date('Ymd_His'),bin2hex(random_bytes(6)),$extension);$destination=BASE_PATH.'/storage/imports/'.$stored;
        if(!move_uploaded_file($file['tmp_name'],$destination)){$destination=(string)$file['tmp_name'];}
        try{$id=(new FacultyImportService($this->database->connection()))->stage($destination,$file['name'],(int)$this->auth->user()['id']);return Response::redirect(url("faculty/import/{$id}"));}
        catch(\Throwable $e){$this->session->flash('error',$e->getMessage());return Response::redirect(url('faculty/import'));}
    }

    private function facultyImportPreview(int $id): array
    {
        $pdo=$this->database->connection();$q=$pdo->prepare("SELECT * FROM import_batches WHERE id=:id AND import_type='faculty'");$q->execute(['id'=>$id]);$batch=$q->fetch(PDO::FETCH_ASSOC);if(!$batch)throw new \RuntimeException('Faculty import batch not found.');$q=$pdo->prepare('SELECT *, source_row_number AS row_number FROM import_rows WHERE import_batch_id=:id ORDER BY source_row_number');$q->execute(['id'=>$id]);return ['batch'=>$batch,'rows'=>$q->fetchAll(PDO::FETCH_ASSOC)];
    }

    private function commitFacultyImport(Request $request,int $id): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url("faculty/import/{$id}"));$pdo=$this->database->connection();
        try{$pdo->beginTransaction();$count=(new FacultyImportService($pdo))->commit($id,(int)$this->auth->user()['id']);$pdo->commit();$this->session->flash('success',"{$count} faculty records imported.");return Response::redirect(url('faculty'));}
        catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('error',$e->getMessage());return Response::redirect(url("faculty/import/{$id}"));}
    }

    private function facultyFormData(?int $id=null): array
    {
        $faculty=null;if($id){$q=$this->database->connection()->prepare('SELECT * FROM faculty WHERE id=:id');$q->execute(['id'=>$id]);$faculty=$q->fetch(PDO::FETCH_ASSOC);}
        return ['faculty'=>$faculty,'schools'=>$this->database->connection()->query("SELECT id,code,name FROM schools WHERE status='active' ORDER BY name")->fetchAll(PDO::FETCH_ASSOC),
            'errors'=>$this->session->pullFlash('errors',[]),'old'=>$this->session->pullFlash('old',[])];
    }

    private function saveFaculty(Request $request,?int $id=null): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('faculty'));
        $data=['school_id'=>(int)$request->input('school_id'),'department_id'=>null,'employee_id'=>trim((string)$request->input('employee_id')),
            'name'=>trim((string)$request->input('name')),'designation'=>trim((string)$request->input('designation')),
            'email'=>trim((string)$request->input('email'))?:null,'phone'=>trim((string)$request->input('phone'))?:null,
            'status'=>(string)$request->input('status','active')];$errors=[];
        if(!$data['school_id'])$errors['school_id']='School is required.';if($data['employee_id']==='')$errors['employee_id']='Employee ID is required.';if($data['name']==='')$errors['name']='Name is required.';
        if($errors){$this->session->flash('errors',$errors);$this->session->flash('old',$data);return Response::redirect($id?url("faculty/{$id}/edit"):url('faculty/create'));}
        $pdo=$this->database->connection();try{$pdo->beginTransaction();
            if($id){$sql='UPDATE faculty SET school_id=:school_id,department_id=:department_id,employee_id=:employee_id,name=:name,designation=:designation,email=:email,phone=:phone,status=:status WHERE id=:id';$data['id']=$id;}
            else{$sql='INSERT INTO faculty(school_id,department_id,employee_id,name,designation,email,phone,status) VALUES(:school_id,:department_id,:employee_id,:name,:designation,:email,:phone,:status)';}
            $pdo->prepare($sql)->execute($data);$entity=$id?:((int)$pdo->lastInsertId());$this->audit($pdo,$id?'faculty.updated':'faculty.created','faculty',$entity,$data);$pdo->commit();
            $this->session->flash('success',$id?'Faculty record updated.':'Faculty record created.');return Response::redirect(url('faculty'));
        }catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('errors',['employee_id'=>'Employee ID must be unique.']);$this->session->flash('old',$data);return Response::redirect($id?url("faculty/{$id}/edit"):url('faculty/create'));}
    }

    private function roomData(Request $request): array
    {
        return ['rooms'=>$this->database->connection()->query("SELECT r.*,SUM(CASE WHEN rs.is_blocked=1 THEN 1 ELSE 0 END) AS blocked_seats
            FROM rooms r LEFT JOIN room_seats rs ON rs.room_id=r.id GROUP BY r.id ORDER BY r.priority,r.code")->fetchAll(PDO::FETCH_ASSOC)];
    }

    private function roomFormData(?int $id=null): array
    {
        $room=null;$blocked='';if($id){$q=$this->database->connection()->prepare('SELECT * FROM rooms WHERE id=:id');$q->execute(['id'=>$id]);$room=$q->fetch(PDO::FETCH_ASSOC);
            $q=$this->database->connection()->prepare("SELECT CONCAT(row_no,'-',column_no) FROM room_seats WHERE room_id=:id AND is_blocked=1");$q->execute(['id'=>$id]);$blocked=implode(',',$q->fetchAll(PDO::FETCH_COLUMN));}
        return ['room'=>$room,'blocked'=>$blocked,'errors'=>$this->session->pullFlash('errors',[]),'old'=>$this->session->pullFlash('old',[])];
    }

    private function stageRoomImport(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token'))){$this->session->flash('error','Your session token expired.');return Response::redirect(url('rooms/import'));}
        $file=$_FILES['room_file']??null;
        if(!$file||$file['error']!==UPLOAD_ERR_OK){$this->session->flash('error','Choose a CSV or XLSX file to upload.');return Response::redirect(url('rooms/import'));}
        $extension=strtolower(pathinfo($file['name'],PATHINFO_EXTENSION));
        if(!in_array($extension,['csv','xlsx'],true)||(int)$file['size']>10*1024*1024){$this->session->flash('error','Upload a CSV or XLSX file smaller than 10 MB.');return Response::redirect(url('rooms/import'));}
        $stored=sprintf('rooms_%s_%s.%s',date('Ymd_His'),bin2hex(random_bytes(6)),$extension);$destination=BASE_PATH.'/storage/imports/'.$stored;
        if(!move_uploaded_file($file['tmp_name'],$destination)){$destination=(string)$file['tmp_name'];}
        try{$id=(new RoomImportService($this->database->connection()))->stage($destination,$file['name'],(int)$this->auth->user()['id']);return Response::redirect(url("rooms/import/{$id}"));}
        catch(\Throwable $e){$this->session->flash('error',$e->getMessage());return Response::redirect(url('rooms/import'));}
    }

    private function roomImportTemplate(): Response
    {
        $rows=[
            ['Room Code','Building','Floor','Rows','Columns','Seat Order','Disabled Seat Numbers','Priority','Status','Notes'],
            ['ICT-101','ICT Block','First Floor','6','8','column_major','R02-C04 | R03-C04','10','active','Standard examination room'],
            ['SOE-201','Engineering Block','Second Floor','5','10','row_major','R01-C01 | R05-C10','20','active','Corner seats disabled'],
        ];
        $content=implode("\r\n",array_map(static fn(array $row):string=>implode(',',array_map(static function(string $value):string{return strpbrk($value,",\"\r\n")!==false?'"'.str_replace('"','""',$value).'"':$value;},$row)),$rows))."\r\n";
        return Response::csv($content,'gbu-room-import-template.csv');
    }

    private function roomImportPreview(int $id): array
    {
        $pdo=$this->database->connection();$q=$pdo->prepare("SELECT * FROM import_batches WHERE id=:id AND import_type='rooms'");$q->execute(['id'=>$id]);$batch=$q->fetch(PDO::FETCH_ASSOC);if(!$batch)throw new \RuntimeException('Room import batch not found.');
        $q=$pdo->prepare('SELECT *, source_row_number AS row_number FROM import_rows WHERE import_batch_id=:id ORDER BY source_row_number');$q->execute(['id'=>$id]);return ['batch'=>$batch,'rows'=>$q->fetchAll(PDO::FETCH_ASSOC)];
    }

    private function commitRoomImport(Request $request,int $id): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url("rooms/import/{$id}"));$pdo=$this->database->connection();
        try{$pdo->beginTransaction();$count=(new RoomImportService($pdo))->commit($id,(int)$this->auth->user()['id']);$pdo->commit();$this->session->flash('success',"{$count} room layouts imported.");return Response::redirect(url('rooms'));}
        catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('error',$e->getMessage());return Response::redirect(url("rooms/import/{$id}"));}
    }

    private function saveRoom(Request $request,?int $id=null): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('rooms'));
        $data=['code'=>trim((string)$request->input('code')),'building'=>trim((string)$request->input('building')),'floor'=>trim((string)$request->input('floor'))?:null,
            'rows_count'=>(int)$request->input('rows_count'),'columns_count'=>(int)$request->input('columns_count'),'physical_capacity'=>1,'usable_capacity'=>1,
            'seat_order'=>(string)$request->input('seat_order','column_major'),'priority'=>(int)$request->input('priority',100),'status'=>(string)$request->input('status','active'),'notes'=>trim((string)$request->input('notes'))?:null];
        $errors=[];if($data['code']==='')$errors['code']='Room code is required.';if($data['building']==='')$errors['building']='Building is required.';if($data['rows_count']<1||$data['rows_count']>100)$errors['rows_count']='Rows must be between 1 and 100.';if($data['columns_count']<1||$data['columns_count']>100)$errors['columns_count']='Columns must be between 1 and 100.';
        if($errors){$this->session->flash('errors',$errors);$this->session->flash('old',array_merge($data,['blocked'=>$request->input('blocked')]));return Response::redirect($id?url("rooms/{$id}/edit"):url('rooms/create'));}
        $blocked=array_values(array_filter(array_map('trim',explode(',',(string)$request->input('blocked','')))));$pdo=$this->database->connection();try{$pdo->beginTransaction();
            if($id){$sets=implode(',',array_map(fn($k)=>"{$k}=:{$k}",array_keys($data)));$data['id']=$id;$pdo->prepare("UPDATE rooms SET {$sets} WHERE id=:id")->execute($data);$roomId=$id;}
            else{$keys=array_keys($data);$pdo->prepare('INSERT INTO rooms('.implode(',',$keys).') VALUES('.implode(',',array_map(fn($k)=>":{$k}",$keys)).')')->execute($data);$roomId=(int)$pdo->lastInsertId();}
            (new RoomSeatGenerator($pdo))->regenerate($roomId,$data['rows_count'],$data['columns_count'],$data['seat_order'],$blocked);$this->audit($pdo,$id?'room.updated':'room.created','room',$roomId,$data);$pdo->commit();$this->session->flash('success',$id?'Room layout updated.':'Room and seat map created.');return Response::redirect(url('rooms'));
        }catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('errors',['code'=>'Room code must be unique and blocked coordinates must be valid.']);$this->session->flash('old',$data);return Response::redirect($id?url("rooms/{$id}/edit"):url('rooms/create'));}
    }

    private function roomLayoutData(int $id): array
    {
        $q=$this->database->connection()->prepare('SELECT * FROM rooms WHERE id=:id');$q->execute(['id'=>$id]);$room=$q->fetch(PDO::FETCH_ASSOC);if(!$room)throw new \RuntimeException('Room not found.');
        $q=$this->database->connection()->prepare('SELECT * FROM room_seats WHERE room_id=:id ORDER BY row_no,column_no');$q->execute(['id'=>$id]);return ['room'=>$room,'seats'=>$q->fetchAll(PDO::FETCH_ASSOC)];
    }

    private function audit(PDO $pdo,string $action,string $entityType,int $entityId,array $newValues): void
    {
        $pdo->prepare('INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values,ip_address,user_agent) VALUES(:user,:action,:type,:id,:values,:ip,:agent)')
            ->execute(['user'=>$this->auth->user()['id'],'action'=>$action,'type'=>$entityType,'id'=>$entityId,'values'=>json_encode($newValues),'ip'=>$_SERVER['REMOTE_ADDR']??null,'agent'=>substr($_SERVER['HTTP_USER_AGENT']??'',0,255)]);
    }

    private function examCycleData(): array
    {
        return ['cycles'=>$this->database->connection()->query("SELECT ec.*,
            (SELECT COUNT(*) FROM examinations e WHERE e.cycle_id=ec.id AND e.status<>'cancelled') AS paper_count,
            (SELECT COUNT(*) FROM exam_shifts es WHERE es.cycle_id=ec.id) AS shift_count,
            (SELECT COUNT(*) FROM seating_allocations sa WHERE sa.cycle_id=ec.id) AS allocation_count,
            (SELECT COUNT(*) FROM exam_eligibility ee JOIN examinations e2 ON e2.id=ee.examination_id WHERE e2.cycle_id=ec.id AND ee.eligibility_status='eligible') AS eligible_count
            FROM exam_cycles ec ORDER BY ec.start_date DESC")->fetchAll(PDO::FETCH_ASSOC),
            'success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function saveExamCycle(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('exam-cycles'));
        $type=(string)$request->input('exam_type');$duration=(int)$request->input('duration',str_contains($type,'mid')?90:180);
        $data=['name'=>trim((string)$request->input('name')),'academic_year'=>trim((string)$request->input('academic_year')),'exam_type'=>$type,
            'start_date'=>(string)$request->input('start_date'),'end_date'=>(string)$request->input('end_date'),'duration'=>$duration,
            'shifts'=>[['name'=>(string)$request->input('shift1_name','1st Shift'),'start'=>(string)$request->input('shift1_start'),'end'=>(string)$request->input('shift1_end'),'duration'=>$duration],
                ['name'=>(string)$request->input('shift2_name','2nd Shift'),'start'=>(string)$request->input('shift2_start'),'end'=>(string)$request->input('shift2_end'),'duration'=>$duration]]];
        $invalid=$data['name']===''||$data['academic_year']===''||$data['start_date']===''||$data['end_date']===''||$data['start_date']>$data['end_date']||$duration<30||$duration>300;
        foreach($data['shifts'] as $shift)if(trim($shift['name'])===''||$shift['start']===''||$shift['end']===''||$shift['start']>=$shift['end'])$invalid=true;
        if($invalid){$this->session->flash('error','Review the cycle details, date range, duration, and shift times.');$this->session->flash('cycle_old',$_POST);return Response::redirect(url('exam-cycles/create'));}
        try{$id=(new ExamService($this->database->connection()))->createCycle($data,(int)$this->auth->user()['id']);$this->session->flash('success','Examination cycle created with calendar and shifts.');return Response::redirect(url("date-sheets/{$id}"));}
        catch(\Throwable $e){$this->session->flash('error',$e->getMessage());return Response::redirect(url('exam-cycles/create'));}
    }

    private function courseData(): array
    {
        $pdo=$this->database->connection();return ['courses'=>$pdo->query("SELECT c.*,pc.semester,pc.category,p.id AS programme_id,p.code AS programme_code,p.name AS programme_name,d.name AS department_name,s.short_name AS school_name FROM programme_courses pc JOIN courses c ON c.id=pc.course_id JOIN programmes p ON p.id=pc.programme_id LEFT JOIN departments d ON d.id=p.department_id JOIN schools s ON s.id=p.school_id ORDER BY p.code,pc.semester,c.code")->fetchAll(PDO::FETCH_ASSOC),'programmes'=>$this->programmeOptions(),'success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function saveCourse(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('courses'));
        $code=strtoupper(trim((string)$request->input('code')));$name=trim((string)$request->input('name'));$programmeId=(int)$request->input('programme_id');$semester=(int)$request->input('semester');$category=(string)$request->input('category','core');
        if($code===''||$name===''||$programmeId<1||$semester<1||$semester>12){$this->session->flash('error','Course code, name, programme, and a valid semester are required.');return Response::redirect(url('courses'));}
        $pdo=$this->database->connection();try{$pdo->beginTransaction();$q=$pdo->prepare('SELECT id FROM courses WHERE code=:code');$q->execute(['code'=>$code]);$courseId=(int)$q->fetchColumn();if(!$courseId){$pdo->prepare("INSERT INTO courses(code,name,status) VALUES(:code,:name,'active')")->execute(['code'=>$code,'name'=>$name]);$courseId=(int)$pdo->lastInsertId();}else{$pdo->prepare('UPDATE courses SET name=:name WHERE id=:id')->execute(['name'=>$name,'id'=>$courseId]);}$pdo->prepare('INSERT INTO programme_courses(programme_id,course_id,semester,category) VALUES(:programme,:course,:semester,:category) ON DUPLICATE KEY UPDATE category=VALUES(category)')->execute(['programme'=>$programmeId,'course'=>$courseId,'semester'=>$semester,'category'=>$category]);$pdo->commit();$this->session->flash('success','Subject added to the programme curriculum.');}
        catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('error',$e->getMessage());}return Response::redirect(url('courses'));
    }

    private function courseImportTemplate(): Response {return Response::csv("Course Code,Course Name,Programme Code,Semester,Category,Status\r\nCS-101,Programming Fundamentals,UCS,1,core,active\r\nCS-102,Discrete Mathematics,UCS,1,core,active\r\n",'gbu-course-curriculum-template.csv');}
    private function stageCourseImport(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('courses/import'));
        $file=$_FILES['course_file']??null;
        if(!$file||$file['error']!==UPLOAD_ERR_OK){$this->session->flash('error','Choose a CSV or XLSX file.');return Response::redirect(url('courses/import'));}
        $ext=strtolower(pathinfo($file['name'],PATHINFO_EXTENSION));
        if(!in_array($ext,['csv','xlsx'],true)||(int)$file['size']>10*1024*1024){$this->session->flash('error','Upload a CSV or XLSX file smaller than 10 MB.');return Response::redirect(url('courses/import'));}
        $stored=sprintf('courses_%s_%s.%s',date('Ymd_His'),bin2hex(random_bytes(6)),$ext);
        $destination=BASE_PATH.'/storage/imports/'.$stored;
        if(!move_uploaded_file($file['tmp_name'],$destination))$destination=(string)$file['tmp_name'];
        try{$id=(new CourseImportService($this->database->connection()))->stage($destination,$file['name'],(int)$this->auth->user()['id']);return Response::redirect(url("courses/import/{$id}"));}
        catch(\Throwable $e){$this->session->flash('error',$e->getMessage());return Response::redirect(url('courses/import'));}
    }
    private function courseImportPreview(int $id):array{$pdo=$this->database->connection();$q=$pdo->prepare("SELECT * FROM import_batches WHERE id=:id AND import_type='courses'");$q->execute(['id'=>$id]);$batch=$q->fetch(PDO::FETCH_ASSOC);if(!$batch)throw new \RuntimeException('Course import not found.');$q=$pdo->prepare('SELECT *, source_row_number AS row_number FROM import_rows WHERE import_batch_id=:id ORDER BY source_row_number');$q->execute(['id'=>$id]);return compact('batch')+['rows'=>$q->fetchAll(PDO::FETCH_ASSOC),'error'=>$this->session->pullFlash('error')];}
    private function commitCourseImport(Request $request,int $id):Response{if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url("courses/import/{$id}"));$pdo=$this->database->connection();try{$pdo->beginTransaction();$count=(new CourseImportService($pdo))->commit($id,(int)$this->auth->user()['id']);$pdo->commit();$this->session->flash('success',"{$count} programme-subject rows imported.");return Response::redirect(url('courses'));}catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('error',$e->getMessage());return Response::redirect(url("courses/import/{$id}"));}}

    private function dateSheetData(int $cycleId): array
    {
        $pdo=$this->database->connection();$q=$pdo->prepare('SELECT * FROM exam_cycles WHERE id=:id');$q->execute(['id'=>$cycleId]);$cycle=$q->fetch(PDO::FETCH_ASSOC);if(!$cycle)throw new \RuntimeException('Exam cycle not found.');
        $q=$pdo->prepare('SELECT * FROM exam_calendar_dates WHERE cycle_id=:id AND is_exam_day=1 ORDER BY exam_date');$q->execute(['id'=>$cycleId]);$dates=$q->fetchAll(PDO::FETCH_ASSOC);
        $q=$pdo->prepare("SELECT e.id,e.exam_date,es.name AS shift_name,es.start_time,es.end_time,c.code AS course_code,c.name AS course_name,
            p.id AS programme_id,p.name AS programme_name,p.code AS programme_code,ec.semester,ec.display_label,(SELECT COUNT(*) FROM exam_eligibility ee WHERE ee.examination_id=e.id AND ee.eligibility_status='eligible') AS eligible_count
            FROM examinations e JOIN exam_shifts es ON es.id=e.shift_id JOIN courses c ON c.id=e.course_id JOIN examination_cohorts ec ON ec.examination_id=e.id JOIN programmes p ON p.id=ec.programme_id
            WHERE e.cycle_id=:id AND e.status<>'cancelled' ORDER BY p.name,ec.semester,es.sequence_no,e.exam_date");$q->execute(['id'=>$cycleId]);$papers=$q->fetchAll(PDO::FETCH_ASSOC);
        $matrix=[];foreach($papers as $paper){$key=$paper['programme_id'].'-'.$paper['semester'].'-'.$paper['shift_name'];$matrix[$key]['label']=$paper['display_label']?:$paper['programme_name'].' Semester '.$paper['semester'];$matrix[$key]['shift']=$paper['shift_name'];$matrix[$key]['time']=substr($paper['start_time'],0,5).' - '.substr($paper['end_time'],0,5);$matrix[$key]['cells'][$paper['exam_date']][]=$paper;}
        return compact('cycle','dates','papers','matrix')+['success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function scheduleData(int $cycleId): array
    {
        $pdo=$this->database->connection();$q=$pdo->prepare('SELECT * FROM exam_cycles WHERE id=:id');$q->execute(['id'=>$cycleId]);$cycle=$q->fetch(PDO::FETCH_ASSOC);if(!$cycle)throw new \RuntimeException('Cycle not found.');
        $q=$pdo->prepare('SELECT * FROM exam_shifts WHERE cycle_id=:id ORDER BY sequence_no');$q->execute(['id'=>$cycleId]);$shifts=$q->fetchAll(PDO::FETCH_ASSOC);$q=$pdo->prepare('SELECT exam_date FROM exam_calendar_dates WHERE cycle_id=:id AND is_exam_day=1 ORDER BY exam_date');$q->execute(['id'=>$cycleId]);
        return ['cycle'=>$cycle,'shifts'=>$shifts,'dates'=>$q->fetchAll(PDO::FETCH_COLUMN),'courses'=>$pdo->query("SELECT c.id,c.code,c.name,pc.programme_id,pc.semester FROM programme_courses pc JOIN courses c ON c.id=pc.course_id WHERE c.status='active' ORDER BY pc.programme_id,pc.semester,c.code")->fetchAll(PDO::FETCH_ASSOC),'programmes'=>$this->programmeOptions(),'error'=>$this->session->pullFlash('error')];
    }

    private function schedulePaper(Request $request,int $cycleId): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url("date-sheets/{$cycleId}"));
        $data=['cycle_id'=>$cycleId,'shift_id'=>(int)$request->input('shift_id'),'course_id'=>(int)$request->input('course_id'),'exam_date'=>(string)$request->input('exam_date'),
            'category'=>(string)$request->input('category','regular'),'programme_id'=>(int)$request->input('programme_id'),'semester'=>(int)$request->input('semester'),'display_label'=>trim((string)$request->input('display_label'))?:null];
        try{(new ExamService($this->database->connection()))->schedule($data);$this->session->flash('success','Paper scheduled and eligible students calculated.');return Response::redirect(url("date-sheets/{$cycleId}"));}
        catch(\Throwable $e){$this->session->flash('error',$e->getMessage());return Response::redirect(url("date-sheets/{$cycleId}/schedule"));}
    }

    private function stageDateSheetImport(Request $request,int $cycleId): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url("date-sheets/{$cycleId}/import"));
        $file=$_FILES['date_sheet_file']??null;
        if(!$file||$file['error']!==UPLOAD_ERR_OK){$this->session->flash('error','Choose a CSV or XLSX file.');return Response::redirect(url("date-sheets/{$cycleId}/import"));}
        $ext=strtolower(pathinfo($file['name'],PATHINFO_EXTENSION));
        if(!in_array($ext,['csv','xlsx'],true)||(int)$file['size']>10*1024*1024){$this->session->flash('error','Upload a CSV or XLSX file smaller than 10 MB.');return Response::redirect(url("date-sheets/{$cycleId}/import"));}
        $stored=sprintf('datesheet_%s_%s.%s',date('Ymd_His'),bin2hex(random_bytes(6)),$ext);
        $destination=BASE_PATH.'/storage/imports/'.$stored;
        if(!move_uploaded_file($file['tmp_name'],$destination))$destination=(string)$file['tmp_name'];
        try{$id=(new DateSheetImportService($this->database->connection()))->stage($cycleId,$destination,$file['name'],(int)$this->auth->user()['id']);return Response::redirect(url("date-sheets/{$cycleId}/import/{$id}"));}
        catch(\Throwable $e){$this->session->flash('error',$e->getMessage());return Response::redirect(url("date-sheets/{$cycleId}/import"));}
    }
    private function dateSheetImportPreview(int $cycleId,int $id): array {$pdo=$this->database->connection();$q=$pdo->prepare("SELECT * FROM import_batches WHERE id=:id AND import_type='date_sheet'");$q->execute(['id'=>$id]);$batch=$q->fetch(PDO::FETCH_ASSOC);if(!$batch)throw new \RuntimeException('Import not found.');$q=$pdo->prepare('SELECT *, source_row_number AS row_number FROM import_rows WHERE import_batch_id=:id ORDER BY source_row_number');$q->execute(['id'=>$id]);return compact('cycleId','batch')+['rows'=>$q->fetchAll(PDO::FETCH_ASSOC),'error'=>$this->session->pullFlash('error')];}
    private function commitDateSheetImport(Request $request,int $cycleId,int $id): Response {if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url("date-sheets/{$cycleId}/import/{$id}"));$pdo=$this->database->connection();try{$pdo->beginTransaction();$count=(new DateSheetImportService($pdo))->commit($id,(int)$this->auth->user()['id']);$pdo->commit();$this->session->flash('success',"{$count} papers imported.");return Response::redirect(url("date-sheets/{$cycleId}"));}catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('error',$e->getMessage());return Response::redirect(url("date-sheets/{$cycleId}/import/{$id}"));}}

    private function seatingData(): array
    {
        return ['allocations'=>$this->database->connection()->query("SELECT sa.*,ec.name AS cycle_name,es.name AS shift_name,
            (SELECT COUNT(*) FROM seating_assignments x WHERE x.allocation_id=sa.id) AS assigned_count,
            (SELECT COUNT(DISTINCT x.room_id) FROM seating_assignments x WHERE x.allocation_id=sa.id) AS room_count,
            (SELECT COUNT(*) FROM seating_unallocated su WHERE su.allocation_id=sa.id AND su.resolved_at IS NULL) AS unallocated_count
            FROM seating_allocations sa JOIN exam_cycles ec ON ec.id=sa.cycle_id JOIN exam_shifts es ON es.id=sa.shift_id
            ORDER BY sa.generated_at DESC LIMIT 100")->fetchAll(PDO::FETCH_ASSOC),'success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function seatingGenerateData(Request $request): array
    {
        $pdo=$this->database->connection();$cycleId=(int)$request->input('cycle_id',0);
        $cycles=$pdo->query("SELECT id,name FROM exam_cycles WHERE status IN ('draft','published') ORDER BY start_date DESC")->fetchAll(PDO::FETCH_ASSOC);
        $sessions=[];if($cycleId){$q=$pdo->prepare("SELECT DISTINCT e.exam_date,es.id AS shift_id,es.name AS shift_name,es.start_time,es.end_time,
            (SELECT COUNT(DISTINCT ee.student_id) FROM examinations e2 JOIN exam_eligibility ee ON ee.examination_id=e2.id AND ee.eligibility_status='eligible' WHERE e2.cycle_id=e.cycle_id AND e2.exam_date=e.exam_date AND e2.shift_id=e.shift_id) AS eligible_count
            FROM examinations e JOIN exam_shifts es ON es.id=e.shift_id WHERE e.cycle_id=:cycle ORDER BY e.exam_date,es.sequence_no");$q->execute(['cycle'=>$cycleId]);$sessions=$q->fetchAll(PDO::FETCH_ASSOC);}
        return ['cycles'=>$cycles,'sessions'=>$sessions,'rooms'=>$pdo->query("SELECT id,code,building,usable_capacity FROM rooms WHERE status='active' ORDER BY priority,code")->fetchAll(PDO::FETCH_ASSOC),'cycleId'=>$cycleId,'error'=>$this->session->pullFlash('error')];
    }

    private function generateSeating(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('seating'));
        $roomIds=array_map('intval',(array)($_POST['room_ids']??[]));$cycleId=(int)$request->input('cycle_id');$date=(string)$request->input('exam_date');$shiftId=(int)$request->input('shift_id');
        try{$result=(new SeatingAllocator($this->database->connection()))->generate($cycleId,$date,$shiftId,$roomIds,(int)$this->auth->user()['id'],hash('sha256',$cycleId.$date.$shiftId.implode(',',$roomIds)));
            $this->session->flash('success',"{$result['assigned']} students assigned. {$result['unallocated']} unallocated.");return Response::redirect(url('seating/'.$result['allocation_id']));}
        catch(\Throwable $e){$this->session->flash('error',$e->getMessage());return Response::redirect(url('seating/generate?cycle_id='.$cycleId));}
    }

    private function seatingPreviewData(int $id): array
    {
        $pdo=$this->database->connection();$q=$pdo->prepare("SELECT sa.*,ec.name AS cycle_name,es.name AS shift_name,es.start_time,es.end_time FROM seating_allocations sa JOIN exam_cycles ec ON ec.id=sa.cycle_id JOIN exam_shifts es ON es.id=sa.shift_id WHERE sa.id=:id");$q->execute(['id'=>$id]);$allocation=$q->fetch(PDO::FETCH_ASSOC);if(!$allocation)throw new \RuntimeException('Allocation not found.');
        $q=$pdo->prepare("SELECT a.*,r.code AS room_code,r.building,rs.seat_label,rs.row_no,rs.column_no,rs.desk_group,s.roll_no_original,s.name AS student_name,p.code AS programme_code,c.code AS course_code,c.name AS course_name
            FROM seating_assignments a JOIN rooms r ON r.id=a.room_id JOIN room_seats rs ON rs.id=a.seat_id JOIN students s ON s.id=a.student_id JOIN programmes p ON p.id=s.programme_id JOIN examinations e ON e.id=a.examination_id JOIN courses c ON c.id=e.course_id WHERE a.allocation_id=:id ORDER BY r.priority,r.code,rs.row_no,rs.column_no");$q->execute(['id'=>$id]);$assignments=$q->fetchAll(PDO::FETCH_ASSOC);$byRoom=[];foreach($assignments as $item)$byRoom[$item['room_code']][]=$item;
        $q=$pdo->prepare("SELECT su.*,s.roll_no_original,s.name,p.code AS programme_code,c.code AS course_code FROM seating_unallocated su JOIN students s ON s.id=su.student_id JOIN programmes p ON p.id=s.programme_id JOIN examinations e ON e.id=su.examination_id JOIN courses c ON c.id=e.course_id WHERE su.allocation_id=:id AND su.resolved_at IS NULL ORDER BY s.normalized_roll_no");$q->execute(['id'=>$id]);$unallocated=$q->fetchAll(PDO::FETCH_ASSOC);
        $q=$pdo->prepare("SELECT rs.id,r.code AS room_code,rs.seat_label FROM room_seats rs JOIN rooms r ON r.id=rs.room_id LEFT JOIN seating_assignments sa ON sa.allocation_id=:id AND sa.seat_id=rs.id WHERE rs.is_blocked=0 AND r.status='active' AND sa.id IS NULL ORDER BY r.priority,r.code,rs.sequence_no");$q->execute(['id'=>$id]);$availableSeats=$q->fetchAll(PDO::FETCH_ASSOC);
        $validation=(new SeatingAllocator($pdo))->validate($id);return compact('allocation','assignments','byRoom','validation','unallocated','availableSeats')+['success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function moveSeating(Request $request,int $id):Response
    { if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url("seating/{$id}"));$assignment=(int)$request->input('assignment_id');$seat=(int)$request->input('seat_id');$reason=trim((string)$request->input('reason'));$pdo=$this->database->connection();try{$pdo->beginTransaction();$q=$pdo->prepare("SELECT sa.id,a.room_id FROM seating_assignments sa JOIN seating_allocations a ON a.id=sa.allocation_id WHERE sa.id=:assignment AND sa.allocation_id=:allocation AND a.status<>'published' FOR UPDATE");$q->execute(['assignment'=>$assignment,'allocation'=>$id]);if(!$q->fetch())throw new \RuntimeException('Only draft allocations can be corrected.');$q=$pdo->prepare('SELECT room_id FROM room_seats WHERE id=:seat AND is_blocked=0');$q->execute(['seat'=>$seat]);$room=(int)$q->fetchColumn();if(!$room)throw new \RuntimeException('Choose a usable seat.');$q=$pdo->prepare('SELECT COUNT(*) FROM seating_assignments WHERE allocation_id=:allocation AND seat_id=:seat');$q->execute(['allocation'=>$id,'seat'=>$seat]);if((int)$q->fetchColumn())throw new \RuntimeException('That seat is already occupied.');$pdo->prepare('UPDATE seating_assignments SET room_id=:room,seat_id=:seat,is_manual_override=1,override_reason=:reason WHERE id=:id')->execute(['room'=>$room,'seat'=>$seat,'reason'=>$reason?:'Manual correction','id'=>$assignment]);$this->audit($pdo,'seating.assignment_moved','seating_allocation',$id,['assignment_id'=>$assignment,'seat_id'=>$seat,'reason'=>$reason]);$pdo->commit();$this->session->flash('success','Seat assignment corrected.');}catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('error',$e->getMessage());}return Response::redirect(url("seating/{$id}")); }
    private function assignUnallocated(Request $request,int $id):Response
    { if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url("seating/{$id}"));$pending=(int)$request->input('unallocated_id');$seat=(int)$request->input('seat_id');$pdo=$this->database->connection();try{$pdo->beginTransaction();$q=$pdo->prepare("SELECT su.*,a.status FROM seating_unallocated su JOIN seating_allocations a ON a.id=su.allocation_id WHERE su.id=:pending AND su.allocation_id=:allocation AND su.resolved_at IS NULL FOR UPDATE");$q->execute(['pending'=>$pending,'allocation'=>$id]);$row=$q->fetch(PDO::FETCH_ASSOC);if(!$row||$row['status']==='published')throw new \RuntimeException('This student cannot be assigned in the current version.');$q=$pdo->prepare('SELECT rs.room_id FROM room_seats rs JOIN rooms r ON r.id=rs.room_id WHERE rs.id=:seat AND rs.is_blocked=0 AND r.status=\'active\'');$q->execute(['seat'=>$seat]);$room=(int)$q->fetchColumn();if(!$room)throw new \RuntimeException('Choose a usable seat.');$pdo->prepare('INSERT INTO seating_assignments(allocation_id,examination_id,room_id,seat_id,student_id,is_manual_override,override_reason) VALUES(:allocation,:exam,:room,:seat,:student,1,\'Assigned from unallocated list\')')->execute(['allocation'=>$id,'exam'=>$row['examination_id'],'room'=>$room,'seat'=>$seat,'student'=>$row['student_id']]);$pdo->prepare('UPDATE seating_unallocated SET resolved_at=NOW() WHERE id=:id')->execute(['id'=>$pending]);$this->audit($pdo,'seating.unallocated_resolved','seating_allocation',$id,['student_id'=>$row['student_id'],'seat_id'=>$seat]);$pdo->commit();$this->session->flash('success','Unallocated student assigned.');}catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('error',$e->getMessage());}return Response::redirect(url("seating/{$id}")); }

    private function publishSeating(Request $request,int $id): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('seating/'.$id));$pdo=$this->database->connection();$validation=(new SeatingAllocator($pdo))->validate($id);
        if(!$validation['valid']){$this->session->flash('error','Allocation validation failed and cannot be published.');return Response::redirect(url('seating/'.$id));}
        $pdo->beginTransaction();try{$q=$pdo->prepare('SELECT cycle_id,exam_date,shift_id FROM seating_allocations WHERE id=:id FOR UPDATE');$q->execute(['id'=>$id]);$a=$q->fetch(PDO::FETCH_ASSOC);
            $pdo->prepare("UPDATE seating_allocations SET status='superseded' WHERE cycle_id=:cycle AND exam_date=:date AND shift_id=:shift AND status='published'")->execute(['cycle'=>$a['cycle_id'],'date'=>$a['exam_date'],'shift'=>$a['shift_id']]);
            $pdo->prepare("UPDATE seating_allocations SET status='published',published_at=NOW() WHERE id=:id")->execute(['id'=>$id]);
            $pdo->prepare("INSERT IGNORE INTO attendance(allocation_id,examination_id,room_id,student_id,status)
                SELECT allocation_id,examination_id,room_id,student_id,'unmarked' FROM seating_assignments WHERE allocation_id=:id")->execute(['id'=>$id]);
            $pdo->commit();$this->session->flash('success','Seating plan published and attendance sheets generated.');}
        catch(\Throwable $e){$pdo->rollBack();$this->session->flash('error',$e->getMessage());}return Response::redirect(url('seating/'.$id));
    }

    private function attendanceData(): array
    {
        return ['allocations'=>$this->database->connection()->query("SELECT sa.id,sa.exam_date,ec.name AS cycle_name,es.name AS shift_name,
            COUNT(a.id) AS student_count,SUM(a.status='present') AS present_count,SUM(a.status='absent') AS absent_count,
            SUM(a.status='unmarked') AS unmarked_count,COUNT(DISTINCT a.room_id) AS room_count
            FROM seating_allocations sa JOIN exam_cycles ec ON ec.id=sa.cycle_id JOIN exam_shifts es ON es.id=sa.shift_id LEFT JOIN attendance a ON a.allocation_id=sa.id
            WHERE sa.status='published' GROUP BY sa.id ORDER BY sa.exam_date DESC")->fetchAll(PDO::FETCH_ASSOC),'success'=>$this->session->pullFlash('success')];
    }

    private function attendanceSheetData(int $allocationId): array
    {
        $pdo=$this->database->connection();$q=$pdo->prepare("SELECT sa.*,ec.name AS cycle_name,es.name AS shift_name,es.start_time,es.end_time FROM seating_allocations sa JOIN exam_cycles ec ON ec.id=sa.cycle_id JOIN exam_shifts es ON es.id=sa.shift_id WHERE sa.id=:id AND sa.status='published'");$q->execute(['id'=>$allocationId]);$allocation=$q->fetch(PDO::FETCH_ASSOC);if(!$allocation)throw new \RuntimeException('Published allocation not found.');
        $q=$pdo->prepare("SELECT a.*,r.code AS room_code,s.roll_no_original,s.name,p.code AS programme_code,rs.seat_label,c.code AS course_code
            FROM attendance a JOIN rooms r ON r.id=a.room_id JOIN students s ON s.id=a.student_id JOIN programmes p ON p.id=s.programme_id
            JOIN seating_assignments sa ON sa.allocation_id=a.allocation_id AND sa.student_id=a.student_id JOIN room_seats rs ON rs.id=sa.seat_id JOIN examinations e ON e.id=a.examination_id JOIN courses c ON c.id=e.course_id
            WHERE a.allocation_id=:id ORDER BY r.code,rs.sequence_no");$q->execute(['id'=>$allocationId]);$records=$q->fetchAll(PDO::FETCH_ASSOC);$byRoom=[];foreach($records as $record)$byRoom[$record['room_code']][]=$record;return compact('allocation','records','byRoom')+['success'=>$this->session->pullFlash('success')];
    }

    private function saveAttendance(Request $request,int $allocationId): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('attendance/'.$allocationId));$statuses=(array)($_POST['status']??[]);$pdo=$this->database->connection();$allowed=['unmarked','present','absent','unfair_means','withheld','other'];$pdo->beginTransaction();try{$q=$pdo->prepare('UPDATE attendance SET status=:status,marked_by=:user,marked_at=NOW() WHERE id=:id AND allocation_id=:allocation');foreach($statuses as $id=>$status)if(in_array($status,$allowed,true))$q->execute(['status'=>$status,'user'=>$this->auth->user()['id'],'id'=>(int)$id,'allocation'=>$allocationId]);$pdo->commit();$this->session->flash('success','Attendance saved.');}catch(\Throwable $e){$pdo->rollBack();throw $e;}return Response::redirect(url('attendance/'.$allocationId));
    }

    private function invigilationData(): array
    {
        $pdo=$this->database->connection();return ['sessions'=>$pdo->query("SELECT sa.id,sa.exam_date,ec.name AS cycle_name,es.name AS shift_name,
            COUNT(DISTINCT ss.room_id) AS room_count,(SELECT COUNT(*) FROM invigilation_allocations ia WHERE ia.cycle_id=sa.cycle_id AND ia.exam_date=sa.exam_date AND ia.shift_id=sa.shift_id AND ia.duty_status<>'cancelled') AS duty_count
            FROM seating_allocations sa JOIN exam_cycles ec ON ec.id=sa.cycle_id JOIN exam_shifts es ON es.id=sa.shift_id JOIN seating_assignments ss ON ss.allocation_id=sa.id WHERE sa.status='published' GROUP BY sa.id ORDER BY sa.exam_date DESC")->fetchAll(PDO::FETCH_ASSOC),
            'duties'=>$pdo->query("SELECT ia.*,f.name AS faculty_name,f.employee_id,r.code AS room_code,es.name AS shift_name,ec.name AS cycle_name FROM invigilation_allocations ia JOIN faculty f ON f.id=ia.faculty_id JOIN rooms r ON r.id=ia.room_id JOIN exam_shifts es ON es.id=ia.shift_id JOIN exam_cycles ec ON ec.id=ia.cycle_id WHERE ia.duty_status<>'cancelled' ORDER BY ia.exam_date DESC,es.sequence_no,r.code")->fetchAll(PDO::FETCH_ASSOC),'success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function allocateInvigilators(Request $request,int $allocationId): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('invigilation'));$pdo=$this->database->connection();$q=$pdo->prepare('SELECT cycle_id,exam_date,shift_id FROM seating_allocations WHERE id=:id AND status=\'published\'');$q->execute(['id'=>$allocationId]);$session=$q->fetch(PDO::FETCH_ASSOC);if(!$session){$this->session->flash('error','Published seating session not found.');return Response::redirect(url('invigilation'));}
        $q=$pdo->prepare('SELECT DISTINCT room_id FROM seating_assignments WHERE allocation_id=:id ORDER BY room_id');$q->execute(['id'=>$allocationId]);$rooms=$q->fetchAll(PDO::FETCH_COLUMN);$faculty=$pdo->prepare("SELECT f.id FROM faculty f WHERE f.status='active' AND NOT EXISTS(SELECT 1 FROM faculty_availability fa WHERE fa.faculty_id=f.id AND fa.exam_date=:date AND fa.shift_id=:shift AND fa.availability='unavailable') AND NOT EXISTS(SELECT 1 FROM invigilation_allocations ia WHERE ia.faculty_id=f.id AND ia.exam_date=:date2 AND ia.shift_id=:shift2 AND ia.duty_status<>'cancelled') ORDER BY f.duty_count,f.name");$faculty->execute(['date'=>$session['exam_date'],'shift'=>$session['shift_id'],'date2'=>$session['exam_date'],'shift2'=>$session['shift_id']]);$available=$faculty->fetchAll(PDO::FETCH_COLUMN);
        if(count($available)<count($rooms)){$this->session->flash('error','Not enough available faculty for all rooms.');return Response::redirect(url('invigilation'));}$pdo->beginTransaction();try{$insert=$pdo->prepare("INSERT INTO invigilation_allocations(cycle_id,exam_date,shift_id,room_id,faculty_id,duty_status,assigned_by) VALUES(:cycle,:date,:shift,:room,:faculty,'assigned',:user)");foreach($rooms as $i=>$room){$insert->execute(['cycle'=>$session['cycle_id'],'date'=>$session['exam_date'],'shift'=>$session['shift_id'],'room'=>$room,'faculty'=>$available[$i],'user'=>$this->auth->user()['id']]);$pdo->prepare('UPDATE faculty SET duty_count=duty_count+1 WHERE id=:id')->execute(['id'=>$available[$i]]);}$pdo->commit();$this->session->flash('success',count($rooms).' invigilators allocated without conflicts.');}catch(\Throwable $e){$pdo->rollBack();$this->session->flash('error','Duties already exist for this session or a conflict was detected.');}return Response::redirect(url('invigilation'));
    }

    private function replacementData(): array
    {
        return ['requests'=>$this->database->connection()->query("SELECT rr.*,f.name AS original_name,rf.name AS replacement_name,r.code AS room_code,ia.exam_date,es.name AS shift_name FROM replacement_requests rr JOIN invigilation_allocations ia ON ia.id=rr.duty_id JOIN faculty f ON f.id=ia.faculty_id LEFT JOIN faculty rf ON rf.id=rr.replacement_faculty_id JOIN rooms r ON r.id=ia.room_id JOIN exam_shifts es ON es.id=ia.shift_id ORDER BY rr.created_at DESC")->fetchAll(PDO::FETCH_ASSOC),'duties'=>$this->database->connection()->query("SELECT ia.id,ia.exam_date,es.name AS shift_name,r.code AS room_code,f.name AS faculty_name FROM invigilation_allocations ia JOIN exam_shifts es ON es.id=ia.shift_id JOIN rooms r ON r.id=ia.room_id JOIN faculty f ON f.id=ia.faculty_id WHERE ia.duty_status='assigned' ORDER BY ia.exam_date DESC")->fetchAll(PDO::FETCH_ASSOC),'faculty'=>$this->database->connection()->query("SELECT id,name FROM faculty WHERE status='active' ORDER BY name")->fetchAll(PDO::FETCH_ASSOC),'success'=>$this->session->pullFlash('success')];
    }

    private function requestReplacement(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('replacements'));$this->database->connection()->prepare("INSERT INTO replacement_requests(duty_id,requested_by,reason,replacement_faculty_id,status) VALUES(:duty,:user,:reason,:faculty,'pending')")->execute(['duty'=>(int)$request->input('duty_id'),'user'=>$this->auth->user()['id'],'reason'=>trim((string)$request->input('reason')),'faculty'=>(int)$request->input('replacement_faculty_id')?:null]);$this->session->flash('success','Replacement request submitted.');return Response::redirect(url('replacements'));
    }

    private function reviewReplacement(Request $request,int $id,string $decision): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('replacements'));$pdo=$this->database->connection();$pdo->beginTransaction();try{$q=$pdo->prepare('SELECT * FROM replacement_requests WHERE id=:id AND status=\'pending\' FOR UPDATE');$q->execute(['id'=>$id]);$r=$q->fetch(PDO::FETCH_ASSOC);if(!$r)throw new \RuntimeException('Request unavailable.');$status=$decision==='approve'?'approved':'rejected';$pdo->prepare('UPDATE replacement_requests SET status=:status,reviewed_by=:user,reviewed_at=NOW() WHERE id=:id')->execute(['status'=>$status,'user'=>$this->auth->user()['id'],'id'=>$id]);if($status==='approved'&&$r['replacement_faculty_id']){$pdo->prepare("UPDATE invigilation_allocations SET faculty_id=:faculty,duty_status='replaced' WHERE id=:id")->execute(['faculty'=>$r['replacement_faculty_id'],'id'=>$r['duty_id']]);}$pdo->commit();$this->session->flash('success','Replacement request '.$status.'.');}catch(\Throwable $e){$pdo->rollBack();$this->session->flash('success',$e->getMessage());}return Response::redirect(url('replacements'));
    }

    private function reportData(): array
    {
        $pdo=$this->database->connection();return ['totals'=>['students'=>(int)$pdo->query('SELECT COUNT(*) FROM students')->fetchColumn(),'faculty'=>(int)$pdo->query("SELECT COUNT(*) FROM faculty WHERE status='active'")->fetchColumn(),'rooms'=>(int)$pdo->query("SELECT COUNT(*) FROM rooms WHERE status='active'")->fetchColumn(),'usable_seats'=>(int)$pdo->query("SELECT COALESCE(SUM(usable_capacity),0) FROM rooms WHERE status='active'")->fetchColumn(),'cycles'=>(int)$pdo->query('SELECT COUNT(*) FROM exam_cycles')->fetchColumn(),'published_allocations'=>(int)$pdo->query("SELECT COUNT(*) FROM seating_allocations WHERE status='published'")->fetchColumn()],
            'programmeCounts'=>$pdo->query("SELECT p.code,p.name,COUNT(s.id) AS student_count FROM programmes p LEFT JOIN students s ON s.programme_id=p.id GROUP BY p.id ORDER BY student_count DESC,p.code")->fetchAll(PDO::FETCH_ASSOC),
            'attendance'=>$pdo->query("SELECT status,COUNT(*) AS total FROM attendance GROUP BY status")->fetchAll(PDO::FETCH_ASSOC)];
    }

    private function auditData(): array
    {
        return ['logs'=>$this->database->connection()->query("SELECT al.*,u.username FROM audit_logs al LEFT JOIN users u ON u.id=al.user_id ORDER BY al.created_at DESC LIMIT 250")->fetchAll(PDO::FETCH_ASSOC)];
    }

    private function studentCsv(): Response
    {
        $rows=$this->database->connection()->query("SELECT s.roll_no_original,s.enrollment_number,s.academic_session,s.normalized_roll_no,s.name,s.branch,s.mobile_number,s.address,s.department_name,s.school_name,s.current_year_of_study,p.code AS programme,s.semester,s.section,s.special_status,s.parsing_status,s.status FROM students s LEFT JOIN programmes p ON p.id=s.programme_id ORDER BY s.normalized_roll_no")->fetchAll(PDO::FETCH_ASSOC);$stream=fopen('php://temp','w+');fputcsv($stream,['Enrollment/Roll Number','Enrollment Number','Academic Session','Normalized Roll Number','Full Name','Branch','Mobile Number','Address','Department','School','Current Year of Study','Programme','Current Semester','Section','Special Status','Parsing Status','Status']);foreach($rows as $row)fputcsv($stream,$row);rewind($stream);$content=stream_get_contents($stream);fclose($stream);return Response::csv("\xEF\xBB\xBF".$content,'gbu-students-'.date('Y-m-d').'.csv');
    }

    private function attendanceCsv():Response
    {return $this->csvResponse("SELECT ec.name AS cycle,a.allocation_id,sa.exam_date,es.name AS shift,r.code AS room,rs.seat_label,s.roll_no_original,s.name,p.code AS programme,c.code AS course,a.status,a.remarks FROM attendance a JOIN seating_allocations sa ON sa.id=a.allocation_id JOIN exam_cycles ec ON ec.id=sa.cycle_id JOIN exam_shifts es ON es.id=sa.shift_id JOIN rooms r ON r.id=a.room_id JOIN students s ON s.id=a.student_id JOIN programmes p ON p.id=s.programme_id JOIN seating_assignments x ON x.allocation_id=a.allocation_id AND x.student_id=a.student_id JOIN room_seats rs ON rs.id=x.seat_id JOIN examinations e ON e.id=a.examination_id JOIN courses c ON c.id=e.course_id ORDER BY sa.exam_date,es.sequence_no,r.code,rs.sequence_no",'gbu-attendance');}
    private function invigilationCsv():Response
    {return $this->csvResponse("SELECT ec.name AS cycle,ia.exam_date,es.name AS shift,r.code AS room,f.employee_id,f.name AS faculty,f.designation,ia.duty_status FROM invigilation_allocations ia JOIN exam_cycles ec ON ec.id=ia.cycle_id JOIN exam_shifts es ON es.id=ia.shift_id JOIN rooms r ON r.id=ia.room_id JOIN faculty f ON f.id=ia.faculty_id ORDER BY ia.exam_date,es.sequence_no,r.code",'gbu-invigilation');}
    private function unallocatedCsv():Response
    {return $this->csvResponse("SELECT ec.name AS cycle,sa.exam_date,es.name AS shift,s.roll_no_original,s.name,p.code AS programme,c.code AS course,su.reason,su.resolved_at FROM seating_unallocated su JOIN seating_allocations sa ON sa.id=su.allocation_id JOIN exam_cycles ec ON ec.id=sa.cycle_id JOIN exam_shifts es ON es.id=sa.shift_id JOIN students s ON s.id=su.student_id JOIN programmes p ON p.id=s.programme_id JOIN examinations e ON e.id=su.examination_id JOIN courses c ON c.id=e.course_id ORDER BY sa.exam_date,s.normalized_roll_no",'gbu-unallocated');}
    private function csvResponse(string $sql,string $name):Response
    {$rows=$this->database->connection()->query($sql)->fetchAll(PDO::FETCH_ASSOC);$stream=fopen('php://temp','w+');if($rows)fputcsv($stream,array_map(fn($key)=>ucwords(str_replace('_',' ',$key)),array_keys($rows[0])));foreach($rows as $row)fputcsv($stream,$row);rewind($stream);$content=stream_get_contents($stream);fclose($stream);return Response::csv("\xEF\xBB\xBF".$content,$name.'-'.date('Y-m-d').'.csv');}

    private function saveSchool(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('masters/schools'));
        $code=strtoupper(trim((string)$request->input('code')));$name=trim((string)$request->input('name'));$short=trim((string)$request->input('short_name'))?:null;
        if($code===''||$name===''){$this->session->flash('error','School code and name are required.');return Response::redirect(url('masters/schools'));}
        try{$pdo=$this->database->connection();$pdo->prepare("INSERT INTO schools(code,name,short_name,status) VALUES(:code,:name,:short,'active')")->execute(['code'=>$code,'name'=>$name,'short'=>$short]);$this->audit($pdo,'school.created','school',(int)$pdo->lastInsertId(),compact('code','name','short'));$this->session->flash('success','School created.');}catch(\Throwable){$this->session->flash('error','School code must be unique.');}return Response::redirect(url('masters/schools'));
    }

    private function saveProgramme(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('masters/programmes'));
        $data=['school_id'=>(int)$request->input('school_id'),'code'=>strtoupper(trim((string)$request->input('code'))),'name'=>trim((string)$request->input('name')),'level'=>(string)$request->input('level','undergraduate'),'duration_semesters'=>(int)$request->input('duration_semesters')?:null,'lateral_entry'=>$request->input('lateral_entry')?1:0,'legacy'=>$request->input('legacy')?1:0,'status'=>'active'];
        if(!$data['school_id']||$data['code']===''||$data['name']===''){$this->session->flash('error','School, programme code, and programme name are required.');return Response::redirect(url('masters/programmes'));}
        try{$pdo=$this->database->connection();$keys=array_keys($data);$pdo->prepare('INSERT INTO programmes('.implode(',',$keys).') VALUES('.implode(',',array_map(fn($k)=>":{$k}",$keys)).')')->execute($data);$this->audit($pdo,'programme.created','programme',(int)$pdo->lastInsertId(),$data);$this->session->flash('success','Programme mapping created.');}catch(\Throwable){$this->session->flash('error','Programme code must be unique.');}return Response::redirect(url('masters/programmes'));
    }

    private function facultyAvailabilityData(): array
    {
        $pdo=$this->database->connection();return ['faculty'=>$pdo->query("SELECT id,employee_id,name FROM faculty WHERE status='active' ORDER BY name")->fetchAll(PDO::FETCH_ASSOC),'shifts'=>$pdo->query("SELECT es.id,es.name,es.start_time,ec.name AS cycle_name,ec.start_date,ec.end_date FROM exam_shifts es JOIN exam_cycles ec ON ec.id=es.cycle_id WHERE ec.status IN ('draft','published') ORDER BY ec.start_date DESC,es.sequence_no")->fetchAll(PDO::FETCH_ASSOC),'entries'=>$pdo->query("SELECT fa.*,f.name AS faculty_name,f.employee_id,es.name AS shift_name,ec.name AS cycle_name FROM faculty_availability fa JOIN faculty f ON f.id=fa.faculty_id JOIN exam_shifts es ON es.id=fa.shift_id JOIN exam_cycles ec ON ec.id=es.cycle_id ORDER BY fa.exam_date DESC,f.name LIMIT 250")->fetchAll(PDO::FETCH_ASSOC),'success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function saveFacultyAvailability(Request $request): Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('faculty/availability'));
        $data=['faculty'=>(int)$request->input('faculty_id'),'date'=>(string)$request->input('exam_date'),'shift'=>(int)$request->input('shift_id'),'availability'=>(string)$request->input('availability'),'reason'=>trim((string)$request->input('reason'))?:null];
        if(!$data['faculty']||!$data['shift']||$data['date']===''||!in_array($data['availability'],['available','unavailable','preferred'],true)){$this->session->flash('error','Complete all availability fields.');return Response::redirect(url('faculty/availability'));}
        $this->database->connection()->prepare("INSERT INTO faculty_availability(faculty_id,exam_date,shift_id,availability,reason) VALUES(:faculty,:date,:shift,:availability,:reason) ON DUPLICATE KEY UPDATE availability=VALUES(availability),reason=VALUES(reason)")->execute($data);$this->session->flash('success','Faculty availability saved.');return Response::redirect(url('faculty/availability'));
    }

    private function userData():array
    {
        $pdo=$this->database->connection();$definitions=RolePolicy::definitions();$roles=$pdo->query('SELECT id,code,name FROM roles ORDER BY name')->fetchAll(PDO::FETCH_ASSOC);foreach($roles as &$role){$role['description']=$definitions[$role['code']]['description']??'';$role['permissions']=RolePolicy::grants($role['code']);}unset($role);
        return ['users'=>$pdo->query('SELECT u.id,u.username,u.name,u.email,u.status,u.last_login_at,u.created_at,r.id AS role_id,r.code AS role_code,r.name AS role_name FROM users u JOIN roles r ON r.id=u.role_id ORDER BY u.name')->fetchAll(PDO::FETCH_ASSOC),'roles'=>$roles,'permissionLabels'=>RolePolicy::permissionLabels(),'success'=>$this->session->pullFlash('success'),'error'=>$this->session->pullFlash('error')];
    }

    private function saveUser(Request $request,?int $id=null):Response
    {
        if(!$this->session->validCsrf((string)$request->input('_token')))return Response::redirect(url('users'));
        $pdo=$this->database->connection();$username=strtolower(trim((string)$request->input('username')));$name=trim((string)$request->input('name'));$email=trim((string)$request->input('email'))?:null;$roleId=(int)$request->input('role_id');$status=(string)$request->input('status','active');$password=(string)$request->input('password');
        if(!preg_match('/^[a-z0-9._-]{3,80}$/',$username)||$name===''||!in_array($status,['active','inactive','locked'],true)){$this->session->flash('error','Enter a valid username, name, role, and account status.');return Response::redirect(url('users'));}
        if($email!==null&&!filter_var($email,FILTER_VALIDATE_EMAIL)){$this->session->flash('error','Enter a valid university email address.');return Response::redirect(url('users'));}
        if(!$id&&strlen($password)<12){$this->session->flash('error','New accounts require a password of at least 12 characters.');return Response::redirect(url('users'));}
        $role=$pdo->prepare('SELECT code FROM roles WHERE id=:id');$role->execute(['id'=>$roleId]);$roleCode=(string)$role->fetchColumn();if($roleCode===''){$this->session->flash('error','Select a valid role.');return Response::redirect(url('users'));}
        if($id===(int)($this->auth->user()['id']??0)&&($status!=='active'||$roleCode!=='admin')){$this->session->flash('error','You cannot remove your own administrator access or deactivate your signed-in account.');return Response::redirect(url('users'));}
        try{$pdo->beginTransaction();if($id){$sql='UPDATE users SET role_id=:role,username=:username,name=:name,email=:email,status=:status';$data=['role'=>$roleId,'username'=>$username,'name'=>$name,'email'=>$email,'status'=>$status,'id'=>$id];if($password!==''){if(strlen($password)<12)throw new \RuntimeException('Replacement passwords must contain at least 12 characters.');$sql.=',password_hash=:password';$data['password']=password_hash($password,PASSWORD_DEFAULT);}$sql.=' WHERE id=:id';$pdo->prepare($sql)->execute($data);$action='user.updated';}
            else{$pdo->prepare('INSERT INTO users(role_id,username,name,email,password_hash,status) VALUES(:role,:username,:name,:email,:password,:status)')->execute(['role'=>$roleId,'username'=>$username,'name'=>$name,'email'=>$email,'password'=>password_hash($password,PASSWORD_DEFAULT),'status'=>$status]);$id=(int)$pdo->lastInsertId();$action='user.created';}
            $pdo->prepare('INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,:action,\'user\',:id,:data)')->execute(['user'=>$this->auth->user()['id'],'action'=>$action,'id'=>$id,'data'=>json_encode(['username'=>$username,'role'=>$roleCode,'status'=>$status])]);$pdo->commit();$this->session->flash('success',$action==='user.created'?'User account created.':'User access updated.');}
        catch(\Throwable $e){if($pdo->inTransaction())$pdo->rollBack();$this->session->flash('error',str_contains(strtolower($e->getMessage()),'duplicate')?'Username or email already exists.':$e->getMessage());}
        return Response::redirect(url('users'));
    }
}
