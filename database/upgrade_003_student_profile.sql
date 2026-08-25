USE gbu_exam_operations;
ALTER TABLE students
 ADD COLUMN IF NOT EXISTS enrollment_number VARCHAR(100) NULL AFTER roll_no_original,
 ADD COLUMN IF NOT EXISTS academic_session VARCHAR(9) NOT NULL DEFAULT '2025-2026' AFTER enrollment_number,
 ADD COLUMN IF NOT EXISTS branch VARCHAR(190) NOT NULL DEFAULT 'Unspecified' AFTER name,
 ADD COLUMN IF NOT EXISTS mobile_number VARCHAR(20) NULL AFTER branch,
 ADD COLUMN IF NOT EXISTS address TEXT NULL AFTER mobile_number,
 ADD COLUMN IF NOT EXISTS department_name VARCHAR(190) NOT NULL DEFAULT 'Unspecified' AFTER address,
 ADD COLUMN IF NOT EXISTS school_name VARCHAR(190) NOT NULL DEFAULT 'Unspecified' AFTER department_name,
 ADD COLUMN IF NOT EXISTS current_year_of_study TINYINT UNSIGNED NOT NULL DEFAULT 1 AFTER school_name,
 ADD INDEX IF NOT EXISTS idx_students_enrollment_number (enrollment_number),
 ADD INDEX IF NOT EXISTS idx_students_academic_session (academic_session);
