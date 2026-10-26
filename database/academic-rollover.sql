-- Additive, repeatable upgrade. Does not recreate existing application tables.
CREATE TABLE IF NOT EXISTS academic_rollover_settings (
  id TINYINT UNSIGNED PRIMARY KEY,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  session_start CHAR(5) NOT NULL DEFAULT '07-01',
  even_start CHAR(5) NOT NULL DEFAULT '01-01',
  last_checked DATE NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
INSERT IGNORE INTO academic_rollover_settings(id,enabled,session_start,even_start)
VALUES(1,1,'07-01','01-01');

CREATE TABLE IF NOT EXISTS academic_rollover_runs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  effective_date DATE NOT NULL,
  academic_session VARCHAR(9) NOT NULL,
  trigger_source VARCHAR(30) NOT NULL,
  actor_id BIGINT UNSIGNED NULL,
  summary JSON NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_rollover_date(effective_date),
  CONSTRAINT fk_rollover_actor FOREIGN KEY(actor_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS student_progression_controls (
  student_id BIGINT UNSIGNED PRIMARY KEY,
  mode ENUM('automatic','hold','withdrawn','completed') NOT NULL DEFAULT 'automatic',
  semester_delay TINYINT UNSIGNED NOT NULL DEFAULT 0,
  reason VARCHAR(500) NOT NULL DEFAULT '',
  updated_by BIGINT UNSIGNED NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_progression_student FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
  CONSTRAINT fk_progression_actor FOREIGN KEY(updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS student_term_enrollments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT UNSIGNED NOT NULL,
  programme_id BIGINT UNSIGNED NOT NULL,
  batch_id BIGINT UNSIGNED NOT NULL,
  academic_session VARCHAR(9) NOT NULL,
  term TINYINT UNSIGNED NOT NULL,
  study_year TINYINT UNSIGNED NOT NULL,
  semester TINYINT UNSIGNED NOT NULL,
  section VARCHAR(20) NULL,
  placement_status ENUM('active','held','awaiting_completion','withdrawn','completed','not_started') NOT NULL,
  effective_date DATE NOT NULL,
  UNIQUE KEY uq_student_period(student_id,academic_session,term),
  KEY idx_term_cohort(academic_session,term,programme_id,batch_id,semester,placement_status),
  CONSTRAINT fk_term_student FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
  CONSTRAINT fk_term_programme FOREIGN KEY(programme_id) REFERENCES programmes(id),
  CONSTRAINT fk_term_batch FOREIGN KEY(batch_id) REFERENCES batches(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS student_course_registrations (
  -- The legacy source name 'core' marks required cohort assignments, including
  -- department electives selected in a regular date sheet. Course category
  -- remains on programme_courses; unscheduled elective alternatives are not assigned.
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  enrollment_id BIGINT UNSIGNED NOT NULL,
  programme_course_id BIGINT UNSIGNED NOT NULL,
  source ENUM('core','manual') NOT NULL DEFAULT 'core',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_term_course(enrollment_id,programme_course_id),
  CONSTRAINT fk_registration_term FOREIGN KEY(enrollment_id) REFERENCES student_term_enrollments(id) ON DELETE CASCADE,
  CONSTRAINT fk_registration_curriculum FOREIGN KEY(programme_course_id) REFERENCES programme_courses(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS student_academic_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT UNSIGNED NOT NULL,
  run_id BIGINT UNSIGNED NULL,
  action VARCHAR(40) NOT NULL,
  old_values JSON NULL,
  new_values JSON NOT NULL,
  reason VARCHAR(500) NOT NULL,
  actor_id BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_academic_history(student_id,id),
  CONSTRAINT fk_academic_history_student FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
  CONSTRAINT fk_academic_history_run FOREIGN KEY(run_id) REFERENCES academic_rollover_runs(id) ON DELETE SET NULL,
  CONSTRAINT fk_academic_history_actor FOREIGN KEY(actor_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;
