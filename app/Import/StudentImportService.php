<?php

declare(strict_types=1);

namespace App\Import;

use App\Academic\RollNumberParser;
use PDO;
use RuntimeException;

final class StudentImportService
{
    public function __construct(private readonly PDO $pdo) {}

    public function stage(string $path, string $originalName, int $userId): int
    {
        $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
        $rows = (new TabularReader())->read($path, $extension);
        if (count($rows) < 2) throw new RuntimeException('The file must contain a header and at least one student row.');
        $headers = array_map([$this, 'headerKey'], array_shift($rows));
        foreach (['roll_no','academic_session','name','branch','mobile_number','address','department_name','school_name','current_year_of_study','semester','section'] as $required) {
            if (!in_array($required, $headers, true)) throw new RuntimeException("Missing required column: {$required}.");
        }
        $programmes = [];
        foreach ($this->pdo->query("SELECT id,code,lateral_entry,legacy FROM programmes WHERE status IN ('active','unverified')") as $programme) {
            $programmes[$programme['code']] = $programme;
        }
        $storedName = basename($path);
        $statement = $this->pdo->prepare("INSERT INTO import_batches(import_type,original_filename,stored_filename,status,uploaded_by)
            VALUES('students',:original,:stored,'validating',:user_id)");
        $statement->execute(['original' => $originalName, 'stored' => $storedName, 'user_id' => $userId]);
        $batchId = (int) $this->pdo->lastInsertId();
        $valid = 0; $invalid = 0;
        $insert = $this->pdo->prepare("INSERT INTO import_rows(import_batch_id,source_row_number,source_data,normalized_data,validation_status,validation_messages)
            VALUES(:batch,:row,:source,:normalized,:status,:messages)");
        foreach ($rows as $index => $values) {
            $source = [];
            foreach ($headers as $column => $header) if ($header !== '') $source[$header] = trim((string) ($values[$column] ?? ''));
            $messages = [];
            if (($source['roll_no'] ?? '') === '') $messages[] = 'Roll number is required.';
            if (($source['name'] ?? '') === '') $messages[] = 'Student name is required.';
            $academicSession=$source['academic_session']??'';if(!preg_match('/^\d{4}-\d{4}$/',$academicSession)||(int)substr($academicSession,5)!==(int)substr($academicSession,0,4)+1)$messages[]='Academic session must use consecutive YYYY-YYYY years.';
            foreach(['branch'=>'Branch','mobile_number'=>'Mobile number','address'=>'Address','department_name'=>'Department','school_name'=>'School','section'=>'Section'] as $field=>$label)if(($source[$field]??'')==='')$messages[]="{$label} is required.";
            if(($source['mobile_number']??'')!==''&&!preg_match('/^[0-9+() -]{7,20}$/',$source['mobile_number']))$messages[]='Mobile number is invalid.';
            $year=(int)($source['current_year_of_study']??0);if($year<1||$year>8)$messages[]='Current year of study must be between 1 and 8.';
            $semester = (int) ($source['semester'] ?? 0);
            if ($semester < 1 || $semester > 12) $messages[] = 'Semester must be between 1 and 12.';
            $parsed = (new RollNumberParser())->parse($source['roll_no'] ?? '', $programmes);
            if ($parsed['parsing_status'] === 'invalid') $messages[] = $parsed['message'];
            $duplicate = $this->pdo->prepare('SELECT COUNT(*) FROM students WHERE normalized_roll_no=:roll');
            $duplicate->execute(['roll' => $parsed['normalized_roll_no']]);
            if ((int) $duplicate->fetchColumn() > 0) $messages[] = 'Roll number already exists.';
            $normalized = array_merge($parsed, ['enrollment_number'=>($source['enrollment_number']??'')?:null,'academic_session'=>$academicSession,'name' => $source['name'] ?? '',
                'branch'=>$source['branch']??'','mobile_number'=>($source['mobile_number']??'')?:null,'address'=>($source['address']??'')?:null,'department_name'=>$source['department_name']??'',
                'school_name'=>$source['school_name']??'','current_year_of_study'=>$year,'semester' => $semester,'section' => $source['section'] ?? null, 'status' => 'active', 'batch_id' => null]);
            unset($normalized['message']);
            $status = $messages ? 'invalid' : ($parsed['parsing_status'] === 'review' ? 'warning' : 'valid');
            $status === 'invalid' ? $invalid++ : $valid++;
            $insert->execute(['batch' => $batchId, 'row' => $index + 2, 'source' => json_encode($source),
                'normalized' => json_encode($normalized), 'status' => $status, 'messages' => json_encode($messages)]);
        }
        $update = $this->pdo->prepare("UPDATE import_batches SET status='review',total_rows=:total,valid_rows=:valid,invalid_rows=:invalid WHERE id=:id");
        $update->execute(['total' => count($rows), 'valid' => $valid, 'invalid' => $invalid, 'id' => $batchId]);
        return $batchId;
    }

    public function commit(int $batchId, int $userId): array
    {
        $batch = $this->pdo->prepare("SELECT * FROM import_batches WHERE id=:id AND import_type='students' AND status='review' FOR UPDATE");
        $batch->execute(['id' => $batchId]);
        if (!$batch->fetch()) throw new RuntimeException('Import batch is not available for commit.');
        $rows = $this->pdo->prepare("SELECT * FROM import_rows WHERE import_batch_id=:id AND validation_status IN ('valid','warning') ORDER BY source_row_number");
        $rows->execute(['id' => $batchId]);
        $insert = $this->pdo->prepare("INSERT INTO students(programme_id,batch_id,roll_no_original,enrollment_number,academic_session,normalized_roll_no,registration_prefix,
            programme_code_detected,student_sequence,name,branch,mobile_number,address,department_name,school_name,current_year_of_study,semester,section,admission_type,special_status,parsing_status,status)
            VALUES(:programme_id,:batch_id,:roll_no_original,:enrollment_number,:academic_session,:normalized_roll_no,:registration_prefix,:programme_code_detected,
            :student_sequence,:name,:branch,:mobile_number,:address,:department_name,:school_name,:current_year_of_study,:semester,:section,:admission_type,:special_status,:parsing_status,:status)");
        $count = 0;
        foreach ($rows as $row) {
            $data = json_decode($row['normalized_data'], true, flags: JSON_THROW_ON_ERROR);
            $insert->execute($data);
            $entityId = (int) $this->pdo->lastInsertId();
            $this->pdo->prepare('UPDATE import_rows SET committed_entity_id=:entity WHERE id=:id')->execute(['entity' => $entityId, 'id' => $row['id']]);
            $count++;
        }
        $this->pdo->prepare("UPDATE import_batches SET status='committed',committed_at=NOW() WHERE id=:id")->execute(['id' => $batchId]);
        $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,'student_import.committed','import_batch',:id,:data)")
            ->execute(['user' => $userId, 'id' => $batchId, 'data' => json_encode(['students_created' => $count])]);
        return ['created' => $count];
    }

    private function headerKey(string $header): string
    {
        $key = strtolower(trim($header));
        $key = preg_replace('/[^a-z0-9]+/', '_', $key) ?? '';
        $aliases = ['roll_number'=>'roll_no','enrollment_roll_number'=>'roll_no','roll_no_original'=>'roll_no','student_name'=>'name','full_name'=>'name','student'=>'name','sem'=>'semester','current_semester'=>'semester','academic_year'=>'academic_session','session'=>'academic_session','enrolment_number'=>'enrollment_number','mobile'=>'mobile_number','phone'=>'mobile_number','department'=>'department_name','school'=>'school_name','current_year'=>'current_year_of_study','year_of_study'=>'current_year_of_study'];
        return $aliases[$key] ?? trim($key, '_');
    }
}
