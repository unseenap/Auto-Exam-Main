<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));require BASE_PATH.'/app/Auth/RolePolicy.php';
use App\Auth\RolePolicy;
$cases=[['admin','users.manage',true],['examination_controller','exams.manage',true],['examination_controller','academic.manage',false],['academic_coordinator','students.manage',true],['academic_coordinator','seating.manage',false],['seating_coordinator','rooms.manage',true],['seating_coordinator','invigilation.manage',false],['invigilation_coordinator','faculty.manage',true],['auditor','audit.view',true],['viewer','audit.view',false],['faculty','dashboard.view',true],['faculty','reports.view',false]];foreach($cases as [$role,$permission,$expected])assert(RolePolicy::allows($role,$permission)===$expected,"{$role} / {$permission}");assert(count(RolePolicy::definitions())===8);echo 'Role policy: '.count($cases)." permission checks passed.\n";
