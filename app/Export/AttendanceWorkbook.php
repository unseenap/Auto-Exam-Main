<?php

declare(strict_types=1);

namespace App\Export;

use App\Seating\SeatingRoster;
use DateTimeImmutable;
use DateTimeZone;
use PDO;

final class AttendanceWorkbook
{
    public function __construct(private readonly PDO $pdo) {}

    public function build(int $cycleId, ?int $allocationId = null, ?int $roomId = null): string
    {
        (new \App\Faculty\AttendanceOperations($this->pdo))->expire($allocationId,$roomId);
        $period = (new SeatingRoster($this->pdo))->period($cycleId);
        $query = $this->pdo->prepare("SELECT sa.id AS allocation_id, sa.exam_date, sh.name AS shift_name, ec.academic_year,
            x.room_id, r.code AS room_code, rs.seat_label, e.category, c.code AS course_code, c.name AS course_name,
            p.code AS programme_code, COALESCE(t.semester,s.semester) AS semester,
            s.roll_no_original, s.normalized_roll_no, s.name,
            COALESCE(a.status,'unmarked') AS status, a.remarks, a.marked_at,
            ufm.first_copy_serial, ufm.second_copy_serial, COALESCE(marker.email,mf.email) AS marker_email,
            marker.name AS marked_name,fs.edited_at,editor.name AS edited_name,
            fs.status AS room_status, fs.submitted_at,fs.submitted_by,submitter.name AS submitter_name,
            COALESCE(submitter.email,sf.email) AS submitter_email,
            (SELECT GROUP_CONCAT(f.name ORDER BY f.name SEPARATOR ', ') FROM invigilation_allocations ia
                JOIN faculty f ON f.id=ia.faculty_id WHERE ia.cycle_id=sa.cycle_id AND ia.exam_date=sa.exam_date
                AND ia.shift_id=sa.shift_id AND ia.room_id=x.room_id
                AND ia.duty_status IN ('assigned','confirmed','completed')) AS teachers
            FROM seating_allocations sa
            JOIN exam_cycles ec ON ec.id=sa.cycle_id
            JOIN exam_shifts sh ON sh.id=sa.shift_id
            JOIN seating_assignments x ON x.allocation_id=sa.id
            JOIN examinations e ON e.id=x.examination_id
            JOIN courses c ON c.id=e.course_id
            JOIN rooms r ON r.id=x.room_id
            JOIN room_seats rs ON rs.id=x.seat_id
            JOIN students s ON s.id=x.student_id
            LEFT JOIN student_term_enrollments t ON t.student_id=s.id AND t.academic_session=? AND t.term=?
            JOIN programmes p ON p.id=COALESCE(t.programme_id,s.programme_id)
            LEFT JOIN attendance a ON a.allocation_id=x.allocation_id AND a.examination_id=x.examination_id
                AND a.student_id=x.student_id AND a.room_id=x.room_id
            LEFT JOIN attendance_ufm ufm ON ufm.attendance_id=a.id
            LEFT JOIN faculty_room_sessions fs ON fs.allocation_id=sa.id AND fs.room_id=x.room_id
            LEFT JOIN users marker ON marker.id=a.marked_by
            LEFT JOIN users editor ON editor.id=fs.edited_by
            LEFT JOIN faculty_user_links ml ON ml.user_id=marker.id
            LEFT JOIN faculty mf ON mf.id=ml.faculty_id
            LEFT JOIN users submitter ON submitter.id=fs.submitted_by
            LEFT JOIN faculty_user_links sl ON sl.user_id=submitter.id
            LEFT JOIN faculty sf ON sf.id=sl.faculty_id
            WHERE sa.cycle_id=? AND sa.status='published' AND (? IS NULL OR sa.id=?) AND (? IS NULL OR x.room_id=?)
            ORDER BY sa.exam_date DESC, sh.sequence_no DESC, sa.id, r.code, p.code, semester, c.code, s.normalized_roll_no");
        $query->execute([$period['session'], $period['term'], $cycleId, $allocationId, $allocationId, $roomId, $roomId]);

        $sessions = [];
        $ufmRows = [];
        $masterRows = [];
        $roomRecords = [];
        while ($record = $query->fetch(PDO::FETCH_ASSOC)) {
            $sessions[$record['allocation_id']][] = $record;
            $roomRecords[$record['allocation_id'].'/'.$record['room_id']][]=$record;
            $masterRows[]=[
                $this->date($record['exam_date']),$record['shift_name'],$record['room_code'],$record['seat_label'],
                $record['roll_no_original'],$record['name'],$record['programme_code'],(int)$record['semester'],
                $record['course_code'],$record['course_name'],ucwords(str_replace('_',' ',$record['status'])),
                $record['marked_name'],$this->date($record['marked_at']),$record['remarks'],
                $record['first_copy_serial'],$record['second_copy_serial'],$record['teachers'],
                $this->lockStatus($record),$record['submitted_by']?$record['submitter_name']:($record['room_status']==='submitted'?'Automatic':null),
                $this->date($record['submitted_at']),
            ];
            if ($record['status'] === 'unfair_means') {
                $ufmRows[] = [
                    $this->date($record['marked_at']), $record['marker_email'], $this->category($record),
                    $this->date($record['exam_date']), $this->session($record), $record['room_code'],
                    $record['programme_code'], $record['shift_name'], (int)$record['semester'],
                    $record['course_name'], $record['course_code'], $record['normalized_roll_no'],
                    mb_strtoupper($record['name']), $record['first_copy_serial'], $record['second_copy_serial'], $record['remarks'],
                ];
            }
        }

        $sheets = ['UFMData' => [
            'headers' => ['Timestamp','Email Address','Student Category','Date','Session','Room Number','Program','Shift',
                'Semester','Course Name','Course Code','Roll Number','Name of Student','Serial Number of the First Copy Issued',
                'Serial Number of the Second Copy Issued','UFM Remarks'],
            'widths' => [24,32,17,13,13,14,20,16,12,32,17,23,32,25,25,50],
            'rows' => $ufmRows,
        ]];
        foreach ($sessions as $records) {
            $first = $records[0];
            $date = $this->date($first['exam_date']);
            $letter = strtoupper(substr(trim($first['shift_name']), 0, 1));
            $key = $date->format('d') . (ctype_alpha($letter) ? $letter : 'S');
            if (isset($sheets[$key])) $key .= '_' . $date->format('Ym');
            $base = $key;
            for ($suffix = 2; isset($sheets[$key]); $suffix++) $key = $base . '_' . $suffix;
            [$details, $summary] = $this->shiftRows($records);
            $sheets[$key] = [
                'headers' => ['Timestamp','Email Address','Student Type','Session','Date','Shift','Room Number','Program',
                    'Semester','Course Code','Number of Scheduled Students','Students Present','Students Absent',
                    'Roll Number of Absent Students','Verification Status'],
                'widths' => [24,32,16,13,13,16,14,20,12,17,19,15,15,46,21],
                'rows' => $details,
            ];
            $sheets['Summary_' . $key] = [
                'title' => 'ATTENDANCE SUMMARY ' . $date->format('d/m/Y') . ' (' . $first['shift_name'] . ')',
                'headers' => ['Program','Semester','Course Code','Scheduled','Present','Absent','Total',
                    'Absentee Roll Number','UFMs','Roll Numbers of UFM'],
                'widths' => [24,13,17,13,11,11,11,48,10,37],
                'rows' => $summary,
            ];
        }
        $registerRows=[];
        foreach($roomRecords as $records){
            $first=$records[0];
            [$present,$absent,$ufm,$latest]=$this->totals($records);
            $unmarked=count($records)-$present-count($absent);
            $registerRows[]=[
                $this->date($first['exam_date']),$first['shift_name'],$first['room_code'],$first['teachers'],
                count($records),$present,count($absent),count($ufm),$unmarked,
                $this->lockStatus($first),$first['edited_name']??$latest['marked_name'],
                $this->date($first['edited_at']??$latest['marked_at']),
                $first['submitted_by']?$first['submitter_name']:($first['room_status']==='submitted'?'Automatic':null),
                $this->date($first['submitted_at']),
            ];
        }
        $sheets['Room register']=[
            'headers'=>['Date','Shift','Room','Assigned teachers','Scheduled','Present','Absent','UFM','Unmarked','Lock status','Last updated by','Last updated at','Locked by','Locked at'],
            'widths'=>[14,16,14,40,13,11,11,10,12,22,28,24,28,24],
            'rows'=>$registerRows,
        ];
        $sheets['Master attendance']=[
            'headers'=>['Date','Shift','Room','Seat','Roll number','Student name','Program','Semester','Course code','Course name',
                'Attendance','Marked by','Marked at','Remarks','First answer-book serial','Second answer-book serial',
                'Assigned teachers','Lock status','Locked by','Locked at'],
            'widths'=>[14,16,14,14,23,30,20,12,17,32,18,28,24,45,25,25,40,22,28,24],
            'rows'=>$masterRows,
        ];
        return (new XlsxExporter())->buildRegister('Examination Attendance', $sheets);
    }

    private function lockStatus(array $record): string
    {
        if($record['room_status']!=='submitted')return 'Editable';
        return $record['submitted_by']?'Teacher locked':'Automatically locked';
    }

    private function shiftRows(array $records): array
    {
        $rooms = [];
        $courses = [];
        foreach ($records as $record) {
            $course = json_encode([$record['programme_code'], $record['semester'], $record['course_code']], JSON_THROW_ON_ERROR);
            $room = $record['room_id'] . '/' . $record['category'] . '/' . $course;
            $rooms[$room][] = $record;
            $courses[$course][] = $record;
        }
        ksort($courses, SORT_NATURAL);
        $detail = [];
        foreach ($rooms as $group) {
            $first = $group[0];
            [$present, $absent, , $latest] = $this->totals($group);
            $submitted = $first['room_status'] === 'submitted';
            $complete=$present+count($absent)===count($group);
            $state = $submitted ? $this->lockStatus($first).($complete?'':' · Incomplete') : ($complete?'Marked':'Incomplete');
            $detail[] = [
                $this->date($submitted ? $first['submitted_at'] : $latest['marked_at']),
                $submitted ? $first['submitter_email'] : $latest['marker_email'],
                $this->category($first), $this->session($first), $this->date($first['exam_date']),
                $first['shift_name'], $first['room_code'], $first['programme_code'], (int)$first['semester'],
                $first['course_code'], count($group), $present, count($absent), implode(', ', $absent), $state,
            ];
        }
        $summary = [];
        foreach ($courses as $group) {
            $first = $group[0];
            [$present, $absent, $ufm] = $this->totals($group);
            $summary[] = [
                $first['programme_code'], (int)$first['semester'], $first['course_code'], count($group), $present,
                count($absent), $present + count($absent), implode(', ', $absent), count($ufm), implode(', ', $ufm),
            ];
        }
        return [$detail, $summary];
    }

    private function totals(array $records): array
    {
        $present = 0;
        $absent = [];
        $ufm = [];
        $latest = $records[0];
        foreach ($records as $record) {
            if ($record['status'] === 'absent') $absent[] = $record['roll_no_original'];
            if ($record['status'] === 'unfair_means') $ufm[] = $record['normalized_roll_no'];
            if (!in_array($record['status'], ['absent', 'unmarked'], true)) $present++;
            if ($record['marked_at'] > $latest['marked_at']) $latest = $record;
        }
        return [$present, $absent, $ufm, $latest];
    }

    private function date(?string $value): ?DateTimeImmutable
    {
        // Excel stores local wall-clock values without a time zone.
        return $value ? new DateTimeImmutable($value, new DateTimeZone('UTC')) : null;
    }

    private function session(array $record): string
    {
        return preg_replace('/^(\d{4})-\d{2}(\d{2})$/', '$1-$2', $record['academic_year']);
    }

    private function category(array $record): string
    {
        return ucwords(str_replace('_', ' ', $record['category']));
    }
}
