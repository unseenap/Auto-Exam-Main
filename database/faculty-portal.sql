CREATE TABLE IF NOT EXISTS faculty_user_links (
 user_id BIGINT UNSIGNED PRIMARY KEY,
 faculty_id BIGINT UNSIGNED NOT NULL UNIQUE,
 CONSTRAINT fk_fp_link_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 CONSTRAINT fk_fp_link_faculty FOREIGN KEY(faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS faculty_duty_acknowledgments (
 duty_id BIGINT UNSIGNED NOT NULL,
 faculty_id BIGINT UNSIGNED NOT NULL,
 acknowledged_at DATETIME NOT NULL,
 PRIMARY KEY(duty_id,faculty_id),
 CONSTRAINT fk_fp_ack_duty FOREIGN KEY(duty_id) REFERENCES invigilation_allocations(id) ON DELETE CASCADE,
 CONSTRAINT fk_fp_ack_faculty FOREIGN KEY(faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS faculty_room_sessions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 allocation_id BIGINT UNSIGNED NOT NULL,
 room_id BIGINT UNSIGNED NOT NULL,
 revision INT UNSIGNED NOT NULL DEFAULT 0,
 status ENUM('draft','submitted') NOT NULL DEFAULT 'draft',
 submitted_by BIGINT UNSIGNED NULL,
 submitted_at DATETIME NULL,
 reopened_until DATETIME NULL,
 edited_by BIGINT UNSIGNED NULL,
 edited_at DATETIME NULL,
 closing_report LONGTEXT NULL,
 report_by BIGINT UNSIGNED NULL,
 report_at DATETIME NULL,
 UNIQUE KEY uq_fp_room(allocation_id,room_id),
 CONSTRAINT fk_fp_room_allocation FOREIGN KEY(allocation_id) REFERENCES seating_allocations(id) ON DELETE CASCADE,
 CONSTRAINT fk_fp_room_room FOREIGN KEY(room_id) REFERENCES rooms(id),
 CONSTRAINT fk_fp_room_submit FOREIGN KEY(submitted_by) REFERENCES users(id),
 CONSTRAINT fk_fp_room_edit FOREIGN KEY(edited_by) REFERENCES users(id),
 CONSTRAINT fk_fp_room_report FOREIGN KEY(report_by) REFERENCES users(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS faculty_correction_requests (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 session_id BIGINT UNSIGNED NOT NULL,
 requested_by BIGINT UNSIGNED NOT NULL,
 reason VARCHAR(1000) NOT NULL,
 status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
 created_at DATETIME NOT NULL,
 reviewed_by BIGINT UNSIGNED NULL,
 reviewed_at DATETIME NULL,
 CONSTRAINT fk_fp_correction_room FOREIGN KEY(session_id) REFERENCES faculty_room_sessions(id) ON DELETE CASCADE,
 CONSTRAINT fk_fp_correction_user FOREIGN KEY(requested_by) REFERENCES users(id),
 CONSTRAINT fk_fp_correction_review FOREIGN KEY(reviewed_by) REFERENCES users(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS faculty_availability_requests (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 faculty_id BIGINT UNSIGNED NOT NULL,
 requested_by BIGINT UNSIGNED NOT NULL,
 exam_date DATE NOT NULL,
 shift_id BIGINT UNSIGNED NOT NULL,
 availability ENUM('available','unavailable','preferred') NOT NULL,
 reason VARCHAR(1000) NOT NULL,
 status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
 created_at DATETIME NOT NULL,
 reviewed_by BIGINT UNSIGNED NULL,
 reviewed_at DATETIME NULL,
 CONSTRAINT fk_fp_avail_faculty FOREIGN KEY(faculty_id) REFERENCES faculty(id),
 CONSTRAINT fk_fp_avail_user FOREIGN KEY(requested_by) REFERENCES users(id),
 CONSTRAINT fk_fp_avail_shift FOREIGN KEY(shift_id) REFERENCES exam_shifts(id) ON DELETE CASCADE,
 CONSTRAINT fk_fp_avail_review FOREIGN KEY(reviewed_by) REFERENCES users(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS faculty_portal_settings (
 id TINYINT UNSIGNED PRIMARY KEY,
 reporting_minutes SMALLINT UNSIGNED NOT NULL DEFAULT 30,
 attendance_before_minutes SMALLINT UNSIGNED NOT NULL DEFAULT 30,
 attendance_after_minutes SMALLINT UNSIGNED NOT NULL DEFAULT 120
) ENGINE=InnoDB;
INSERT IGNORE INTO faculty_portal_settings(id) VALUES(1);
