<?php

declare(strict_types=1);

namespace App\Academic;

use PDO;

final class StudentRepository
{
    public function __construct(private readonly PDO $pdo) {}

    public function paginate(string $search = '', ?int $programmeId = null, ?int $batchId = null, int $page = 1, int $perPage = 25, ?int $schoolId = null): array
    {
        $where = ['1=1']; $params = [];
        if ($search !== '') {
            $where[] = '(s.roll_no_original LIKE :search_roll OR s.enrollment_number LIKE :search_enrollment OR s.normalized_roll_no LIKE :search_normalized OR s.name LIKE :search_name OR s.mobile_number LIKE :search_mobile)';
            foreach (['roll','enrollment','normalized','name','mobile'] as $field) $params['search_'.$field] = '%' . $search . '%';
        }
        if ($schoolId) { $where[] = 'EXISTS (SELECT 1 FROM programmes sp WHERE sp.id=s.programme_id AND sp.school_id=:school_id)'; $params['school_id'] = $schoolId; }
        if ($programmeId) { $where[] = 's.programme_id=:programme_id'; $params['programme_id'] = $programmeId; }
        if ($batchId) { $where[] = 's.batch_id=:batch_id'; $params['batch_id'] = $batchId; }
        $clause = implode(' AND ', $where);
        $count = $this->pdo->prepare("SELECT COUNT(*) FROM students s WHERE {$clause}");
        $count->execute($params); $total = (int) $count->fetchColumn();
        $page = max(1,min($page,max(1,(int)ceil($total/$perPage))));
        $offset = ($page - 1) * $perPage;
        $statement = $this->pdo->prepare("SELECT s.*,p.code AS programme_code,p.name AS programme_name,b.label AS batch_label,
            (SELECT t.placement_status FROM student_term_enrollments t WHERE t.student_id=s.id ORDER BY t.academic_session DESC,t.term DESC LIMIT 1) AS progression_status
            FROM students s LEFT JOIN programmes p ON p.id=s.programme_id LEFT JOIN batches b ON b.id=s.batch_id
            WHERE {$clause} ORDER BY s.normalized_roll_no LIMIT {$perPage} OFFSET {$offset}");
        $statement->execute($params);
        return ['items' => $statement->fetchAll(PDO::FETCH_ASSOC), 'total' => $total, 'page' => $page,
            'pages' => max(1, (int) ceil($total / $perPage))];
    }

    public function find(int $id): ?array
    {
        $statement = $this->pdo->prepare('SELECT * FROM students WHERE id=:id');
        $statement->execute(['id' => $id]);
        return $statement->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public function save(array $data, ?int $id = null): int
    {
        $fields = ['programme_id','batch_id','roll_no_original','enrollment_number','academic_session','normalized_roll_no','registration_prefix','programme_code_detected',
            'student_sequence','name','branch','mobile_number','address','department_name','school_name','current_year_of_study','semester','section','admission_type','special_status','parsing_status','status'];
        $payload = array_intersect_key($data, array_flip($fields));
        if ($id) {
            $sets = implode(',', array_map(static fn(string $field): string => "{$field}=:{$field}", array_keys($payload)));
            $payload['id'] = $id;
            $this->pdo->prepare("UPDATE students SET {$sets} WHERE id=:id")->execute($payload);
            return $id;
        }
        $names = implode(',', array_keys($payload));
        $bindings = implode(',', array_map(static fn(string $field): string => ":{$field}", array_keys($payload)));
        $this->pdo->prepare("INSERT INTO students ({$names}) VALUES ({$bindings})")->execute($payload);
        return (int) $this->pdo->lastInsertId();
    }
}
