<?php

declare(strict_types=1);

namespace App\Auth;

final class RolePolicy
{
    private const PERMISSIONS = [
        'admin' => ['*'],
        'examination_controller' => ['dashboard.view','exams.manage','seating.manage','attendance.manage','reports.view'],
        'academic_coordinator' => ['dashboard.view','academic.manage','students.manage','reports.view'],
        'seating_coordinator' => ['dashboard.view','rooms.manage','seating.manage','reports.view'],
        'invigilation_coordinator' => ['dashboard.view','faculty.manage','invigilation.manage','attendance.manage','reports.view'],
        'faculty' => ['dashboard.view'],
        'auditor' => ['dashboard.view','reports.view','audit.view'],
        'viewer' => ['dashboard.view','reports.view'],
    ];

    public static function allows(string $role,string $permission):bool
    {
        $grants=self::PERMISSIONS[$role]??[];return in_array('*',$grants,true)||in_array($permission,$grants,true);
    }

    public static function definitions():array
    {
        return [
            'admin'=>['name'=>'System Administrator','description'=>'Full system configuration, user access, masters, operations, and audit control.'],
            'examination_controller'=>['name'=>'Controller of Examinations','description'=>'Exam cycles, date sheets, seating publication, attendance, and operational reports.'],
            'academic_coordinator'=>['name'=>'Academic Coordinator','description'=>'Schools, programmes, curriculum, and student records.'],
            'seating_coordinator'=>['name'=>'Seating Coordinator','description'=>'Room layouts, seat availability, seating generation, and seating reports.'],
            'invigilation_coordinator'=>['name'=>'Invigilation Coordinator','description'=>'Faculty records, invigilation allocation, replacements, and attendance operations.'],
            'faculty'=>['name'=>'Faculty / Invigilator','description'=>'Authenticated faculty access with a restricted personal dashboard.'],
            'auditor'=>['name'=>'Audit and Compliance Viewer','description'=>'Read-only reports and complete audit history.'],
            'viewer'=>['name'=>'Authorized Read-only Viewer','description'=>'Read-only dashboard and published operational reports.'],
        ];
    }

    public static function permissionLabels():array
    {
        return ['dashboard.view'=>'Dashboard','academic.manage'=>'Academic masters','students.manage'=>'Students','faculty.manage'=>'Faculty','rooms.manage'=>'Rooms','exams.manage'=>'Exam cycles and date sheets','seating.manage'=>'Seating','attendance.manage'=>'Attendance','invigilation.manage'=>'Invigilation','reports.view'=>'Reports','audit.view'=>'Audit logs','users.manage'=>'Users and roles'];
    }

    public static function grants(string $role):array
    {
        if($role==='admin')return array_keys(self::permissionLabels());return self::PERMISSIONS[$role]??[];
    }
}
