<?php

declare(strict_types=1);

$root = dirname(__DIR__);
$studentCsv = $root . '/storage/demo-data/large-multi-branch/students_large_multi_branch.csv';
$facultyCsv = $root . '/storage/demo-data/large-multi-branch/faculty_large_all_schools.csv';
$courseCsv = $root . '/storage/demo-data/btech_cse_2022_23_curriculum_upload.csv';
$output = $root . '/database/infinityfree_demo_data_seed.sql';

/** @return list<array<string,string>> */
function csvRows(string $path): array
{
    $handle = fopen($path, 'rb');
    if ($handle === false) throw new RuntimeException("Unable to read {$path}");
    $headers = fgetcsv($handle);
    if ($headers === false) throw new RuntimeException("CSV has no header: {$path}");
    $rows = [];
    while (($values = fgetcsv($handle)) !== false) {
        if ($values === [null] || $values === []) continue;
        $values = array_pad($values, count($headers), '');
        $rows[] = array_combine($headers, array_slice($values, 0, count($headers)));
    }
    fclose($handle);
    return $rows;
}

function sqlString(?string $value): string
{
    if ($value === null || $value === '') return 'NULL';
    return "'" . str_replace("'", "''", trim($value)) . "'";
}

/** @param list<string> $values */
function chunkedInsert(string $table, array $columns, array $values, string $duplicateClause, int $size = 100): string
{
    $sql = '';
    foreach (array_chunk($values, $size) as $chunk) {
        $sql .= "INSERT INTO {$table} (" . implode(',', $columns) . ") VALUES\n";
        $sql .= implode(",\n", $chunk) . "\n{$duplicateClause};\n\n";
    }
    return $sql;
}

$schools = [
    ['SOM', 'School of Management', 'Management'],
    ['SOBT', 'School of Biotechnology', 'Biotechnology'],
    ['ICT', 'School of Information and Communication Technology', 'SOICT'],
    ['SOE', 'School of Engineering', 'Engineering'],
    ['SOVSAS', 'School of Vocational Studies and Applied Sciences', 'Vocational & Applied Sciences'],
    ['SOHSS', 'School of Humanities and Social Sciences', 'Humanities & Social Sciences'],
    ['SOBSC', 'School of Buddhist Studies and Civilization', 'Buddhist Studies'],
    ['SOLJG', 'School of Law, Justice and Governance', 'Law, Justice & Governance'],
];

$programmes = [
    ['ICT','UCS','B.Tech Computer Science and Engineering','undergraduate',8,0,0],
    ['ICT','UCM','B.Tech Machine Learning','undergraduate',8,0,0],
    ['ICT','UCD','B.Tech Data Science','undergraduate',8,0,0],
    ['ICT','UCC','B.Tech Cyber Security','undergraduate',8,0,0],
    ['ICT','UAI','B.Tech Artificial Intelligence','undergraduate',8,0,0],
    ['ICT','UIT','B.Tech Information Technology','undergraduate',8,0,0],
    ['ICT','UCA','Bachelor of Computer Applications','undergraduate',6,0,0],
    ['ICT','LCS','CSE Lateral Entry','undergraduate',6,1,0],
    ['ICT','LIT','IT Lateral Entry','undergraduate',6,1,0],
    ['ICT','PCS','M.Tech Computer Science and Engineering','postgraduate',4,0,0],
    ['ICT','PCW','M.Tech CSE Working Professional','postgraduate',4,0,0],
    ['ICT','ICS','Integrated B.Tech Computer Science and Engineering','integrated',10,0,1],
    ['SOE','UEC','B.Tech Electronics and Communication Engineering','undergraduate',8,0,0],
    ['SOE','UVL','B.Tech ECE VLSI Design and Embedded Systems','undergraduate',8,0,0],
    ['SOE','UEA','B.Tech ECE Artificial Intelligence and Machine Learning','undergraduate',8,0,0],
    ['SOE','LEA','ECE AI and ML Lateral Entry','undergraduate',6,1,0],
    ['SOE','IEC','Integrated Electronics and Communication Engineering','integrated',10,0,1],
];

$studentRows = csvRows($studentCsv);
$facultyRows = csvRows($facultyCsv);
$courseRows = csvRows($courseCsv);

$sql = "-- GBU hosted demo data seed for phpMyAdmin\n";
$sql .= "-- Repeatable: existing records are updated by their unique identifiers.\n";
$sql .= "-- Contains 340 students, 64 faculty members, and 94 UCS curriculum mappings.\n";
$sql .= "SET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS = 0;\nSTART TRANSACTION;\n\n";

$schoolValues = array_map(static fn(array $s): string => '(' . implode(',', [sqlString($s[0]),sqlString($s[1]),sqlString($s[2]),"'active'"]) . ')', $schools);
$sql .= chunkedInsert('schools', ['code','name','short_name','status'], $schoolValues,
    "ON DUPLICATE KEY UPDATE name=VALUES(name),short_name=VALUES(short_name),status='active'", 100);

foreach ($programmes as [$schoolCode,$code,$name,$level,$semesters,$lateral,$legacy]) {
    $sql .= "INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)\n";
    $sql .= "SELECT id," . sqlString($code) . ',' . sqlString($name) . ',' . sqlString($level) . ",{$semesters},{$lateral},{$legacy},'active' FROM schools WHERE code=" . sqlString($schoolCode) . "\n";
    $sql .= "ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';\n\n";
}

$courseValues = [];
foreach ($courseRows as $row) {
    $courseValues[] = '(' . implode(',', [sqlString($row['Course Code']),sqlString($row['Course Name']),sqlString($row['Status'])]) . ')';
}
$sql .= chunkedInsert('courses', ['code','name','status'], $courseValues,
    "ON DUPLICATE KEY UPDATE name=VALUES(name),status=VALUES(status)", 100);

foreach ($courseRows as $row) {
    $sql .= "INSERT INTO programme_courses (programme_id,course_id,semester,category)\n";
    $sql .= "SELECT p.id,c.id," . (int)$row['Semester'] . ',' . sqlString(strtolower($row['Category'])) . " FROM programmes p JOIN courses c ON c.code=" . sqlString($row['Course Code']) . " WHERE p.code=" . sqlString($row['Programme Code']) . "\n";
    $sql .= "ON DUPLICATE KEY UPDATE category=VALUES(category);\n";
}
$sql .= "\n";

$studentValues = [];
foreach ($studentRows as $row) {
    $roll = strtoupper(preg_replace('/[^A-Z0-9]/', '', $row['Enrollment/Roll Number']) ?? '');
    if (!preg_match('/^([0-9]{3})([A-Z]{3})([0-9]{3})$/', $roll, $parts)) {
        throw new RuntimeException("Invalid demo roll number: {$row['Enrollment/Roll Number']}");
    }
    $code = $parts[2];
    $admission = in_array($code, ['LCS','LIT','LEA'], true) ? 'lateral' : (in_array($code, ['ICS','IEC'], true) ? 'legacy' : 'regular');
    $studentValues[] = '(' . implode(',', [
        "(SELECT id FROM programmes WHERE code=" . sqlString($code) . " LIMIT 1)",
        'NULL', sqlString($row['Enrollment/Roll Number']), sqlString($row['Enrollment Number']), sqlString($row['Academic Session']),
        sqlString($roll), sqlString($parts[1]), sqlString($code), sqlString($parts[3]), sqlString($row['Full Name']),
        sqlString($row['Branch']), sqlString($row['Mobile Number']), sqlString($row['Address']), sqlString($row['Department']),
        sqlString($row['School']), (string)(int)$row['Current Year of Study'], (string)(int)$row['Current Semester'], sqlString($row['Section']),
        sqlString($admission), "'none'", "'verified'", "'active'"
    ]) . ')';
}
$sql .= chunkedInsert('students', [
    'programme_id','batch_id','roll_no_original','enrollment_number','academic_session','normalized_roll_no','registration_prefix',
    'programme_code_detected','student_sequence','name','branch','mobile_number','address','department_name','school_name',
    'current_year_of_study','semester','section','admission_type','special_status','parsing_status','status'
], $studentValues,
    "ON DUPLICATE KEY UPDATE programme_id=VALUES(programme_id),enrollment_number=VALUES(enrollment_number),academic_session=VALUES(academic_session),roll_no_original=VALUES(roll_no_original),registration_prefix=VALUES(registration_prefix),programme_code_detected=VALUES(programme_code_detected),student_sequence=VALUES(student_sequence),name=VALUES(name),branch=VALUES(branch),mobile_number=VALUES(mobile_number),address=VALUES(address),department_name=VALUES(department_name),school_name=VALUES(school_name),current_year_of_study=VALUES(current_year_of_study),semester=VALUES(semester),section=VALUES(section),admission_type=VALUES(admission_type),parsing_status='verified',status='active'", 100);

$facultyValues = [];
foreach ($facultyRows as $row) {
    $facultyValues[] = '(' . implode(',', [
        "(SELECT id FROM schools WHERE code=" . sqlString(strtoupper($row['School Code'])) . " LIMIT 1)",
        'NULL', sqlString($row['Employee ID']), sqlString($row['Name']), sqlString($row['Designation']),
        sqlString($row['Email']), sqlString($row['Phone']), "'active'", '0'
    ]) . ')';
}
$sql .= chunkedInsert('faculty', ['school_id','department_id','employee_id','name','designation','email','phone','status','duty_count'],
    $facultyValues,
    "ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),designation=VALUES(designation),email=VALUES(email),phone=VALUES(phone),status='active'", 100);

$sql .= "COMMIT;\nSET FOREIGN_KEY_CHECKS = 1;\n\n";
$sql .= "-- Import verification\n";
$sql .= "SELECT COUNT(*) AS demo_students FROM students WHERE normalized_roll_no REGEXP '^[0-9]{3}[A-Z]{3}[0-9]{3}$';\n";
$sql .= "SELECT COUNT(*) AS demo_faculty FROM faculty WHERE employee_id LIKE 'GBU-LARGE-F%';\n";
$sql .= "SELECT COUNT(*) AS ucs_curriculum_mappings FROM programme_courses pc JOIN programmes p ON p.id=pc.programme_id WHERE p.code='UCS';\n";

file_put_contents($output, $sql);
fwrite(STDOUT, "Created {$output}\nStudents: " . count($studentRows) . "\nFaculty: " . count($facultyRows) . "\nCurriculum rows: " . count($courseRows) . "\n");

