CREATE DATABASE IF NOT EXISTS gbu_exam_operations
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gbu_exam_operations;

CREATE TABLE roles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(40) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id BIGINT UNSIGNED NOT NULL,
  username VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(190) NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  status ENUM('active','inactive','locked') NOT NULL DEFAULT 'active',
  last_login_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB;

CREATE TABLE schools (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(190) NOT NULL,
  short_name VARCHAR(80) NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE departments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(30) NOT NULL,
  name VARCHAR(190) NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  UNIQUE KEY uq_department_school_code (school_id, code),
  CONSTRAINT fk_departments_school FOREIGN KEY (school_id) REFERENCES schools(id)
) ENGINE=InnoDB;

CREATE TABLE programmes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(190) NOT NULL,
  level ENUM('undergraduate','postgraduate','integrated','doctoral','diploma','other') NOT NULL,
  duration_semesters TINYINT UNSIGNED NULL,
  lateral_entry TINYINT(1) NOT NULL DEFAULT 0,
  legacy TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('active','inactive','unverified') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_programmes_school FOREIGN KEY (school_id) REFERENCES schools(id),
  CONSTRAINT fk_programmes_department FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE batches (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  programme_id BIGINT UNSIGNED NOT NULL,
  label VARCHAR(80) NOT NULL,
  start_year SMALLINT UNSIGNED NULL,
  end_year SMALLINT UNSIGNED NULL,
  status ENUM('active','completed','inactive') NOT NULL DEFAULT 'active',
  UNIQUE KEY uq_batch_programme_label (programme_id, label),
  CONSTRAINT fk_batches_programme FOREIGN KEY (programme_id) REFERENCES programmes(id)
) ENGINE=InnoDB;

CREATE TABLE courses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(40) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE programme_courses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  programme_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  semester TINYINT UNSIGNED NULL,
  category ENUM('core','elective','bridge','common','back_paper','other') NOT NULL DEFAULT 'core',
  UNIQUE KEY uq_programme_course_semester (programme_id, course_id, semester),
  CONSTRAINT fk_programme_courses_programme FOREIGN KEY (programme_id) REFERENCES programmes(id),
  CONSTRAINT fk_programme_courses_course FOREIGN KEY (course_id) REFERENCES courses(id)
) ENGINE=InnoDB;

CREATE TABLE students (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  programme_id BIGINT UNSIGNED NULL,
  batch_id BIGINT UNSIGNED NULL,
  roll_no_original VARCHAR(100) NOT NULL,
  enrollment_number VARCHAR(100) NULL,
  academic_session VARCHAR(9) NOT NULL,
  normalized_roll_no VARCHAR(100) NOT NULL UNIQUE,
  registration_prefix VARCHAR(30) NULL,
  programme_code_detected VARCHAR(30) NULL,
  student_sequence VARCHAR(30) NULL,
  name VARCHAR(190) NOT NULL,
  branch VARCHAR(190) NOT NULL,
  mobile_number VARCHAR(20) NULL,
  address TEXT NULL,
  department_name VARCHAR(190) NOT NULL,
  school_name VARCHAR(190) NOT NULL,
  current_year_of_study TINYINT UNSIGNED NOT NULL,
  semester TINYINT UNSIGNED NULL,
  section VARCHAR(20) NULL,
  admission_type ENUM('regular','lateral','integrated','legacy','unknown') NOT NULL DEFAULT 'regular',
  special_status ENUM('none','repeat','back_paper','special','pass_out','not_promoted','unverified') NOT NULL DEFAULT 'none',
  parsing_status ENUM('verified','review','invalid') NOT NULL DEFAULT 'review',
  status ENUM('active','inactive','completed') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_students_filters (programme_id, batch_id, semester, section),
  KEY idx_students_original_roll (roll_no_original),
  CONSTRAINT fk_students_programme FOREIGN KEY (programme_id) REFERENCES programmes(id),
  CONSTRAINT fk_students_batch FOREIGN KEY (batch_id) REFERENCES batches(id)
) ENGINE=InnoDB;

CREATE TABLE faculty (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  employee_id VARCHAR(60) NOT NULL UNIQUE,
  name VARCHAR(190) NOT NULL,
  designation VARCHAR(120) NULL,
  email VARCHAR(190) NULL,
  phone VARCHAR(30) NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  duty_count INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_faculty_school FOREIGN KEY (school_id) REFERENCES schools(id),
  CONSTRAINT fk_faculty_department FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE rooms (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(60) NOT NULL UNIQUE,
  building VARCHAR(120) NOT NULL,
  floor VARCHAR(60) NULL,
  rows_count SMALLINT UNSIGNED NOT NULL,
  columns_count SMALLINT UNSIGNED NOT NULL,
  physical_capacity SMALLINT UNSIGNED NOT NULL,
  usable_capacity SMALLINT UNSIGNED NOT NULL,
  seat_order ENUM('row_major','column_major','custom') NOT NULL DEFAULT 'column_major',
  priority SMALLINT UNSIGNED NOT NULL DEFAULT 100,
  status ENUM('active','inactive','maintenance') NOT NULL DEFAULT 'active',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CHECK (usable_capacity <= physical_capacity)
) ENGINE=InnoDB;

CREATE TABLE room_seats (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  room_id BIGINT UNSIGNED NOT NULL,
  seat_label VARCHAR(60) NOT NULL,
  row_no SMALLINT UNSIGNED NOT NULL,
  column_no SMALLINT UNSIGNED NOT NULL,
  desk_group VARCHAR(40) NULL,
  desk_position SMALLINT UNSIGNED NULL,
  sequence_no SMALLINT UNSIGNED NOT NULL,
  is_blocked TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_room_seat_label (room_id, seat_label),
  UNIQUE KEY uq_room_coordinate (room_id, row_no, column_no),
  CONSTRAINT fk_room_seats_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE exam_cycles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(190) NOT NULL,
  academic_year VARCHAR(20) NOT NULL,
  exam_type ENUM('mid_sem','end_sem','regular','repeat','back_paper','special_back_paper','pass_out_special','not_promoted_special','doctoral','other') NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  default_duration_minutes SMALLINT UNSIGNED NOT NULL,
  status ENUM('draft','published','closed','archived') NOT NULL DEFAULT 'draft',
  version_no INT UNSIGNED NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED NOT NULL,
  published_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_exam_cycles_user FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE exam_shifts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cycle_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(80) NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_minutes SMALLINT UNSIGNED NOT NULL,
  sequence_no TINYINT UNSIGNED NOT NULL,
  UNIQUE KEY uq_cycle_shift_sequence (cycle_id, sequence_no),
  CONSTRAINT fk_exam_shifts_cycle FOREIGN KEY (cycle_id) REFERENCES exam_cycles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE exam_calendar_dates (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cycle_id BIGINT UNSIGNED NOT NULL,
  exam_date DATE NOT NULL,
  is_exam_day TINYINT(1) NOT NULL DEFAULT 1,
  note VARCHAR(255) NULL,
  UNIQUE KEY uq_cycle_calendar_date (cycle_id, exam_date),
  CONSTRAINT fk_calendar_cycle FOREIGN KEY (cycle_id) REFERENCES exam_cycles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE examinations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cycle_id BIGINT UNSIGNED NOT NULL,
  shift_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  exam_date DATE NOT NULL,
  category ENUM('regular','repeat','back_paper','special','pass_out','not_promoted') NOT NULL DEFAULT 'regular',
  status ENUM('draft','published','completed','cancelled') NOT NULL DEFAULT 'draft',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_exam_cycle_course_slot (cycle_id, course_id, exam_date, shift_id, category),
  KEY idx_examinations_session (exam_date, shift_id, status),
  CONSTRAINT fk_examinations_cycle FOREIGN KEY (cycle_id) REFERENCES exam_cycles(id),
  CONSTRAINT fk_examinations_shift FOREIGN KEY (shift_id) REFERENCES exam_shifts(id),
  CONSTRAINT fk_examinations_course FOREIGN KEY (course_id) REFERENCES courses(id)
) ENGINE=InnoDB;

CREATE TABLE examination_cohorts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  examination_id BIGINT UNSIGNED NOT NULL,
  programme_id BIGINT UNSIGNED NOT NULL,
  batch_id BIGINT UNSIGNED NULL,
  semester TINYINT UNSIGNED NULL,
  display_label VARCHAR(255) NULL,
  UNIQUE KEY uq_exam_cohort (examination_id, programme_id, batch_id, semester),
  CONSTRAINT fk_exam_cohorts_exam FOREIGN KEY (examination_id) REFERENCES examinations(id) ON DELETE CASCADE,
  CONSTRAINT fk_exam_cohorts_programme FOREIGN KEY (programme_id) REFERENCES programmes(id),
  CONSTRAINT fk_exam_cohorts_batch FOREIGN KEY (batch_id) REFERENCES batches(id)
) ENGINE=InnoDB;

CREATE TABLE exam_eligibility (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  examination_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  eligibility_status ENUM('eligible','ineligible','pending','withdrawn') NOT NULL DEFAULT 'eligible',
  source ENUM('cohort','import','manual','registration') NOT NULL DEFAULT 'cohort',
  UNIQUE KEY uq_exam_student_eligibility (examination_id, student_id),
  CONSTRAINT fk_eligibility_exam FOREIGN KEY (examination_id) REFERENCES examinations(id) ON DELETE CASCADE,
  CONSTRAINT fk_eligibility_student FOREIGN KEY (student_id) REFERENCES students(id)
) ENGINE=InnoDB;

CREATE TABLE seating_allocations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cycle_id BIGINT UNSIGNED NOT NULL,
  exam_date DATE NOT NULL,
  shift_id BIGINT UNSIGNED NOT NULL,
  version_no INT UNSIGNED NOT NULL,
  seed_value VARCHAR(100) NOT NULL,
  rule_profile JSON NOT NULL,
  status ENUM('draft','validated','published','superseded','archived') NOT NULL DEFAULT 'draft',
  generated_by BIGINT UNSIGNED NOT NULL,
  generated_at DATETIME NOT NULL,
  published_at DATETIME NULL,
  UNIQUE KEY uq_allocation_session_version (cycle_id, exam_date, shift_id, version_no),
  CONSTRAINT fk_allocations_cycle FOREIGN KEY (cycle_id) REFERENCES exam_cycles(id),
  CONSTRAINT fk_allocations_shift FOREIGN KEY (shift_id) REFERENCES exam_shifts(id),
  CONSTRAINT fk_allocations_user FOREIGN KEY (generated_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE seating_assignments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  allocation_id BIGINT UNSIGNED NOT NULL,
  examination_id BIGINT UNSIGNED NOT NULL,
  room_id BIGINT UNSIGNED NOT NULL,
  seat_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  is_manual_override TINYINT(1) NOT NULL DEFAULT 0,
  override_reason VARCHAR(255) NULL,
  UNIQUE KEY uq_allocation_student (allocation_id, student_id),
  UNIQUE KEY uq_allocation_seat (allocation_id, room_id, seat_id),
  CONSTRAINT fk_assignments_allocation FOREIGN KEY (allocation_id) REFERENCES seating_allocations(id) ON DELETE CASCADE,
  CONSTRAINT fk_assignments_exam FOREIGN KEY (examination_id) REFERENCES examinations(id),
  CONSTRAINT fk_assignments_room FOREIGN KEY (room_id) REFERENCES rooms(id),
  CONSTRAINT fk_assignments_seat FOREIGN KEY (seat_id) REFERENCES room_seats(id),
  CONSTRAINT fk_assignments_student FOREIGN KEY (student_id) REFERENCES students(id)
) ENGINE=InnoDB;

CREATE TABLE seating_unallocated (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  allocation_id BIGINT UNSIGNED NOT NULL,
  examination_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  reason VARCHAR(120) NOT NULL DEFAULT 'insufficient_capacity',
  resolved_at DATETIME NULL,
  UNIQUE KEY uq_unallocated_student (allocation_id, student_id),
  CONSTRAINT fk_unallocated_allocation FOREIGN KEY (allocation_id) REFERENCES seating_allocations(id) ON DELETE CASCADE,
  CONSTRAINT fk_unallocated_exam FOREIGN KEY (examination_id) REFERENCES examinations(id),
  CONSTRAINT fk_unallocated_student FOREIGN KEY (student_id) REFERENCES students(id)
) ENGINE=InnoDB;

CREATE TABLE faculty_availability (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  faculty_id BIGINT UNSIGNED NOT NULL,
  exam_date DATE NOT NULL,
  shift_id BIGINT UNSIGNED NOT NULL,
  availability ENUM('available','unavailable','preferred') NOT NULL DEFAULT 'available',
  reason VARCHAR(255) NULL,
  UNIQUE KEY uq_faculty_session_availability (faculty_id, exam_date, shift_id),
  CONSTRAINT fk_availability_faculty FOREIGN KEY (faculty_id) REFERENCES faculty(id),
  CONSTRAINT fk_availability_shift FOREIGN KEY (shift_id) REFERENCES exam_shifts(id)
) ENGINE=InnoDB;

CREATE TABLE invigilation_allocations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cycle_id BIGINT UNSIGNED NOT NULL,
  exam_date DATE NOT NULL,
  shift_id BIGINT UNSIGNED NOT NULL,
  room_id BIGINT UNSIGNED NOT NULL,
  faculty_id BIGINT UNSIGNED NOT NULL,
  duty_role ENUM('invigilator','senior_invigilator','reliever','observer') NOT NULL DEFAULT 'invigilator',
  duty_status ENUM('assigned','confirmed','replaced','completed','cancelled') NOT NULL DEFAULT 'assigned',
  assigned_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_faculty_session_duty (faculty_id, exam_date, shift_id),
  UNIQUE KEY uq_room_faculty_session (room_id, faculty_id, exam_date, shift_id),
  CONSTRAINT fk_duties_cycle FOREIGN KEY (cycle_id) REFERENCES exam_cycles(id),
  CONSTRAINT fk_duties_shift FOREIGN KEY (shift_id) REFERENCES exam_shifts(id),
  CONSTRAINT fk_duties_room FOREIGN KEY (room_id) REFERENCES rooms(id),
  CONSTRAINT fk_duties_faculty FOREIGN KEY (faculty_id) REFERENCES faculty(id),
  CONSTRAINT fk_duties_user FOREIGN KEY (assigned_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE attendance (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  allocation_id BIGINT UNSIGNED NOT NULL,
  examination_id BIGINT UNSIGNED NOT NULL,
  room_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  status ENUM('unmarked','present','absent','unfair_means','withheld','other') NOT NULL DEFAULT 'unmarked',
  remarks VARCHAR(255) NULL,
  marked_by BIGINT UNSIGNED NULL,
  marked_at DATETIME NULL,
  corrected_by BIGINT UNSIGNED NULL,
  corrected_at DATETIME NULL,
  UNIQUE KEY uq_attendance_exam_student (examination_id, student_id),
  CONSTRAINT fk_attendance_allocation FOREIGN KEY (allocation_id) REFERENCES seating_allocations(id),
  CONSTRAINT fk_attendance_exam FOREIGN KEY (examination_id) REFERENCES examinations(id),
  CONSTRAINT fk_attendance_room FOREIGN KEY (room_id) REFERENCES rooms(id),
  CONSTRAINT fk_attendance_student FOREIGN KEY (student_id) REFERENCES students(id),
  CONSTRAINT fk_attendance_marker FOREIGN KEY (marked_by) REFERENCES users(id),
  CONSTRAINT fk_attendance_corrector FOREIGN KEY (corrected_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE replacement_requests (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  duty_id BIGINT UNSIGNED NOT NULL,
  requested_by BIGINT UNSIGNED NOT NULL,
  reason TEXT NOT NULL,
  replacement_faculty_id BIGINT UNSIGNED NULL,
  status ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  reviewed_by BIGINT UNSIGNED NULL,
  reviewed_at DATETIME NULL,
  review_note VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_replacements_duty FOREIGN KEY (duty_id) REFERENCES invigilation_allocations(id),
  CONSTRAINT fk_replacements_requester FOREIGN KEY (requested_by) REFERENCES users(id),
  CONSTRAINT fk_replacements_faculty FOREIGN KEY (replacement_faculty_id) REFERENCES faculty(id),
  CONSTRAINT fk_replacements_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE import_batches (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  import_type ENUM('students','faculty','rooms','courses','date_sheet','eligibility') NOT NULL,
  original_filename VARCHAR(255) NOT NULL,
  stored_filename VARCHAR(255) NOT NULL,
  status ENUM('uploaded','validating','review','committed','failed','cancelled') NOT NULL DEFAULT 'uploaded',
  total_rows INT UNSIGNED NOT NULL DEFAULT 0,
  valid_rows INT UNSIGNED NOT NULL DEFAULT 0,
  invalid_rows INT UNSIGNED NOT NULL DEFAULT 0,
  uploaded_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  committed_at DATETIME NULL,
  CONSTRAINT fk_imports_user FOREIGN KEY (uploaded_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE import_errors (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  import_batch_id BIGINT UNSIGNED NOT NULL,
  sheet_name VARCHAR(190) NULL,
  source_row_number INT UNSIGNED NULL,
  column_reference VARCHAR(30) NULL,
  source_value TEXT NULL,
  error_code VARCHAR(80) NOT NULL,
  message VARCHAR(255) NOT NULL,
  CONSTRAINT fk_import_errors_batch FOREIGN KEY (import_batch_id) REFERENCES import_batches(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE import_rows (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  import_batch_id BIGINT UNSIGNED NOT NULL,
  source_row_number INT UNSIGNED NOT NULL,
  source_data JSON NOT NULL,
  normalized_data JSON NULL,
  validation_status ENUM('valid','invalid','warning') NOT NULL,
  validation_messages JSON NULL,
  committed_entity_id BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_import_batch_row (import_batch_id, source_row_number),
  CONSTRAINT fk_import_rows_batch FOREIGN KEY (import_batch_id) REFERENCES import_batches(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id BIGINT UNSIGNED NULL,
  old_values JSON NULL,
  new_values JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_audit_entity (entity_type, entity_id),
  KEY idx_audit_user_date (user_id, created_at),
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE system_settings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(120) NOT NULL UNIQUE,
  setting_value TEXT NULL,
  value_type ENUM('string','integer','boolean','json') NOT NULL DEFAULT 'string',
  updated_by BIGINT UNSIGNED NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_settings_user FOREIGN KEY (updated_by) REFERENCES users(id)
) ENGINE=InnoDB;
