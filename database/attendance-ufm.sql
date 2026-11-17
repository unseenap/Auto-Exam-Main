CREATE TABLE IF NOT EXISTS attendance_ufm (
 attendance_id BIGINT UNSIGNED PRIMARY KEY,
 first_copy_serial VARCHAR(64) NOT NULL DEFAULT '',
 second_copy_serial VARCHAR(64) NOT NULL DEFAULT '',
 CONSTRAINT fk_ufm_attendance FOREIGN KEY(attendance_id) REFERENCES attendance(id) ON DELETE CASCADE
) ENGINE=InnoDB;
