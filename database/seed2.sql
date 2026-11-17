-- Auto-Exam supplemental seed for an existing InfinityFree database.
-- Select the database in phpMyAdmin and import after the current schema and seed.sql.
-- Includes fictional demo students, faculty, rooms, and an August/September 2026 draft cycle.
-- Existing records with matching keys are preserved. No production backup data is included.
-- If admin is missing, its password comes from the separately delivered Admin-Reset ZIP.
SET NAMES utf8mb4;


CREATE TABLE IF NOT EXISTS attendance_ufm (
 attendance_id BIGINT UNSIGNED PRIMARY KEY,
 first_copy_serial VARCHAR(64) NOT NULL DEFAULT '',
 second_copy_serial VARCHAR(64) NOT NULL DEFAULT '',
 CONSTRAINT fk_ufm_attendance FOREIGN KEY(attendance_id) REFERENCES attendance(id) ON DELETE CASCADE
) ENGINE=InnoDB;

START TRANSACTION;

-- Create the administrator only when the baseline has no admin username.
INSERT INTO users (role_id, username, name, password_hash, status)
SELECT r.id, 'admin', 'Examination Cell Administrator', '$2y$10$h58UFw7v00GgRzU4hQCbLOOA9bSRVJ37g/6RD9VPBgnpfBv5yxE12', 'active'
FROM roles r WHERE r.code = 'admin' AND NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin');


-- Add lateral-entry cohorts to the corresponding regular programmes.

INSERT INTO batches (programme_id, label, start_year, end_year, status)
SELECT p.id, CONCAT(p.code, ' 2022-', 2022 + CEIL(p.duration_semesters / 2)), 2022, 2022 + CEIL(p.duration_semesters / 2), 'active'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NULL
ON DUPLICATE KEY UPDATE id = batches.id;

INSERT INTO batches (programme_id, label, start_year, end_year, status)
SELECT p.id, CONCAT(p.code, ' 2022-', 2022 + CEIL(p.duration_semesters / 2)), 2022, 2022 + CEIL(p.duration_semesters / 2), 'active'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NULL
ON DUPLICATE KEY UPDATE id = batches.id;

INSERT INTO batches (programme_id, label, start_year, end_year, status)
SELECT p.id, CONCAT(p.code, ' 2022-', 2022 + CEIL(p.duration_semesters / 2)), 2022, 2022 + CEIL(p.duration_semesters / 2), 'active'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NULL
ON DUPLICATE KEY UPDATE id = batches.id;

-- Add the missing demo students and faculty by their source identifiers.

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS001', '2300100001', '2026-2027', '235ICS001', '235', 'ICS', '001', 'Aarav Yadav', 'Integrated B.Tech Computer Science and Engineering', '9876000001', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS002', '2300100002', '2026-2027', '235ICS002', '235', 'ICS', '002', 'Aditi Tiwari', 'Integrated B.Tech Computer Science and Engineering', '9876000002', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS003', '2300100003', '2026-2027', '235ICS003', '235', 'ICS', '003', 'Advik Khan', 'Integrated B.Tech Computer Science and Engineering', '9876000003', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS004', '2300100004', '2026-2027', '235ICS004', '235', 'ICS', '004', 'Ananya Kumar', 'Integrated B.Tech Computer Science and Engineering', '9876000004', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS005', '2300100005', '2026-2027', '235ICS005', '235', 'ICS', '005', 'Arjun Kapoor', 'Integrated B.Tech Computer Science and Engineering', '9876000005', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS006', '2300100006', '2026-2027', '235ICS006', '235', 'ICS', '006', 'Avni Saini', 'Integrated B.Tech Computer Science and Engineering', '9876000006', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS007', '2300100007', '2026-2027', '235ICS007', '235', 'ICS', '007', 'Dev Verma', 'Integrated B.Tech Computer Science and Engineering', '9876000007', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS008', '2300100008', '2026-2027', '235ICS008', '235', 'ICS', '008', 'Diya Mehta', 'Integrated B.Tech Computer Science and Engineering', '9876000008', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS009', '2300100009', '2026-2027', '235ICS009', '235', 'ICS', '009', 'Ishaan Agarwal', 'Integrated B.Tech Computer Science and Engineering', '9876000009', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS010', '2300100010', '2026-2027', '235ICS010', '235', 'ICS', '010', 'Kavya Srivastava', 'Integrated B.Tech Computer Science and Engineering', '9876000010', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS011', '2300100011', '2026-2027', '235ICS011', '235', 'ICS', '011', 'Krish Mishra', 'Integrated B.Tech Computer Science and Engineering', '9876000011', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS012', '2300100012', '2026-2027', '235ICS012', '235', 'ICS', '012', 'Meera Chauhan', 'Integrated B.Tech Computer Science and Engineering', '9876000012', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS013', '2300100013', '2026-2027', '235ICS013', '235', 'ICS', '013', 'Naksh Arora', 'Integrated B.Tech Computer Science and Engineering', '9876000013', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS014', '2300100014', '2026-2027', '235ICS014', '235', 'ICS', '014', 'Navya Singh', 'Integrated B.Tech Computer Science and Engineering', '9876000014', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS015', '2300100015', '2026-2027', '235ICS015', '235', 'ICS', '015', 'Pranav Joshi', 'Integrated B.Tech Computer Science and Engineering', '9876000015', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS016', '2300100016', '2026-2027', '235ICS016', '235', 'ICS', '016', 'Riya Jain', 'Integrated B.Tech Computer Science and Engineering', '9876000016', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS017', '2300100017', '2026-2027', '235ICS017', '235', 'ICS', '017', 'Rohan Chandra', 'Integrated B.Tech Computer Science and Engineering', '9876000017', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS018', '2300100018', '2026-2027', '235ICS018', '235', 'ICS', '018', 'Saanvi Patel', 'Integrated B.Tech Computer Science and Engineering', '9876000018', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS019', '2300100019', '2026-2027', '235ICS019', '235', 'ICS', '019', 'Samarth Saxena', 'Integrated B.Tech Computer Science and Engineering', '9876000019', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235ICS020', '2300100020', '2026-2027', '235ICS020', '235', 'ICS', '020', 'Siya Rao', 'Integrated B.Tech Computer Science and Engineering', '9876000020', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC001', '2300100021', '2026-2027', '235IEC001', '235', 'IEC', '001', 'Vedant Gupta', 'Electronics and Communication Engineering', '9876000021', 'Greater Noida Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC002', '2300100022', '2026-2027', '235IEC002', '235', 'IEC', '002', 'Vanya Bansal', 'Electronics and Communication Engineering', '9876000022', 'Noida Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC003', '2300100023', '2026-2027', '235IEC003', '235', 'IEC', '003', 'Vihaan Malhotra', 'Electronics and Communication Engineering', '9876000023', 'Ghaziabad Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC004', '2300100024', '2026-2027', '235IEC004', '235', 'IEC', '004', 'Zara Sharma', 'Electronics and Communication Engineering', '9876000024', 'Delhi', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC005', '2300100025', '2026-2027', '235IEC005', '235', 'IEC', '005', 'Aarav Yadav', 'Electronics and Communication Engineering', '9876000025', 'Meerut Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC006', '2300100026', '2026-2027', '235IEC006', '235', 'IEC', '006', 'Aditi Tiwari', 'Electronics and Communication Engineering', '9876000026', 'Agra Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC007', '2300100027', '2026-2027', '235IEC007', '235', 'IEC', '007', 'Advik Khan', 'Electronics and Communication Engineering', '9876000027', 'Mathura Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC008', '2300100028', '2026-2027', '235IEC008', '235', 'IEC', '008', 'Ananya Kumar', 'Electronics and Communication Engineering', '9876000028', 'Aligarh Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC009', '2300100029', '2026-2027', '235IEC009', '235', 'IEC', '009', 'Arjun Kapoor', 'Electronics and Communication Engineering', '9876000029', 'Hapur Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC010', '2300100030', '2026-2027', '235IEC010', '235', 'IEC', '010', 'Avni Saini', 'Electronics and Communication Engineering', '9876000030', 'Bulandshahr Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'A', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC011', '2300100031', '2026-2027', '235IEC011', '235', 'IEC', '011', 'Dev Verma', 'Electronics and Communication Engineering', '9876000031', 'Greater Noida Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC012', '2300100032', '2026-2027', '235IEC012', '235', 'IEC', '012', 'Diya Mehta', 'Electronics and Communication Engineering', '9876000032', 'Noida Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC013', '2300100033', '2026-2027', '235IEC013', '235', 'IEC', '013', 'Ishaan Agarwal', 'Electronics and Communication Engineering', '9876000033', 'Ghaziabad Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC014', '2300100034', '2026-2027', '235IEC014', '235', 'IEC', '014', 'Kavya Srivastava', 'Electronics and Communication Engineering', '9876000034', 'Delhi', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC015', '2300100035', '2026-2027', '235IEC015', '235', 'IEC', '015', 'Krish Mishra', 'Electronics and Communication Engineering', '9876000035', 'Meerut Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC016', '2300100036', '2026-2027', '235IEC016', '235', 'IEC', '016', 'Meera Chauhan', 'Electronics and Communication Engineering', '9876000036', 'Agra Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC017', '2300100037', '2026-2027', '235IEC017', '235', 'IEC', '017', 'Naksh Arora', 'Electronics and Communication Engineering', '9876000037', 'Mathura Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC018', '2300100038', '2026-2027', '235IEC018', '235', 'IEC', '018', 'Navya Singh', 'Electronics and Communication Engineering', '9876000038', 'Aligarh Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC019', '2300100039', '2026-2027', '235IEC019', '235', 'IEC', '019', 'Pranav Joshi', 'Electronics and Communication Engineering', '9876000039', 'Hapur Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235IEC020', '2300100040', '2026-2027', '235IEC020', '235', 'IEC', '020', 'Riya Jain', 'Electronics and Communication Engineering', '9876000040', 'Bulandshahr Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 3, 5, 'B', 'legacy', 'verified'
FROM programmes p WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS001', '2300100041', '2026-2027', '235LCS001', '235', 'LCS', '001', 'Rohan Chandra', 'Computer Science and Engineering', '9876000041', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS002', '2300100042', '2026-2027', '235LCS002', '235', 'LCS', '002', 'Saanvi Patel', 'Computer Science and Engineering', '9876000042', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS003', '2300100043', '2026-2027', '235LCS003', '235', 'LCS', '003', 'Samarth Saxena', 'Computer Science and Engineering', '9876000043', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS004', '2300100044', '2026-2027', '235LCS004', '235', 'LCS', '004', 'Siya Rao', 'Computer Science and Engineering', '9876000044', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS005', '2300100045', '2026-2027', '235LCS005', '235', 'LCS', '005', 'Vedant Gupta', 'Computer Science and Engineering', '9876000045', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS006', '2300100046', '2026-2027', '235LCS006', '235', 'LCS', '006', 'Vanya Bansal', 'Computer Science and Engineering', '9876000046', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS007', '2300100047', '2026-2027', '235LCS007', '235', 'LCS', '007', 'Vihaan Malhotra', 'Computer Science and Engineering', '9876000047', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS008', '2300100048', '2026-2027', '235LCS008', '235', 'LCS', '008', 'Zara Sharma', 'Computer Science and Engineering', '9876000048', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS009', '2300100049', '2026-2027', '235LCS009', '235', 'LCS', '009', 'Aarav Yadav', 'Computer Science and Engineering', '9876000049', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS010', '2300100050', '2026-2027', '235LCS010', '235', 'LCS', '010', 'Aditi Tiwari', 'Computer Science and Engineering', '9876000050', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS011', '2300100051', '2026-2027', '235LCS011', '235', 'LCS', '011', 'Advik Khan', 'Computer Science and Engineering', '9876000051', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS012', '2300100052', '2026-2027', '235LCS012', '235', 'LCS', '012', 'Ananya Kumar', 'Computer Science and Engineering', '9876000052', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS013', '2300100053', '2026-2027', '235LCS013', '235', 'LCS', '013', 'Arjun Kapoor', 'Computer Science and Engineering', '9876000053', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS014', '2300100054', '2026-2027', '235LCS014', '235', 'LCS', '014', 'Avni Saini', 'Computer Science and Engineering', '9876000054', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS015', '2300100055', '2026-2027', '235LCS015', '235', 'LCS', '015', 'Dev Verma', 'Computer Science and Engineering', '9876000055', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS016', '2300100056', '2026-2027', '235LCS016', '235', 'LCS', '016', 'Diya Mehta', 'Computer Science and Engineering', '9876000056', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS017', '2300100057', '2026-2027', '235LCS017', '235', 'LCS', '017', 'Ishaan Agarwal', 'Computer Science and Engineering', '9876000057', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS018', '2300100058', '2026-2027', '235LCS018', '235', 'LCS', '018', 'Kavya Srivastava', 'Computer Science and Engineering', '9876000058', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS019', '2300100059', '2026-2027', '235LCS019', '235', 'LCS', '019', 'Krish Mishra', 'Computer Science and Engineering', '9876000059', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LCS020', '2300100060', '2026-2027', '235LCS020', '235', 'LCS', '020', 'Meera Chauhan', 'Computer Science and Engineering', '9876000060', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA001', '2300100061', '2026-2027', '235LEA001', '235', 'LEA', '001', 'Naksh Arora', 'Electronics AI and Machine Learning', '9876000061', 'Greater Noida Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA002', '2300100062', '2026-2027', '235LEA002', '235', 'LEA', '002', 'Navya Singh', 'Electronics AI and Machine Learning', '9876000062', 'Noida Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA003', '2300100063', '2026-2027', '235LEA003', '235', 'LEA', '003', 'Pranav Joshi', 'Electronics AI and Machine Learning', '9876000063', 'Ghaziabad Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA004', '2300100064', '2026-2027', '235LEA004', '235', 'LEA', '004', 'Riya Jain', 'Electronics AI and Machine Learning', '9876000064', 'Delhi', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA005', '2300100065', '2026-2027', '235LEA005', '235', 'LEA', '005', 'Rohan Chandra', 'Electronics AI and Machine Learning', '9876000065', 'Meerut Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA006', '2300100066', '2026-2027', '235LEA006', '235', 'LEA', '006', 'Saanvi Patel', 'Electronics AI and Machine Learning', '9876000066', 'Agra Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA007', '2300100067', '2026-2027', '235LEA007', '235', 'LEA', '007', 'Samarth Saxena', 'Electronics AI and Machine Learning', '9876000067', 'Mathura Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA008', '2300100068', '2026-2027', '235LEA008', '235', 'LEA', '008', 'Siya Rao', 'Electronics AI and Machine Learning', '9876000068', 'Aligarh Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA009', '2300100069', '2026-2027', '235LEA009', '235', 'LEA', '009', 'Vedant Gupta', 'Electronics AI and Machine Learning', '9876000069', 'Hapur Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA010', '2300100070', '2026-2027', '235LEA010', '235', 'LEA', '010', 'Vanya Bansal', 'Electronics AI and Machine Learning', '9876000070', 'Bulandshahr Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA011', '2300100071', '2026-2027', '235LEA011', '235', 'LEA', '011', 'Vihaan Malhotra', 'Electronics AI and Machine Learning', '9876000071', 'Greater Noida Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA012', '2300100072', '2026-2027', '235LEA012', '235', 'LEA', '012', 'Zara Sharma', 'Electronics AI and Machine Learning', '9876000072', 'Noida Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA013', '2300100073', '2026-2027', '235LEA013', '235', 'LEA', '013', 'Aarav Yadav', 'Electronics AI and Machine Learning', '9876000073', 'Ghaziabad Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA014', '2300100074', '2026-2027', '235LEA014', '235', 'LEA', '014', 'Aditi Tiwari', 'Electronics AI and Machine Learning', '9876000074', 'Delhi', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA015', '2300100075', '2026-2027', '235LEA015', '235', 'LEA', '015', 'Advik Khan', 'Electronics AI and Machine Learning', '9876000075', 'Meerut Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA016', '2300100076', '2026-2027', '235LEA016', '235', 'LEA', '016', 'Ananya Kumar', 'Electronics AI and Machine Learning', '9876000076', 'Agra Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA017', '2300100077', '2026-2027', '235LEA017', '235', 'LEA', '017', 'Arjun Kapoor', 'Electronics AI and Machine Learning', '9876000077', 'Mathura Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA018', '2300100078', '2026-2027', '235LEA018', '235', 'LEA', '018', 'Avni Saini', 'Electronics AI and Machine Learning', '9876000078', 'Aligarh Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA019', '2300100079', '2026-2027', '235LEA019', '235', 'LEA', '019', 'Dev Verma', 'Electronics AI and Machine Learning', '9876000079', 'Hapur Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LEA020', '2300100080', '2026-2027', '235LEA020', '235', 'LEA', '020', 'Diya Mehta', 'Electronics AI and Machine Learning', '9876000080', 'Bulandshahr Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT001', '2300100081', '2026-2027', '235LIT001', '235', 'LIT', '001', 'Ishaan Agarwal', 'Information Technology', '9876000081', 'Greater Noida Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT002', '2300100082', '2026-2027', '235LIT002', '235', 'LIT', '002', 'Kavya Srivastava', 'Information Technology', '9876000082', 'Noida Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT003', '2300100083', '2026-2027', '235LIT003', '235', 'LIT', '003', 'Krish Mishra', 'Information Technology', '9876000083', 'Ghaziabad Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT004', '2300100084', '2026-2027', '235LIT004', '235', 'LIT', '004', 'Meera Chauhan', 'Information Technology', '9876000084', 'Delhi', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT005', '2300100085', '2026-2027', '235LIT005', '235', 'LIT', '005', 'Naksh Arora', 'Information Technology', '9876000085', 'Meerut Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT006', '2300100086', '2026-2027', '235LIT006', '235', 'LIT', '006', 'Navya Singh', 'Information Technology', '9876000086', 'Agra Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT007', '2300100087', '2026-2027', '235LIT007', '235', 'LIT', '007', 'Pranav Joshi', 'Information Technology', '9876000087', 'Mathura Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT008', '2300100088', '2026-2027', '235LIT008', '235', 'LIT', '008', 'Riya Jain', 'Information Technology', '9876000088', 'Aligarh Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT009', '2300100089', '2026-2027', '235LIT009', '235', 'LIT', '009', 'Rohan Chandra', 'Information Technology', '9876000089', 'Hapur Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT010', '2300100090', '2026-2027', '235LIT010', '235', 'LIT', '010', 'Saanvi Patel', 'Information Technology', '9876000090', 'Bulandshahr Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT011', '2300100091', '2026-2027', '235LIT011', '235', 'LIT', '011', 'Samarth Saxena', 'Information Technology', '9876000091', 'Greater Noida Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT012', '2300100092', '2026-2027', '235LIT012', '235', 'LIT', '012', 'Siya Rao', 'Information Technology', '9876000092', 'Noida Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT013', '2300100093', '2026-2027', '235LIT013', '235', 'LIT', '013', 'Vedant Gupta', 'Information Technology', '9876000093', 'Ghaziabad Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT014', '2300100094', '2026-2027', '235LIT014', '235', 'LIT', '014', 'Vanya Bansal', 'Information Technology', '9876000094', 'Delhi', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT015', '2300100095', '2026-2027', '235LIT015', '235', 'LIT', '015', 'Vihaan Malhotra', 'Information Technology', '9876000095', 'Meerut Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT016', '2300100096', '2026-2027', '235LIT016', '235', 'LIT', '016', 'Zara Sharma', 'Information Technology', '9876000096', 'Agra Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT017', '2300100097', '2026-2027', '235LIT017', '235', 'LIT', '017', 'Aarav Yadav', 'Information Technology', '9876000097', 'Mathura Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT018', '2300100098', '2026-2027', '235LIT018', '235', 'LIT', '018', 'Aditi Tiwari', 'Information Technology', '9876000098', 'Aligarh Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT019', '2300100099', '2026-2027', '235LIT019', '235', 'LIT', '019', 'Advik Khan', 'Information Technology', '9876000099', 'Hapur Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), '235LIT020', '2300100100', '2026-2027', '235LIT020', '235', 'LIT', '020', 'Ananya Kumar', 'Information Technology', '9876000100', 'Bulandshahr Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'lateral', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS001', '2300100101', '2026-2027', '235PCS001', '235', 'PCS', '001', 'Arjun Kapoor', 'Computer Science and Engineering', '9876000101', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS002', '2300100102', '2026-2027', '235PCS002', '235', 'PCS', '002', 'Avni Saini', 'Computer Science and Engineering', '9876000102', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS003', '2300100103', '2026-2027', '235PCS003', '235', 'PCS', '003', 'Dev Verma', 'Computer Science and Engineering', '9876000103', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS004', '2300100104', '2026-2027', '235PCS004', '235', 'PCS', '004', 'Diya Mehta', 'Computer Science and Engineering', '9876000104', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS005', '2300100105', '2026-2027', '235PCS005', '235', 'PCS', '005', 'Ishaan Agarwal', 'Computer Science and Engineering', '9876000105', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS006', '2300100106', '2026-2027', '235PCS006', '235', 'PCS', '006', 'Kavya Srivastava', 'Computer Science and Engineering', '9876000106', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS007', '2300100107', '2026-2027', '235PCS007', '235', 'PCS', '007', 'Krish Mishra', 'Computer Science and Engineering', '9876000107', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS008', '2300100108', '2026-2027', '235PCS008', '235', 'PCS', '008', 'Meera Chauhan', 'Computer Science and Engineering', '9876000108', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS009', '2300100109', '2026-2027', '235PCS009', '235', 'PCS', '009', 'Naksh Arora', 'Computer Science and Engineering', '9876000109', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS010', '2300100110', '2026-2027', '235PCS010', '235', 'PCS', '010', 'Navya Singh', 'Computer Science and Engineering', '9876000110', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS011', '2300100111', '2026-2027', '235PCS011', '235', 'PCS', '011', 'Pranav Joshi', 'Computer Science and Engineering', '9876000111', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS012', '2300100112', '2026-2027', '235PCS012', '235', 'PCS', '012', 'Riya Jain', 'Computer Science and Engineering', '9876000112', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS013', '2300100113', '2026-2027', '235PCS013', '235', 'PCS', '013', 'Rohan Chandra', 'Computer Science and Engineering', '9876000113', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS014', '2300100114', '2026-2027', '235PCS014', '235', 'PCS', '014', 'Saanvi Patel', 'Computer Science and Engineering', '9876000114', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS015', '2300100115', '2026-2027', '235PCS015', '235', 'PCS', '015', 'Samarth Saxena', 'Computer Science and Engineering', '9876000115', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS016', '2300100116', '2026-2027', '235PCS016', '235', 'PCS', '016', 'Siya Rao', 'Computer Science and Engineering', '9876000116', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS017', '2300100117', '2026-2027', '235PCS017', '235', 'PCS', '017', 'Vedant Gupta', 'Computer Science and Engineering', '9876000117', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS018', '2300100118', '2026-2027', '235PCS018', '235', 'PCS', '018', 'Vanya Bansal', 'Computer Science and Engineering', '9876000118', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS019', '2300100119', '2026-2027', '235PCS019', '235', 'PCS', '019', 'Vihaan Malhotra', 'Computer Science and Engineering', '9876000119', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCS020', '2300100120', '2026-2027', '235PCS020', '235', 'PCS', '020', 'Zara Sharma', 'Computer Science and Engineering', '9876000120', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW001', '2300100121', '2026-2027', '235PCW001', '235', 'PCW', '001', 'Aarav Yadav', 'Computer Science and Engineering', '9876000121', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW002', '2300100122', '2026-2027', '235PCW002', '235', 'PCW', '002', 'Aditi Tiwari', 'Computer Science and Engineering', '9876000122', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW003', '2300100123', '2026-2027', '235PCW003', '235', 'PCW', '003', 'Advik Khan', 'Computer Science and Engineering', '9876000123', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW004', '2300100124', '2026-2027', '235PCW004', '235', 'PCW', '004', 'Ananya Kumar', 'Computer Science and Engineering', '9876000124', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW005', '2300100125', '2026-2027', '235PCW005', '235', 'PCW', '005', 'Arjun Kapoor', 'Computer Science and Engineering', '9876000125', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW006', '2300100126', '2026-2027', '235PCW006', '235', 'PCW', '006', 'Avni Saini', 'Computer Science and Engineering', '9876000126', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW007', '2300100127', '2026-2027', '235PCW007', '235', 'PCW', '007', 'Dev Verma', 'Computer Science and Engineering', '9876000127', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW008', '2300100128', '2026-2027', '235PCW008', '235', 'PCW', '008', 'Diya Mehta', 'Computer Science and Engineering', '9876000128', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW009', '2300100129', '2026-2027', '235PCW009', '235', 'PCW', '009', 'Ishaan Agarwal', 'Computer Science and Engineering', '9876000129', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW010', '2300100130', '2026-2027', '235PCW010', '235', 'PCW', '010', 'Kavya Srivastava', 'Computer Science and Engineering', '9876000130', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW011', '2300100131', '2026-2027', '235PCW011', '235', 'PCW', '011', 'Krish Mishra', 'Computer Science and Engineering', '9876000131', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW012', '2300100132', '2026-2027', '235PCW012', '235', 'PCW', '012', 'Meera Chauhan', 'Computer Science and Engineering', '9876000132', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW013', '2300100133', '2026-2027', '235PCW013', '235', 'PCW', '013', 'Naksh Arora', 'Computer Science and Engineering', '9876000133', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW014', '2300100134', '2026-2027', '235PCW014', '235', 'PCW', '014', 'Navya Singh', 'Computer Science and Engineering', '9876000134', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW015', '2300100135', '2026-2027', '235PCW015', '235', 'PCW', '015', 'Pranav Joshi', 'Computer Science and Engineering', '9876000135', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW016', '2300100136', '2026-2027', '235PCW016', '235', 'PCW', '016', 'Riya Jain', 'Computer Science and Engineering', '9876000136', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW017', '2300100137', '2026-2027', '235PCW017', '235', 'PCW', '017', 'Rohan Chandra', 'Computer Science and Engineering', '9876000137', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW018', '2300100138', '2026-2027', '235PCW018', '235', 'PCW', '018', 'Saanvi Patel', 'Computer Science and Engineering', '9876000138', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW019', '2300100139', '2026-2027', '235PCW019', '235', 'PCW', '019', 'Samarth Saxena', 'Computer Science and Engineering', '9876000139', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235PCW020', '2300100140', '2026-2027', '235PCW020', '235', 'PCW', '020', 'Siya Rao', 'Computer Science and Engineering', '9876000140', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 1, 1, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI001', '2300100141', '2026-2027', '235UAI001', '235', 'UAI', '001', 'Vedant Gupta', 'Artificial Intelligence', '9876000141', 'Greater Noida Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI002', '2300100142', '2026-2027', '235UAI002', '235', 'UAI', '002', 'Vanya Bansal', 'Artificial Intelligence', '9876000142', 'Noida Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI003', '2300100143', '2026-2027', '235UAI003', '235', 'UAI', '003', 'Vihaan Malhotra', 'Artificial Intelligence', '9876000143', 'Ghaziabad Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI004', '2300100144', '2026-2027', '235UAI004', '235', 'UAI', '004', 'Zara Sharma', 'Artificial Intelligence', '9876000144', 'Delhi', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI005', '2300100145', '2026-2027', '235UAI005', '235', 'UAI', '005', 'Aarav Yadav', 'Artificial Intelligence', '9876000145', 'Meerut Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI006', '2300100146', '2026-2027', '235UAI006', '235', 'UAI', '006', 'Aditi Tiwari', 'Artificial Intelligence', '9876000146', 'Agra Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI007', '2300100147', '2026-2027', '235UAI007', '235', 'UAI', '007', 'Advik Khan', 'Artificial Intelligence', '9876000147', 'Mathura Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI008', '2300100148', '2026-2027', '235UAI008', '235', 'UAI', '008', 'Ananya Kumar', 'Artificial Intelligence', '9876000148', 'Aligarh Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI009', '2300100149', '2026-2027', '235UAI009', '235', 'UAI', '009', 'Arjun Kapoor', 'Artificial Intelligence', '9876000149', 'Hapur Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI010', '2300100150', '2026-2027', '235UAI010', '235', 'UAI', '010', 'Avni Saini', 'Artificial Intelligence', '9876000150', 'Bulandshahr Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI011', '2300100151', '2026-2027', '235UAI011', '235', 'UAI', '011', 'Dev Verma', 'Artificial Intelligence', '9876000151', 'Greater Noida Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI012', '2300100152', '2026-2027', '235UAI012', '235', 'UAI', '012', 'Diya Mehta', 'Artificial Intelligence', '9876000152', 'Noida Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI013', '2300100153', '2026-2027', '235UAI013', '235', 'UAI', '013', 'Ishaan Agarwal', 'Artificial Intelligence', '9876000153', 'Ghaziabad Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI014', '2300100154', '2026-2027', '235UAI014', '235', 'UAI', '014', 'Kavya Srivastava', 'Artificial Intelligence', '9876000154', 'Delhi', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI015', '2300100155', '2026-2027', '235UAI015', '235', 'UAI', '015', 'Krish Mishra', 'Artificial Intelligence', '9876000155', 'Meerut Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI016', '2300100156', '2026-2027', '235UAI016', '235', 'UAI', '016', 'Meera Chauhan', 'Artificial Intelligence', '9876000156', 'Agra Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI017', '2300100157', '2026-2027', '235UAI017', '235', 'UAI', '017', 'Naksh Arora', 'Artificial Intelligence', '9876000157', 'Mathura Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI018', '2300100158', '2026-2027', '235UAI018', '235', 'UAI', '018', 'Navya Singh', 'Artificial Intelligence', '9876000158', 'Aligarh Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI019', '2300100159', '2026-2027', '235UAI019', '235', 'UAI', '019', 'Pranav Joshi', 'Artificial Intelligence', '9876000159', 'Hapur Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UAI020', '2300100160', '2026-2027', '235UAI020', '235', 'UAI', '020', 'Riya Jain', 'Artificial Intelligence', '9876000160', 'Bulandshahr Uttar Pradesh', 'Artificial Intelligence', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA001', '2300100161', '2026-2027', '235UCA001', '235', 'UCA', '001', 'Rohan Chandra', 'Computer Applications', '9876000161', 'Greater Noida Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA002', '2300100162', '2026-2027', '235UCA002', '235', 'UCA', '002', 'Saanvi Patel', 'Computer Applications', '9876000162', 'Noida Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA003', '2300100163', '2026-2027', '235UCA003', '235', 'UCA', '003', 'Samarth Saxena', 'Computer Applications', '9876000163', 'Ghaziabad Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA004', '2300100164', '2026-2027', '235UCA004', '235', 'UCA', '004', 'Siya Rao', 'Computer Applications', '9876000164', 'Delhi', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA005', '2300100165', '2026-2027', '235UCA005', '235', 'UCA', '005', 'Vedant Gupta', 'Computer Applications', '9876000165', 'Meerut Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA006', '2300100166', '2026-2027', '235UCA006', '235', 'UCA', '006', 'Vanya Bansal', 'Computer Applications', '9876000166', 'Agra Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA007', '2300100167', '2026-2027', '235UCA007', '235', 'UCA', '007', 'Vihaan Malhotra', 'Computer Applications', '9876000167', 'Mathura Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA008', '2300100168', '2026-2027', '235UCA008', '235', 'UCA', '008', 'Zara Sharma', 'Computer Applications', '9876000168', 'Aligarh Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA009', '2300100169', '2026-2027', '235UCA009', '235', 'UCA', '009', 'Aarav Yadav', 'Computer Applications', '9876000169', 'Hapur Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA010', '2300100170', '2026-2027', '235UCA010', '235', 'UCA', '010', 'Aditi Tiwari', 'Computer Applications', '9876000170', 'Bulandshahr Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA011', '2300100171', '2026-2027', '235UCA011', '235', 'UCA', '011', 'Advik Khan', 'Computer Applications', '9876000171', 'Greater Noida Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA012', '2300100172', '2026-2027', '235UCA012', '235', 'UCA', '012', 'Ananya Kumar', 'Computer Applications', '9876000172', 'Noida Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA013', '2300100173', '2026-2027', '235UCA013', '235', 'UCA', '013', 'Arjun Kapoor', 'Computer Applications', '9876000173', 'Ghaziabad Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA014', '2300100174', '2026-2027', '235UCA014', '235', 'UCA', '014', 'Avni Saini', 'Computer Applications', '9876000174', 'Delhi', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA015', '2300100175', '2026-2027', '235UCA015', '235', 'UCA', '015', 'Dev Verma', 'Computer Applications', '9876000175', 'Meerut Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA016', '2300100176', '2026-2027', '235UCA016', '235', 'UCA', '016', 'Diya Mehta', 'Computer Applications', '9876000176', 'Agra Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA017', '2300100177', '2026-2027', '235UCA017', '235', 'UCA', '017', 'Ishaan Agarwal', 'Computer Applications', '9876000177', 'Mathura Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA018', '2300100178', '2026-2027', '235UCA018', '235', 'UCA', '018', 'Kavya Srivastava', 'Computer Applications', '9876000178', 'Aligarh Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA019', '2300100179', '2026-2027', '235UCA019', '235', 'UCA', '019', 'Krish Mishra', 'Computer Applications', '9876000179', 'Hapur Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCA020', '2300100180', '2026-2027', '235UCA020', '235', 'UCA', '020', 'Meera Chauhan', 'Computer Applications', '9876000180', 'Bulandshahr Uttar Pradesh', 'Computer Applications', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC001', '2300100181', '2026-2027', '235UCC001', '235', 'UCC', '001', 'Naksh Arora', 'Cyber Security', '9876000181', 'Greater Noida Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC002', '2300100182', '2026-2027', '235UCC002', '235', 'UCC', '002', 'Navya Singh', 'Cyber Security', '9876000182', 'Noida Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC003', '2300100183', '2026-2027', '235UCC003', '235', 'UCC', '003', 'Pranav Joshi', 'Cyber Security', '9876000183', 'Ghaziabad Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC004', '2300100184', '2026-2027', '235UCC004', '235', 'UCC', '004', 'Riya Jain', 'Cyber Security', '9876000184', 'Delhi', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC005', '2300100185', '2026-2027', '235UCC005', '235', 'UCC', '005', 'Rohan Chandra', 'Cyber Security', '9876000185', 'Meerut Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC006', '2300100186', '2026-2027', '235UCC006', '235', 'UCC', '006', 'Saanvi Patel', 'Cyber Security', '9876000186', 'Agra Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC007', '2300100187', '2026-2027', '235UCC007', '235', 'UCC', '007', 'Samarth Saxena', 'Cyber Security', '9876000187', 'Mathura Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC008', '2300100188', '2026-2027', '235UCC008', '235', 'UCC', '008', 'Siya Rao', 'Cyber Security', '9876000188', 'Aligarh Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC009', '2300100189', '2026-2027', '235UCC009', '235', 'UCC', '009', 'Vedant Gupta', 'Cyber Security', '9876000189', 'Hapur Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC010', '2300100190', '2026-2027', '235UCC010', '235', 'UCC', '010', 'Vanya Bansal', 'Cyber Security', '9876000190', 'Bulandshahr Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC011', '2300100191', '2026-2027', '235UCC011', '235', 'UCC', '011', 'Vihaan Malhotra', 'Cyber Security', '9876000191', 'Greater Noida Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC012', '2300100192', '2026-2027', '235UCC012', '235', 'UCC', '012', 'Zara Sharma', 'Cyber Security', '9876000192', 'Noida Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC013', '2300100193', '2026-2027', '235UCC013', '235', 'UCC', '013', 'Aarav Yadav', 'Cyber Security', '9876000193', 'Ghaziabad Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC014', '2300100194', '2026-2027', '235UCC014', '235', 'UCC', '014', 'Aditi Tiwari', 'Cyber Security', '9876000194', 'Delhi', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC015', '2300100195', '2026-2027', '235UCC015', '235', 'UCC', '015', 'Advik Khan', 'Cyber Security', '9876000195', 'Meerut Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC016', '2300100196', '2026-2027', '235UCC016', '235', 'UCC', '016', 'Ananya Kumar', 'Cyber Security', '9876000196', 'Agra Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC017', '2300100197', '2026-2027', '235UCC017', '235', 'UCC', '017', 'Arjun Kapoor', 'Cyber Security', '9876000197', 'Mathura Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC018', '2300100198', '2026-2027', '235UCC018', '235', 'UCC', '018', 'Avni Saini', 'Cyber Security', '9876000198', 'Aligarh Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC019', '2300100199', '2026-2027', '235UCC019', '235', 'UCC', '019', 'Dev Verma', 'Cyber Security', '9876000199', 'Hapur Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCC020', '2300100200', '2026-2027', '235UCC020', '235', 'UCC', '020', 'Diya Mehta', 'Cyber Security', '9876000200', 'Bulandshahr Uttar Pradesh', 'Cyber Security', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD001', '2300100201', '2026-2027', '235UCD001', '235', 'UCD', '001', 'Ishaan Agarwal', 'Data Science', '9876000201', 'Greater Noida Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD002', '2300100202', '2026-2027', '235UCD002', '235', 'UCD', '002', 'Kavya Srivastava', 'Data Science', '9876000202', 'Noida Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD003', '2300100203', '2026-2027', '235UCD003', '235', 'UCD', '003', 'Krish Mishra', 'Data Science', '9876000203', 'Ghaziabad Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD004', '2300100204', '2026-2027', '235UCD004', '235', 'UCD', '004', 'Meera Chauhan', 'Data Science', '9876000204', 'Delhi', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD005', '2300100205', '2026-2027', '235UCD005', '235', 'UCD', '005', 'Naksh Arora', 'Data Science', '9876000205', 'Meerut Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD006', '2300100206', '2026-2027', '235UCD006', '235', 'UCD', '006', 'Navya Singh', 'Data Science', '9876000206', 'Agra Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD007', '2300100207', '2026-2027', '235UCD007', '235', 'UCD', '007', 'Pranav Joshi', 'Data Science', '9876000207', 'Mathura Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD008', '2300100208', '2026-2027', '235UCD008', '235', 'UCD', '008', 'Riya Jain', 'Data Science', '9876000208', 'Aligarh Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD009', '2300100209', '2026-2027', '235UCD009', '235', 'UCD', '009', 'Rohan Chandra', 'Data Science', '9876000209', 'Hapur Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD010', '2300100210', '2026-2027', '235UCD010', '235', 'UCD', '010', 'Saanvi Patel', 'Data Science', '9876000210', 'Bulandshahr Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD011', '2300100211', '2026-2027', '235UCD011', '235', 'UCD', '011', 'Samarth Saxena', 'Data Science', '9876000211', 'Greater Noida Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD012', '2300100212', '2026-2027', '235UCD012', '235', 'UCD', '012', 'Siya Rao', 'Data Science', '9876000212', 'Noida Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD013', '2300100213', '2026-2027', '235UCD013', '235', 'UCD', '013', 'Vedant Gupta', 'Data Science', '9876000213', 'Ghaziabad Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD014', '2300100214', '2026-2027', '235UCD014', '235', 'UCD', '014', 'Vanya Bansal', 'Data Science', '9876000214', 'Delhi', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD015', '2300100215', '2026-2027', '235UCD015', '235', 'UCD', '015', 'Vihaan Malhotra', 'Data Science', '9876000215', 'Meerut Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD016', '2300100216', '2026-2027', '235UCD016', '235', 'UCD', '016', 'Zara Sharma', 'Data Science', '9876000216', 'Agra Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD017', '2300100217', '2026-2027', '235UCD017', '235', 'UCD', '017', 'Aarav Yadav', 'Data Science', '9876000217', 'Mathura Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD018', '2300100218', '2026-2027', '235UCD018', '235', 'UCD', '018', 'Aditi Tiwari', 'Data Science', '9876000218', 'Aligarh Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD019', '2300100219', '2026-2027', '235UCD019', '235', 'UCD', '019', 'Advik Khan', 'Data Science', '9876000219', 'Hapur Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCD020', '2300100220', '2026-2027', '235UCD020', '235', 'UCD', '020', 'Ananya Kumar', 'Data Science', '9876000220', 'Bulandshahr Uttar Pradesh', 'Data Science', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM001', '2300100221', '2026-2027', '235UCM001', '235', 'UCM', '001', 'Arjun Kapoor', 'Machine Learning', '9876000221', 'Greater Noida Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM002', '2300100222', '2026-2027', '235UCM002', '235', 'UCM', '002', 'Avni Saini', 'Machine Learning', '9876000222', 'Noida Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM003', '2300100223', '2026-2027', '235UCM003', '235', 'UCM', '003', 'Dev Verma', 'Machine Learning', '9876000223', 'Ghaziabad Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM004', '2300100224', '2026-2027', '235UCM004', '235', 'UCM', '004', 'Diya Mehta', 'Machine Learning', '9876000224', 'Delhi', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM005', '2300100225', '2026-2027', '235UCM005', '235', 'UCM', '005', 'Ishaan Agarwal', 'Machine Learning', '9876000225', 'Meerut Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM006', '2300100226', '2026-2027', '235UCM006', '235', 'UCM', '006', 'Kavya Srivastava', 'Machine Learning', '9876000226', 'Agra Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM007', '2300100227', '2026-2027', '235UCM007', '235', 'UCM', '007', 'Krish Mishra', 'Machine Learning', '9876000227', 'Mathura Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM008', '2300100228', '2026-2027', '235UCM008', '235', 'UCM', '008', 'Meera Chauhan', 'Machine Learning', '9876000228', 'Aligarh Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM009', '2300100229', '2026-2027', '235UCM009', '235', 'UCM', '009', 'Naksh Arora', 'Machine Learning', '9876000229', 'Hapur Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM010', '2300100230', '2026-2027', '235UCM010', '235', 'UCM', '010', 'Navya Singh', 'Machine Learning', '9876000230', 'Bulandshahr Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM011', '2300100231', '2026-2027', '235UCM011', '235', 'UCM', '011', 'Pranav Joshi', 'Machine Learning', '9876000231', 'Greater Noida Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM012', '2300100232', '2026-2027', '235UCM012', '235', 'UCM', '012', 'Riya Jain', 'Machine Learning', '9876000232', 'Noida Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM013', '2300100233', '2026-2027', '235UCM013', '235', 'UCM', '013', 'Rohan Chandra', 'Machine Learning', '9876000233', 'Ghaziabad Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM014', '2300100234', '2026-2027', '235UCM014', '235', 'UCM', '014', 'Saanvi Patel', 'Machine Learning', '9876000234', 'Delhi', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM015', '2300100235', '2026-2027', '235UCM015', '235', 'UCM', '015', 'Samarth Saxena', 'Machine Learning', '9876000235', 'Meerut Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM016', '2300100236', '2026-2027', '235UCM016', '235', 'UCM', '016', 'Siya Rao', 'Machine Learning', '9876000236', 'Agra Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM017', '2300100237', '2026-2027', '235UCM017', '235', 'UCM', '017', 'Vedant Gupta', 'Machine Learning', '9876000237', 'Mathura Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM018', '2300100238', '2026-2027', '235UCM018', '235', 'UCM', '018', 'Vanya Bansal', 'Machine Learning', '9876000238', 'Aligarh Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM019', '2300100239', '2026-2027', '235UCM019', '235', 'UCM', '019', 'Vihaan Malhotra', 'Machine Learning', '9876000239', 'Hapur Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCM020', '2300100240', '2026-2027', '235UCM020', '235', 'UCM', '020', 'Zara Sharma', 'Machine Learning', '9876000240', 'Bulandshahr Uttar Pradesh', 'Machine Learning', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS001', '2300100241', '2026-2027', '235UCS001', '235', 'UCS', '001', 'Aarav Yadav', 'Computer Science and Engineering', '9876000241', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS002', '2300100242', '2026-2027', '235UCS002', '235', 'UCS', '002', 'Aditi Tiwari', 'Computer Science and Engineering', '9876000242', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS003', '2300100243', '2026-2027', '235UCS003', '235', 'UCS', '003', 'Advik Khan', 'Computer Science and Engineering', '9876000243', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS004', '2300100244', '2026-2027', '235UCS004', '235', 'UCS', '004', 'Ananya Kumar', 'Computer Science and Engineering', '9876000244', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS005', '2300100245', '2026-2027', '235UCS005', '235', 'UCS', '005', 'Arjun Kapoor', 'Computer Science and Engineering', '9876000245', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS006', '2300100246', '2026-2027', '235UCS006', '235', 'UCS', '006', 'Avni Saini', 'Computer Science and Engineering', '9876000246', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS007', '2300100247', '2026-2027', '235UCS007', '235', 'UCS', '007', 'Dev Verma', 'Computer Science and Engineering', '9876000247', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS008', '2300100248', '2026-2027', '235UCS008', '235', 'UCS', '008', 'Diya Mehta', 'Computer Science and Engineering', '9876000248', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS009', '2300100249', '2026-2027', '235UCS009', '235', 'UCS', '009', 'Ishaan Agarwal', 'Computer Science and Engineering', '9876000249', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS010', '2300100250', '2026-2027', '235UCS010', '235', 'UCS', '010', 'Kavya Srivastava', 'Computer Science and Engineering', '9876000250', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS011', '2300100251', '2026-2027', '235UCS011', '235', 'UCS', '011', 'Krish Mishra', 'Computer Science and Engineering', '9876000251', 'Greater Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS012', '2300100252', '2026-2027', '235UCS012', '235', 'UCS', '012', 'Meera Chauhan', 'Computer Science and Engineering', '9876000252', 'Noida Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS013', '2300100253', '2026-2027', '235UCS013', '235', 'UCS', '013', 'Naksh Arora', 'Computer Science and Engineering', '9876000253', 'Ghaziabad Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS014', '2300100254', '2026-2027', '235UCS014', '235', 'UCS', '014', 'Navya Singh', 'Computer Science and Engineering', '9876000254', 'Delhi', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS015', '2300100255', '2026-2027', '235UCS015', '235', 'UCS', '015', 'Pranav Joshi', 'Computer Science and Engineering', '9876000255', 'Meerut Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS016', '2300100256', '2026-2027', '235UCS016', '235', 'UCS', '016', 'Riya Jain', 'Computer Science and Engineering', '9876000256', 'Agra Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS017', '2300100257', '2026-2027', '235UCS017', '235', 'UCS', '017', 'Rohan Chandra', 'Computer Science and Engineering', '9876000257', 'Mathura Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS018', '2300100258', '2026-2027', '235UCS018', '235', 'UCS', '018', 'Saanvi Patel', 'Computer Science and Engineering', '9876000258', 'Aligarh Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS019', '2300100259', '2026-2027', '235UCS019', '235', 'UCS', '019', 'Samarth Saxena', 'Computer Science and Engineering', '9876000259', 'Hapur Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UCS020', '2300100260', '2026-2027', '235UCS020', '235', 'UCS', '020', 'Siya Rao', 'Computer Science and Engineering', '9876000260', 'Bulandshahr Uttar Pradesh', 'Computer Science and Engineering', 'School of Information and Communication Technology', 3, 5, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA001', '2300100261', '2026-2027', '235UEA001', '235', 'UEA', '001', 'Vedant Gupta', 'Electronics AI and Machine Learning', '9876000261', 'Greater Noida Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA002', '2300100262', '2026-2027', '235UEA002', '235', 'UEA', '002', 'Vanya Bansal', 'Electronics AI and Machine Learning', '9876000262', 'Noida Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA003', '2300100263', '2026-2027', '235UEA003', '235', 'UEA', '003', 'Vihaan Malhotra', 'Electronics AI and Machine Learning', '9876000263', 'Ghaziabad Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA004', '2300100264', '2026-2027', '235UEA004', '235', 'UEA', '004', 'Zara Sharma', 'Electronics AI and Machine Learning', '9876000264', 'Delhi', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA005', '2300100265', '2026-2027', '235UEA005', '235', 'UEA', '005', 'Aarav Yadav', 'Electronics AI and Machine Learning', '9876000265', 'Meerut Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA006', '2300100266', '2026-2027', '235UEA006', '235', 'UEA', '006', 'Aditi Tiwari', 'Electronics AI and Machine Learning', '9876000266', 'Agra Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA007', '2300100267', '2026-2027', '235UEA007', '235', 'UEA', '007', 'Advik Khan', 'Electronics AI and Machine Learning', '9876000267', 'Mathura Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA008', '2300100268', '2026-2027', '235UEA008', '235', 'UEA', '008', 'Ananya Kumar', 'Electronics AI and Machine Learning', '9876000268', 'Aligarh Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA009', '2300100269', '2026-2027', '235UEA009', '235', 'UEA', '009', 'Arjun Kapoor', 'Electronics AI and Machine Learning', '9876000269', 'Hapur Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA010', '2300100270', '2026-2027', '235UEA010', '235', 'UEA', '010', 'Avni Saini', 'Electronics AI and Machine Learning', '9876000270', 'Bulandshahr Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA011', '2300100271', '2026-2027', '235UEA011', '235', 'UEA', '011', 'Dev Verma', 'Electronics AI and Machine Learning', '9876000271', 'Greater Noida Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA012', '2300100272', '2026-2027', '235UEA012', '235', 'UEA', '012', 'Diya Mehta', 'Electronics AI and Machine Learning', '9876000272', 'Noida Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA013', '2300100273', '2026-2027', '235UEA013', '235', 'UEA', '013', 'Ishaan Agarwal', 'Electronics AI and Machine Learning', '9876000273', 'Ghaziabad Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA014', '2300100274', '2026-2027', '235UEA014', '235', 'UEA', '014', 'Kavya Srivastava', 'Electronics AI and Machine Learning', '9876000274', 'Delhi', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA015', '2300100275', '2026-2027', '235UEA015', '235', 'UEA', '015', 'Krish Mishra', 'Electronics AI and Machine Learning', '9876000275', 'Meerut Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA016', '2300100276', '2026-2027', '235UEA016', '235', 'UEA', '016', 'Meera Chauhan', 'Electronics AI and Machine Learning', '9876000276', 'Agra Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA017', '2300100277', '2026-2027', '235UEA017', '235', 'UEA', '017', 'Naksh Arora', 'Electronics AI and Machine Learning', '9876000277', 'Mathura Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA018', '2300100278', '2026-2027', '235UEA018', '235', 'UEA', '018', 'Navya Singh', 'Electronics AI and Machine Learning', '9876000278', 'Aligarh Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA019', '2300100279', '2026-2027', '235UEA019', '235', 'UEA', '019', 'Pranav Joshi', 'Electronics AI and Machine Learning', '9876000279', 'Hapur Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEA020', '2300100280', '2026-2027', '235UEA020', '235', 'UEA', '020', 'Riya Jain', 'Electronics AI and Machine Learning', '9876000280', 'Bulandshahr Uttar Pradesh', 'Electronics AI and Machine Learning', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC001', '2300100281', '2026-2027', '235UEC001', '235', 'UEC', '001', 'Rohan Chandra', 'Electronics and Communication Engineering', '9876000281', 'Greater Noida Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC002', '2300100282', '2026-2027', '235UEC002', '235', 'UEC', '002', 'Saanvi Patel', 'Electronics and Communication Engineering', '9876000282', 'Noida Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC003', '2300100283', '2026-2027', '235UEC003', '235', 'UEC', '003', 'Samarth Saxena', 'Electronics and Communication Engineering', '9876000283', 'Ghaziabad Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC004', '2300100284', '2026-2027', '235UEC004', '235', 'UEC', '004', 'Siya Rao', 'Electronics and Communication Engineering', '9876000284', 'Delhi', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC005', '2300100285', '2026-2027', '235UEC005', '235', 'UEC', '005', 'Vedant Gupta', 'Electronics and Communication Engineering', '9876000285', 'Meerut Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC006', '2300100286', '2026-2027', '235UEC006', '235', 'UEC', '006', 'Vanya Bansal', 'Electronics and Communication Engineering', '9876000286', 'Agra Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC007', '2300100287', '2026-2027', '235UEC007', '235', 'UEC', '007', 'Vihaan Malhotra', 'Electronics and Communication Engineering', '9876000287', 'Mathura Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC008', '2300100288', '2026-2027', '235UEC008', '235', 'UEC', '008', 'Zara Sharma', 'Electronics and Communication Engineering', '9876000288', 'Aligarh Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC009', '2300100289', '2026-2027', '235UEC009', '235', 'UEC', '009', 'Aarav Yadav', 'Electronics and Communication Engineering', '9876000289', 'Hapur Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC010', '2300100290', '2026-2027', '235UEC010', '235', 'UEC', '010', 'Aditi Tiwari', 'Electronics and Communication Engineering', '9876000290', 'Bulandshahr Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC011', '2300100291', '2026-2027', '235UEC011', '235', 'UEC', '011', 'Advik Khan', 'Electronics and Communication Engineering', '9876000291', 'Greater Noida Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC012', '2300100292', '2026-2027', '235UEC012', '235', 'UEC', '012', 'Ananya Kumar', 'Electronics and Communication Engineering', '9876000292', 'Noida Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC013', '2300100293', '2026-2027', '235UEC013', '235', 'UEC', '013', 'Arjun Kapoor', 'Electronics and Communication Engineering', '9876000293', 'Ghaziabad Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC014', '2300100294', '2026-2027', '235UEC014', '235', 'UEC', '014', 'Avni Saini', 'Electronics and Communication Engineering', '9876000294', 'Delhi', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC015', '2300100295', '2026-2027', '235UEC015', '235', 'UEC', '015', 'Dev Verma', 'Electronics and Communication Engineering', '9876000295', 'Meerut Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC016', '2300100296', '2026-2027', '235UEC016', '235', 'UEC', '016', 'Diya Mehta', 'Electronics and Communication Engineering', '9876000296', 'Agra Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC017', '2300100297', '2026-2027', '235UEC017', '235', 'UEC', '017', 'Ishaan Agarwal', 'Electronics and Communication Engineering', '9876000297', 'Mathura Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC018', '2300100298', '2026-2027', '235UEC018', '235', 'UEC', '018', 'Kavya Srivastava', 'Electronics and Communication Engineering', '9876000298', 'Aligarh Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC019', '2300100299', '2026-2027', '235UEC019', '235', 'UEC', '019', 'Krish Mishra', 'Electronics and Communication Engineering', '9876000299', 'Hapur Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UEC020', '2300100300', '2026-2027', '235UEC020', '235', 'UEC', '020', 'Meera Chauhan', 'Electronics and Communication Engineering', '9876000300', 'Bulandshahr Uttar Pradesh', 'Electronics and Communication Engineering', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT001', '2300100301', '2026-2027', '235UIT001', '235', 'UIT', '001', 'Naksh Arora', 'Information Technology', '9876000301', 'Greater Noida Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT002', '2300100302', '2026-2027', '235UIT002', '235', 'UIT', '002', 'Navya Singh', 'Information Technology', '9876000302', 'Noida Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT003', '2300100303', '2026-2027', '235UIT003', '235', 'UIT', '003', 'Pranav Joshi', 'Information Technology', '9876000303', 'Ghaziabad Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT004', '2300100304', '2026-2027', '235UIT004', '235', 'UIT', '004', 'Riya Jain', 'Information Technology', '9876000304', 'Delhi', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT005', '2300100305', '2026-2027', '235UIT005', '235', 'UIT', '005', 'Rohan Chandra', 'Information Technology', '9876000305', 'Meerut Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT006', '2300100306', '2026-2027', '235UIT006', '235', 'UIT', '006', 'Saanvi Patel', 'Information Technology', '9876000306', 'Agra Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT007', '2300100307', '2026-2027', '235UIT007', '235', 'UIT', '007', 'Samarth Saxena', 'Information Technology', '9876000307', 'Mathura Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT008', '2300100308', '2026-2027', '235UIT008', '235', 'UIT', '008', 'Siya Rao', 'Information Technology', '9876000308', 'Aligarh Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT009', '2300100309', '2026-2027', '235UIT009', '235', 'UIT', '009', 'Vedant Gupta', 'Information Technology', '9876000309', 'Hapur Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT010', '2300100310', '2026-2027', '235UIT010', '235', 'UIT', '010', 'Vanya Bansal', 'Information Technology', '9876000310', 'Bulandshahr Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT011', '2300100311', '2026-2027', '235UIT011', '235', 'UIT', '011', 'Vihaan Malhotra', 'Information Technology', '9876000311', 'Greater Noida Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT012', '2300100312', '2026-2027', '235UIT012', '235', 'UIT', '012', 'Zara Sharma', 'Information Technology', '9876000312', 'Noida Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT013', '2300100313', '2026-2027', '235UIT013', '235', 'UIT', '013', 'Aarav Yadav', 'Information Technology', '9876000313', 'Ghaziabad Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT014', '2300100314', '2026-2027', '235UIT014', '235', 'UIT', '014', 'Aditi Tiwari', 'Information Technology', '9876000314', 'Delhi', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT015', '2300100315', '2026-2027', '235UIT015', '235', 'UIT', '015', 'Advik Khan', 'Information Technology', '9876000315', 'Meerut Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT016', '2300100316', '2026-2027', '235UIT016', '235', 'UIT', '016', 'Ananya Kumar', 'Information Technology', '9876000316', 'Agra Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT017', '2300100317', '2026-2027', '235UIT017', '235', 'UIT', '017', 'Arjun Kapoor', 'Information Technology', '9876000317', 'Mathura Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT018', '2300100318', '2026-2027', '235UIT018', '235', 'UIT', '018', 'Avni Saini', 'Information Technology', '9876000318', 'Aligarh Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT019', '2300100319', '2026-2027', '235UIT019', '235', 'UIT', '019', 'Dev Verma', 'Information Technology', '9876000319', 'Hapur Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UIT020', '2300100320', '2026-2027', '235UIT020', '235', 'UIT', '020', 'Diya Mehta', 'Information Technology', '9876000320', 'Bulandshahr Uttar Pradesh', 'Information Technology', 'School of Information and Communication Technology', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL001', '2300100321', '2026-2027', '235UVL001', '235', 'UVL', '001', 'Ishaan Agarwal', 'VLSI Design and Embedded Systems', '9876000321', 'Greater Noida Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL002', '2300100322', '2026-2027', '235UVL002', '235', 'UVL', '002', 'Kavya Srivastava', 'VLSI Design and Embedded Systems', '9876000322', 'Noida Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL003', '2300100323', '2026-2027', '235UVL003', '235', 'UVL', '003', 'Krish Mishra', 'VLSI Design and Embedded Systems', '9876000323', 'Ghaziabad Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL004', '2300100324', '2026-2027', '235UVL004', '235', 'UVL', '004', 'Meera Chauhan', 'VLSI Design and Embedded Systems', '9876000324', 'Delhi', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL005', '2300100325', '2026-2027', '235UVL005', '235', 'UVL', '005', 'Naksh Arora', 'VLSI Design and Embedded Systems', '9876000325', 'Meerut Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL006', '2300100326', '2026-2027', '235UVL006', '235', 'UVL', '006', 'Navya Singh', 'VLSI Design and Embedded Systems', '9876000326', 'Agra Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL007', '2300100327', '2026-2027', '235UVL007', '235', 'UVL', '007', 'Pranav Joshi', 'VLSI Design and Embedded Systems', '9876000327', 'Mathura Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL008', '2300100328', '2026-2027', '235UVL008', '235', 'UVL', '008', 'Riya Jain', 'VLSI Design and Embedded Systems', '9876000328', 'Aligarh Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL009', '2300100329', '2026-2027', '235UVL009', '235', 'UVL', '009', 'Rohan Chandra', 'VLSI Design and Embedded Systems', '9876000329', 'Hapur Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL010', '2300100330', '2026-2027', '235UVL010', '235', 'UVL', '010', 'Saanvi Patel', 'VLSI Design and Embedded Systems', '9876000330', 'Bulandshahr Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'A', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL011', '2300100331', '2026-2027', '235UVL011', '235', 'UVL', '011', 'Samarth Saxena', 'VLSI Design and Embedded Systems', '9876000331', 'Greater Noida Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL012', '2300100332', '2026-2027', '235UVL012', '235', 'UVL', '012', 'Siya Rao', 'VLSI Design and Embedded Systems', '9876000332', 'Noida Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL013', '2300100333', '2026-2027', '235UVL013', '235', 'UVL', '013', 'Vedant Gupta', 'VLSI Design and Embedded Systems', '9876000333', 'Ghaziabad Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL014', '2300100334', '2026-2027', '235UVL014', '235', 'UVL', '014', 'Vanya Bansal', 'VLSI Design and Embedded Systems', '9876000334', 'Delhi', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL015', '2300100335', '2026-2027', '235UVL015', '235', 'UVL', '015', 'Vihaan Malhotra', 'VLSI Design and Embedded Systems', '9876000335', 'Meerut Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL016', '2300100336', '2026-2027', '235UVL016', '235', 'UVL', '016', 'Zara Sharma', 'VLSI Design and Embedded Systems', '9876000336', 'Agra Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL017', '2300100337', '2026-2027', '235UVL017', '235', 'UVL', '017', 'Aarav Yadav', 'VLSI Design and Embedded Systems', '9876000337', 'Mathura Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL018', '2300100338', '2026-2027', '235UVL018', '235', 'UVL', '018', 'Aditi Tiwari', 'VLSI Design and Embedded Systems', '9876000338', 'Aligarh Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL019', '2300100339', '2026-2027', '235UVL019', '235', 'UVL', '019', 'Advik Khan', 'VLSI Design and Embedded Systems', '9876000339', 'Hapur Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO students (programme_id, batch_id, roll_no_original, enrollment_number, academic_session, normalized_roll_no, registration_prefix, programme_code_detected, student_sequence, name, branch, mobile_number, address, department_name, school_name, current_year_of_study, semester, section, admission_type, parsing_status)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), '235UVL020', '2300100340', '2026-2027', '235UVL020', '235', 'UVL', '020', 'Ananya Kumar', 'VLSI Design and Embedded Systems', '9876000340', 'Bulandshahr Uttar Pradesh', 'VLSI Design and Embedded Systems', 'School of Engineering', 2, 3, 'B', 'regular', 'verified'
FROM programmes p WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = students.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F001', 'Dr. Ananya Mishra', 'Professor', 'ananya.mishra.1@example.test', '9765000001' FROM schools WHERE code = 'ICT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F002', 'Dr. Dev Bansal', 'Associate Professor', 'dev.bansal.2@example.test', '9765000002' FROM schools WHERE code = 'ICT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F003', 'Dr. Kavya Agarwal', 'Associate Professor', 'kavya.agarwal.3@example.test', '9765000003' FROM schools WHERE code = 'ICT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F004', 'Dr. Naksh Rao', 'Assistant Professor', 'naksh.rao.4@example.test', '9765000004' FROM schools WHERE code = 'ICT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F005', 'Dr. Riya Verma', 'Assistant Professor', 'riya.verma.5@example.test', '9765000005' FROM schools WHERE code = 'ICT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F006', 'Dr. Samarth Patel', 'Assistant Professor', 'samarth.patel.6@example.test', '9765000006' FROM schools WHERE code = 'ICT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F007', 'Dr. Vanya Kapoor', 'Assistant Professor', 'vanya.kapoor.7@example.test', '9765000007' FROM schools WHERE code = 'ICT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F008', 'Dr. Aarav Jain', 'Assistant Professor', 'aarav.jain.8@example.test', '9765000008' FROM schools WHERE code = 'ICT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F009', 'Dr. Ananya Khan', 'Professor', 'ananya.khan.9@example.test', '9765000009' FROM schools WHERE code = 'SOE'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F010', 'Dr. Dev Singh', 'Associate Professor', 'dev.singh.10@example.test', '9765000010' FROM schools WHERE code = 'SOE'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F011', 'Dr. Kavya Yadav', 'Associate Professor', 'kavya.yadav.11@example.test', '9765000011' FROM schools WHERE code = 'SOE'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F012', 'Dr. Naksh Chauhan', 'Assistant Professor', 'naksh.chauhan.12@example.test', '9765000012' FROM schools WHERE code = 'SOE'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F013', 'Dr. Riya Malhotra', 'Assistant Professor', 'riya.malhotra.13@example.test', '9765000013' FROM schools WHERE code = 'SOE'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F014', 'Dr. Samarth Srivastava', 'Assistant Professor', 'samarth.srivastava.14@example.test', '9765000014' FROM schools WHERE code = 'SOE'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F015', 'Dr. Vanya Gupta', 'Assistant Professor', 'vanya.gupta.15@example.test', '9765000015' FROM schools WHERE code = 'SOE'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F016', 'Dr. Aarav Mehta', 'Assistant Professor', 'aarav.mehta.16@example.test', '9765000016' FROM schools WHERE code = 'SOE'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F017', 'Dr. Ananya Saxena', 'Professor', 'ananya.saxena.17@example.test', '9765000017' FROM schools WHERE code = 'SOM'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F018', 'Dr. Dev Saini', 'Associate Professor', 'dev.saini.18@example.test', '9765000018' FROM schools WHERE code = 'SOM'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F019', 'Dr. Kavya Chandra', 'Associate Professor', 'kavya.chandra.19@example.test', '9765000019' FROM schools WHERE code = 'SOM'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F020', 'Dr. Naksh Kumar', 'Assistant Professor', 'naksh.kumar.20@example.test', '9765000020' FROM schools WHERE code = 'SOM'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F021', 'Dr. Riya Joshi', 'Assistant Professor', 'riya.joshi.21@example.test', '9765000021' FROM schools WHERE code = 'SOM'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F022', 'Dr. Samarth Tiwari', 'Assistant Professor', 'samarth.tiwari.22@example.test', '9765000022' FROM schools WHERE code = 'SOM'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F023', 'Dr. Vanya Arora', 'Assistant Professor', 'vanya.arora.23@example.test', '9765000023' FROM schools WHERE code = 'SOM'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F024', 'Dr. Aarav Sharma', 'Assistant Professor', 'aarav.sharma.24@example.test', '9765000024' FROM schools WHERE code = 'SOM'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F025', 'Dr. Ananya Mishra', 'Professor', 'ananya.mishra.25@example.test', '9765000025' FROM schools WHERE code = 'SOBT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F026', 'Dr. Dev Bansal', 'Associate Professor', 'dev.bansal.26@example.test', '9765000026' FROM schools WHERE code = 'SOBT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F027', 'Dr. Kavya Agarwal', 'Associate Professor', 'kavya.agarwal.27@example.test', '9765000027' FROM schools WHERE code = 'SOBT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F028', 'Dr. Naksh Rao', 'Assistant Professor', 'naksh.rao.28@example.test', '9765000028' FROM schools WHERE code = 'SOBT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F029', 'Dr. Riya Verma', 'Assistant Professor', 'riya.verma.29@example.test', '9765000029' FROM schools WHERE code = 'SOBT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F030', 'Dr. Samarth Patel', 'Assistant Professor', 'samarth.patel.30@example.test', '9765000030' FROM schools WHERE code = 'SOBT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F031', 'Dr. Vanya Kapoor', 'Assistant Professor', 'vanya.kapoor.31@example.test', '9765000031' FROM schools WHERE code = 'SOBT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F032', 'Dr. Aarav Jain', 'Assistant Professor', 'aarav.jain.32@example.test', '9765000032' FROM schools WHERE code = 'SOBT'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F033', 'Dr. Ananya Khan', 'Professor', 'ananya.khan.33@example.test', '9765000033' FROM schools WHERE code = 'SOVSAS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F034', 'Dr. Dev Singh', 'Associate Professor', 'dev.singh.34@example.test', '9765000034' FROM schools WHERE code = 'SOVSAS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F035', 'Dr. Kavya Yadav', 'Associate Professor', 'kavya.yadav.35@example.test', '9765000035' FROM schools WHERE code = 'SOVSAS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F036', 'Dr. Naksh Chauhan', 'Assistant Professor', 'naksh.chauhan.36@example.test', '9765000036' FROM schools WHERE code = 'SOVSAS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F037', 'Dr. Riya Malhotra', 'Assistant Professor', 'riya.malhotra.37@example.test', '9765000037' FROM schools WHERE code = 'SOVSAS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F038', 'Dr. Samarth Srivastava', 'Assistant Professor', 'samarth.srivastava.38@example.test', '9765000038' FROM schools WHERE code = 'SOVSAS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F039', 'Dr. Vanya Gupta', 'Assistant Professor', 'vanya.gupta.39@example.test', '9765000039' FROM schools WHERE code = 'SOVSAS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F040', 'Dr. Aarav Mehta', 'Assistant Professor', 'aarav.mehta.40@example.test', '9765000040' FROM schools WHERE code = 'SOVSAS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F041', 'Dr. Ananya Saxena', 'Professor', 'ananya.saxena.41@example.test', '9765000041' FROM schools WHERE code = 'SOHSS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F042', 'Dr. Dev Saini', 'Associate Professor', 'dev.saini.42@example.test', '9765000042' FROM schools WHERE code = 'SOHSS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F043', 'Dr. Kavya Chandra', 'Associate Professor', 'kavya.chandra.43@example.test', '9765000043' FROM schools WHERE code = 'SOHSS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F044', 'Dr. Naksh Kumar', 'Assistant Professor', 'naksh.kumar.44@example.test', '9765000044' FROM schools WHERE code = 'SOHSS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F045', 'Dr. Riya Joshi', 'Assistant Professor', 'riya.joshi.45@example.test', '9765000045' FROM schools WHERE code = 'SOHSS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F046', 'Dr. Samarth Tiwari', 'Assistant Professor', 'samarth.tiwari.46@example.test', '9765000046' FROM schools WHERE code = 'SOHSS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F047', 'Dr. Vanya Arora', 'Assistant Professor', 'vanya.arora.47@example.test', '9765000047' FROM schools WHERE code = 'SOHSS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F048', 'Dr. Aarav Sharma', 'Assistant Professor', 'aarav.sharma.48@example.test', '9765000048' FROM schools WHERE code = 'SOHSS'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F049', 'Dr. Ananya Mishra', 'Professor', 'ananya.mishra.49@example.test', '9765000049' FROM schools WHERE code = 'SOBSC'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F050', 'Dr. Dev Bansal', 'Associate Professor', 'dev.bansal.50@example.test', '9765000050' FROM schools WHERE code = 'SOBSC'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F051', 'Dr. Kavya Agarwal', 'Associate Professor', 'kavya.agarwal.51@example.test', '9765000051' FROM schools WHERE code = 'SOBSC'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F052', 'Dr. Naksh Rao', 'Assistant Professor', 'naksh.rao.52@example.test', '9765000052' FROM schools WHERE code = 'SOBSC'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F053', 'Dr. Riya Verma', 'Assistant Professor', 'riya.verma.53@example.test', '9765000053' FROM schools WHERE code = 'SOBSC'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F054', 'Dr. Samarth Patel', 'Assistant Professor', 'samarth.patel.54@example.test', '9765000054' FROM schools WHERE code = 'SOBSC'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F055', 'Dr. Vanya Kapoor', 'Assistant Professor', 'vanya.kapoor.55@example.test', '9765000055' FROM schools WHERE code = 'SOBSC'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F056', 'Dr. Aarav Jain', 'Assistant Professor', 'aarav.jain.56@example.test', '9765000056' FROM schools WHERE code = 'SOBSC'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F057', 'Dr. Ananya Khan', 'Professor', 'ananya.khan.57@example.test', '9765000057' FROM schools WHERE code = 'SOLJG'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F058', 'Dr. Dev Singh', 'Associate Professor', 'dev.singh.58@example.test', '9765000058' FROM schools WHERE code = 'SOLJG'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F059', 'Dr. Kavya Yadav', 'Associate Professor', 'kavya.yadav.59@example.test', '9765000059' FROM schools WHERE code = 'SOLJG'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F060', 'Dr. Naksh Chauhan', 'Assistant Professor', 'naksh.chauhan.60@example.test', '9765000060' FROM schools WHERE code = 'SOLJG'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F061', 'Dr. Riya Malhotra', 'Assistant Professor', 'riya.malhotra.61@example.test', '9765000061' FROM schools WHERE code = 'SOLJG'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F062', 'Dr. Samarth Srivastava', 'Assistant Professor', 'samarth.srivastava.62@example.test', '9765000062' FROM schools WHERE code = 'SOLJG'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F063', 'Dr. Vanya Gupta', 'Assistant Professor', 'vanya.gupta.63@example.test', '9765000063' FROM schools WHERE code = 'SOLJG'
ON DUPLICATE KEY UPDATE id = faculty.id;

INSERT INTO faculty (school_id, employee_id, name, designation, email, phone)
SELECT id, 'GBU-LARGE-F064', 'Dr. Aarav Mehta', 'Assistant Professor', 'aarav.mehta.64@example.test', '9765000064' FROM schools WHERE code = 'SOLJG'
ON DUPLICATE KEY UPDATE id = faculty.id;

-- Add proposed rooms and seat grids together. Existing room layouts are preserved.

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'ICT-101', id, 'School of ICT Block', 'Ground Floor', 6, 8, 48, 46, 'column_major', 10, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'ICT'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'ICT-101');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 1 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'ICT-102', id, 'School of ICT Block', 'Ground Floor', 6, 8, 48, 48, 'column_major', 11, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'ICT'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'ICT-102');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'ICT-201', id, 'School of ICT Block', 'First Floor', 7, 8, 56, 53, 'column_major', 12, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'ICT'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'ICT-201');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C01', 7, 1, 'DESK-1', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C02', 7, 2, 'DESK-1', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C03', 7, 3, 'DESK-2', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 23, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 24, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C04', 7, 4, 'DESK-2', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C05', 7, 5, 'DESK-3', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C06', 7, 6, 'DESK-3', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C07', 7, 7, 'DESK-4', 1, 49, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 50, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 51, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 52, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 53, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 54, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 55, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C08', 7, 8, 'DESK-4', 2, 56, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'ICT-202', id, 'School of ICT Block', 'First Floor', 7, 8, 56, 54, 'row_major', 13, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'ICT'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'ICT-202');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 8, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C01', 7, 1, 'DESK-1', 1, 49, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C02', 7, 2, 'DESK-1', 2, 50, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C03', 7, 3, 'DESK-2', 1, 51, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C04', 7, 4, 'DESK-2', 2, 52, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C05', 7, 5, 'DESK-3', 1, 53, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C06', 7, 6, 'DESK-3', 2, 54, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C07', 7, 7, 'DESK-4', 1, 55, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C08', 7, 8, 'DESK-4', 2, 56, 1 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'ICT-301', id, 'School of ICT Block', 'Second Floor', 8, 8, 64, 62, 'column_major', 14, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'ICT'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'ICT-301');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C01', 7, 1, 'DESK-1', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C01', 8, 1, 'DESK-1', 1, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C02', 7, 2, 'DESK-1', 2, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C02', 8, 2, 'DESK-1', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C03', 7, 3, 'DESK-2', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C03', 8, 3, 'DESK-2', 1, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 28, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C04', 7, 4, 'DESK-2', 2, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C04', 8, 4, 'DESK-2', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 36, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C05', 7, 5, 'DESK-3', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C05', 8, 5, 'DESK-3', 1, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C06', 7, 6, 'DESK-3', 2, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C06', 8, 6, 'DESK-3', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 49, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 50, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 51, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 52, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 53, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 54, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C07', 7, 7, 'DESK-4', 1, 55, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C07', 8, 7, 'DESK-4', 1, 56, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 57, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 58, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 59, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 60, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 61, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 62, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C08', 7, 8, 'DESK-4', 2, 63, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C08', 8, 8, 'DESK-4', 2, 64, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOE-101', id, 'School of Engineering Block', 'Ground Floor', 6, 10, 60, 58, 'column_major', 20, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOE'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOE-101');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C09', 1, 9, 'DESK-5', 1, 49, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C09', 2, 9, 'DESK-5', 1, 50, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C09', 3, 9, 'DESK-5', 1, 51, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C09', 4, 9, 'DESK-5', 1, 52, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C09', 5, 9, 'DESK-5', 1, 53, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C09', 6, 9, 'DESK-5', 1, 54, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C10', 1, 10, 'DESK-5', 2, 55, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C10', 2, 10, 'DESK-5', 2, 56, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C10', 3, 10, 'DESK-5', 2, 57, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C10', 4, 10, 'DESK-5', 2, 58, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C10', 5, 10, 'DESK-5', 2, 59, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C10', 6, 10, 'DESK-5', 2, 60, 1 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOE-102', id, 'School of Engineering Block', 'Ground Floor', 6, 10, 60, 58, 'row_major', 21, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOE'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOE-102');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C09', 1, 9, 'DESK-5', 1, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C10', 1, 10, 'DESK-5', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C09', 2, 9, 'DESK-5', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C10', 2, 10, 'DESK-5', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 25, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 26, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C09', 3, 9, 'DESK-5', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C10', 3, 10, 'DESK-5', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C09', 4, 9, 'DESK-5', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C10', 4, 10, 'DESK-5', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C09', 5, 9, 'DESK-5', 1, 49, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C10', 5, 10, 'DESK-5', 2, 50, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 51, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 52, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 53, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 54, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 55, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 56, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 57, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 58, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C09', 6, 9, 'DESK-5', 1, 59, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C10', 6, 10, 'DESK-5', 2, 60, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOE-201', id, 'School of Engineering Block', 'First Floor', 8, 10, 80, 77, 'column_major', 22, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOE'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOE-201');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C01', 7, 1, 'DESK-1', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C01', 8, 1, 'DESK-1', 1, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C02', 7, 2, 'DESK-1', 2, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C02', 8, 2, 'DESK-1', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C03', 7, 3, 'DESK-2', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C03', 8, 3, 'DESK-2', 1, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C04', 7, 4, 'DESK-2', 2, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C04', 8, 4, 'DESK-2', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 36, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C05', 7, 5, 'DESK-3', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C05', 8, 5, 'DESK-3', 1, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C06', 7, 6, 'DESK-3', 2, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C06', 8, 6, 'DESK-3', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 49, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 50, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 51, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 52, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 53, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 54, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C07', 7, 7, 'DESK-4', 1, 55, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C07', 8, 7, 'DESK-4', 1, 56, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 57, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 58, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 59, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 60, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 61, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 62, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C08', 7, 8, 'DESK-4', 2, 63, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C08', 8, 8, 'DESK-4', 2, 64, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C09', 1, 9, 'DESK-5', 1, 65, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C09', 2, 9, 'DESK-5', 1, 66, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C09', 3, 9, 'DESK-5', 1, 67, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C09', 4, 9, 'DESK-5', 1, 68, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C09', 5, 9, 'DESK-5', 1, 69, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C09', 6, 9, 'DESK-5', 1, 70, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C09', 7, 9, 'DESK-5', 1, 71, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C09', 8, 9, 'DESK-5', 1, 72, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C10', 1, 10, 'DESK-5', 2, 73, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C10', 2, 10, 'DESK-5', 2, 74, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C10', 3, 10, 'DESK-5', 2, 75, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C10', 4, 10, 'DESK-5', 2, 76, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C10', 5, 10, 'DESK-5', 2, 77, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C10', 6, 10, 'DESK-5', 2, 78, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C10', 7, 10, 'DESK-5', 2, 79, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R08-C10', 8, 10, 'DESK-5', 2, 80, 1 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOE-202', id, 'School of Engineering Block', 'First Floor', 7, 10, 70, 70, 'column_major', 23, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOE'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOE-202');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C01', 7, 1, 'DESK-1', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C02', 7, 2, 'DESK-1', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C03', 7, 3, 'DESK-2', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C04', 7, 4, 'DESK-2', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C05', 7, 5, 'DESK-3', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C06', 7, 6, 'DESK-3', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C07', 7, 7, 'DESK-4', 1, 49, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 50, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 51, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 52, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 53, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 54, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 55, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C08', 7, 8, 'DESK-4', 2, 56, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C09', 1, 9, 'DESK-5', 1, 57, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C09', 2, 9, 'DESK-5', 1, 58, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C09', 3, 9, 'DESK-5', 1, 59, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C09', 4, 9, 'DESK-5', 1, 60, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C09', 5, 9, 'DESK-5', 1, 61, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C09', 6, 9, 'DESK-5', 1, 62, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C09', 7, 9, 'DESK-5', 1, 63, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C10', 1, 10, 'DESK-5', 2, 64, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C10', 2, 10, 'DESK-5', 2, 65, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C10', 3, 10, 'DESK-5', 2, 66, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C10', 4, 10, 'DESK-5', 2, 67, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C10', 5, 10, 'DESK-5', 2, 68, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C10', 6, 10, 'DESK-5', 2, 69, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R07-C10', 7, 10, 'DESK-5', 2, 70, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOM-101', id, 'School of Management Block', 'Ground Floor', 6, 8, 48, 46, 'row_major', 30, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOM'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOM-101');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 41, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 1 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOM-201', id, 'School of Management Block', 'First Floor', 6, 9, 54, 53, 'column_major', 31, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOM'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOM-201');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 27, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C09', 1, 9, 'DESK-5', 1, 49, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C09', 2, 9, 'DESK-5', 1, 50, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C09', 3, 9, 'DESK-5', 1, 51, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C09', 4, 9, 'DESK-5', 1, 52, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C09', 5, 9, 'DESK-5', 1, 53, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C09', 6, 9, 'DESK-5', 1, 54, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOBT-101', id, 'School of Biotechnology Block', 'Ground Floor', 5, 8, 40, 38, 'column_major', 40, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOBT'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOBT-101');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 36, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 40, 1 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOBT-201', id, 'School of Biotechnology Block', 'First Floor', 6, 8, 48, 46, 'row_major', 41, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOBT'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOBT-201');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 10, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 15, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOHSS-101', id, 'School of Humanities Block', 'Ground Floor', 6, 8, 48, 47, 'column_major', 50, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOHSS'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOHSS-101');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 24, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOHSS-201', id, 'School of Humanities Block', 'First Floor', 5, 8, 40, 40, 'row_major', 51, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOHSS'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOHSS-201');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOLJG-101', id, 'School of Law Block', 'Ground Floor', 6, 9, 54, 52, 'column_major', 60, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOLJG'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOLJG-101');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C09', 1, 9, 'DESK-5', 1, 49, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C09', 2, 9, 'DESK-5', 1, 50, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C09', 3, 9, 'DESK-5', 1, 51, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C09', 4, 9, 'DESK-5', 1, 52, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C09', 5, 9, 'DESK-5', 1, 53, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C09', 6, 9, 'DESK-5', 1, 54, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOLJG-201', id, 'School of Law Block', 'First Floor', 6, 8, 48, 46, 'row_major', 61, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOLJG'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOLJG-201');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 20, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 21, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOBSC-101', id, 'School of Buddhist Studies Block', 'Ground Floor', 5, 8, 40, 39, 'column_major', 70, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOBSC'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOBSC-101');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOVSAS-101', id, 'Vocational Studies Block', 'Ground Floor', 6, 8, 48, 46, 'row_major', 80, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOVSAS'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOVSAS-101');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 8, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 23, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 28, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C01', 6, 1, 'DESK-1', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C02', 6, 2, 'DESK-1', 2, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C03', 6, 3, 'DESK-2', 1, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C04', 6, 4, 'DESK-2', 2, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C05', 6, 5, 'DESK-3', 1, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C06', 6, 6, 'DESK-3', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C07', 6, 7, 'DESK-4', 1, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R06-C08', 6, 8, 'DESK-4', 2, 48, 1 WHERE @seed2_room_id IS NOT NULL;

INSERT INTO rooms (code, school_id, building, floor, rows_count, columns_count, physical_capacity, usable_capacity, seat_order, priority, status, notes)
SELECT 'SOVSAS-201', id, 'Vocational Studies Block', 'First Floor', 5, 10, 50, 48, 'column_major', 81, 'active', 'Proposed demo room - verify with GBU' FROM schools WHERE code = 'SOVSAS'
AND NOT EXISTS (SELECT 1 FROM rooms WHERE code = 'SOVSAS-201');
SET @seed2_room_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO room_seats (room_id, seat_label, row_no, column_no, desk_group, desk_position, sequence_no, is_blocked)
SELECT @seed2_room_id, 'R01-C01', 1, 1, 'DESK-1', 1, 1, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C01', 2, 1, 'DESK-1', 1, 2, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C01', 3, 1, 'DESK-1', 1, 3, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C01', 4, 1, 'DESK-1', 1, 4, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C01', 5, 1, 'DESK-1', 1, 5, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C02', 1, 2, 'DESK-1', 2, 6, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C02', 2, 2, 'DESK-1', 2, 7, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C02', 3, 2, 'DESK-1', 2, 8, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C02', 4, 2, 'DESK-1', 2, 9, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C02', 5, 2, 'DESK-1', 2, 10, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C03', 1, 3, 'DESK-2', 1, 11, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C03', 2, 3, 'DESK-2', 1, 12, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C03', 3, 3, 'DESK-2', 1, 13, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C03', 4, 3, 'DESK-2', 1, 14, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C03', 5, 3, 'DESK-2', 1, 15, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C04', 1, 4, 'DESK-2', 2, 16, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C04', 2, 4, 'DESK-2', 2, 17, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C04', 3, 4, 'DESK-2', 2, 18, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C04', 4, 4, 'DESK-2', 2, 19, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C04', 5, 4, 'DESK-2', 2, 20, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C05', 1, 5, 'DESK-3', 1, 21, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C05', 2, 5, 'DESK-3', 1, 22, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C05', 3, 5, 'DESK-3', 1, 23, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C05', 4, 5, 'DESK-3', 1, 24, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C05', 5, 5, 'DESK-3', 1, 25, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C06', 1, 6, 'DESK-3', 2, 26, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C06', 2, 6, 'DESK-3', 2, 27, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C06', 3, 6, 'DESK-3', 2, 28, 1 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C06', 4, 6, 'DESK-3', 2, 29, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C06', 5, 6, 'DESK-3', 2, 30, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C07', 1, 7, 'DESK-4', 1, 31, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C07', 2, 7, 'DESK-4', 1, 32, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C07', 3, 7, 'DESK-4', 1, 33, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C07', 4, 7, 'DESK-4', 1, 34, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C07', 5, 7, 'DESK-4', 1, 35, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C08', 1, 8, 'DESK-4', 2, 36, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C08', 2, 8, 'DESK-4', 2, 37, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C08', 3, 8, 'DESK-4', 2, 38, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C08', 4, 8, 'DESK-4', 2, 39, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C08', 5, 8, 'DESK-4', 2, 40, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C09', 1, 9, 'DESK-5', 1, 41, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C09', 2, 9, 'DESK-5', 1, 42, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C09', 3, 9, 'DESK-5', 1, 43, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C09', 4, 9, 'DESK-5', 1, 44, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C09', 5, 9, 'DESK-5', 1, 45, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R01-C10', 1, 10, 'DESK-5', 2, 46, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R02-C10', 2, 10, 'DESK-5', 2, 47, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R03-C10', 3, 10, 'DESK-5', 2, 48, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R04-C10', 4, 10, 'DESK-5', 2, 49, 0 WHERE @seed2_room_id IS NOT NULL
UNION ALL SELECT @seed2_room_id, 'R05-C10', 5, 10, 'DESK-5', 2, 50, 0 WHERE @seed2_room_id IS NOT NULL;

-- Backfill missing curriculum mappings from the CSE fixture and demo papers.

INSERT INTO courses (code, name, status) VALUES
('CE103', 'Engineering Graphics', 'active'),
('CS101', 'Fundamentals of Computer Programming', 'active'),
('CS102', 'Computer Organization and Architecture', 'active'),
('CS105', 'Introduction to Artificial Intelligence', 'active'),
('CS181', 'Computer Programming Lab', 'active'),
('CS183', 'Computer Organization and Architecture Lab', 'active'),
('CS201', 'Internet Technology', 'active'),
('CS202', 'Software Engineering', 'active'),
('CS203', 'Concepts of Operating Systems', 'active'),
('CS204', 'Database Management System', 'active'),
('CS205', 'Data Structure and Algorithms', 'active'),
('CS206', 'Java Programming', 'active'),
('CS207', 'Problem Solving using C++', 'active'),
('CS208', 'Artificial Intelligence', 'active'),
('CS209', 'Logic Design', 'active'),
('CS210', 'Theory of Automata', 'active'),
('CS212', 'Discrete Structure', 'active'),
('CS281', 'Data Structure and Algorithms Lab', 'active'),
('CS282', 'Database Management System Lab', 'active'),
('CS283', 'Object- Oriented Programming Lab', 'active'),
('CS284', 'Java Programming Lab', 'active'),
('CS285', 'Logic Design Lab', 'active'),
('CS286', 'Artificial Intelligence Lab', 'active'),
('CS301', 'Computer Networks', 'active'),
('CS302', 'Web Development using PHP', 'active'),
('CS303', 'Compiler Design', 'active'),
('CS304', 'Software Testing', 'active'),
('CS305', 'Wireless Communication', 'active'),
('CS306', 'Analysis and Design of Algorithms', 'active'),
('CS307', 'Python', 'active'),
('CS308', 'Cyber Security', 'active'),
('CS309', 'Computer Graphics', 'active'),
('CS310', 'Digital Image Processing', 'active'),
('CS311', 'Computer Vision', 'active'),
('CS312', 'Adhoc & Sensor Networks', 'active'),
('CS313', 'Android Operating System', 'active'),
('CS314', 'Expert System', 'active'),
('CS315', 'Computer Based Numerical and Statistical Techniques', 'active'),
('CS316', 'Fault tolerant System', 'active'),
('CS317', 'Data Mining', 'active'),
('CS318', 'Mobile Computing', 'active'),
('CS319', 'System Analysis & Design', 'active'),
('CS320', 'Computer security', 'active'),
('CS321', 'Software Project Management', 'active'),
('CS322', 'Management Information system', 'active'),
('CS323', 'Information Retrieval System', 'active'),
('CS324', 'Evolutionary Computation', 'active'),
('CS325', 'Graph Theory', 'active'),
('CS326', 'Fuzzy logic', 'active'),
('CS327', 'Knowledge Engineering', 'active'),
('CS328', 'Big Data Analytics', 'active'),
('CS381', 'Computer Networks Lab', 'active'),
('CS382', 'Web Development using PHP Lab', 'active'),
('CS383', 'Compiler Design Lab', 'active'),
('CS384', 'Analysis and Design of Algorithms Lab', 'active'),
('CS385', 'Python Programming Lab', 'active'),
('CS386', 'Cyber Security Lab', 'active'),
('CS401', 'Internet of Things', 'active'),
('CS403', 'Soft Computing Techniques', 'active'),
('CS405', 'Machine Learning', 'active'),
('CS407', 'Pattern Recognition', 'active'),
('CS409', 'Robotics', 'active'),
('CS411', 'Optimization Techniques', 'active'),
('CS413', 'Cloud Computing', 'active'),
('CS415', 'Information Security', 'active'),
('CS481', 'Internet of Things Lab', 'active'),
('CS490', 'Seminar', 'active'),
('CS491', 'Minor Project', 'active'),
('CS492', 'Major Project', 'active'),
('CS493', 'Industrial Training', 'active'),
('CS494', 'Internship', 'active'),
('EC101', 'Basic Electronics Engineering', 'active'),
('EC181', 'Basic Electronics Engineering Lab', 'active'),
('EE102', 'Basic Electrical Engineering', 'active'),
('EE104', 'Basic Electrical Engineering Lab', 'active'),
('EN101', 'English Proficiency', 'active'),
('EN151', 'Language Lab', 'active'),
('ES101', 'Environmental Studies', 'active'),
('GP', 'General Proficiency', 'active'),
('ICS501', 'Integrated B.Tech Computer Science and Engineering - Core Concepts and Applications', 'active'),
('ICS502', 'Integrated B.Tech Computer Science and Engineering - Advanced Methods and Practice', 'active'),
('IEC501', 'Electronics and Communication Engineering - Core Concepts and Applications', 'active'),
('IEC502', 'Electronics and Communication Engineering - Advanced Methods and Practice', 'active'),
('LCS301', 'Computer Science and Engineering - Core Concepts and Applications', 'active'),
('LCS302', 'Computer Science and Engineering - Advanced Methods and Practice', 'active'),
('LEA301', 'Electronics AI and Machine Learning - Core Concepts and Applications', 'active'),
('LEA302', 'Electronics AI and Machine Learning - Advanced Methods and Practice', 'active'),
('LIT301', 'Information Technology - Core Concepts and Applications', 'active'),
('LIT302', 'Information Technology - Advanced Methods and Practice', 'active'),
('MA101', 'Engineering Mathematics-I', 'active'),
('MA102', 'Engineering Mathematics-II', 'active'),
('MA201', 'Engineering Mathematics- III', 'active'),
('MA401', 'Modeling and Simulation', 'active'),
('ME101', 'Engineering Mechanics', 'active'),
('ME102', 'Workshop Practice', 'active'),
('PCS101', 'Computer Science and Engineering - Core Concepts and Applications', 'active'),
('PCS102', 'Computer Science and Engineering - Advanced Methods and Practice', 'active'),
('PCW101', 'Computer Science and Engineering - Core Concepts and Applications', 'active'),
('PCW102', 'Computer Science and Engineering - Advanced Methods and Practice', 'active'),
('PH102', 'Engineering Physics', 'active'),
('PH104', 'Engineering Physics Lab', 'active'),
('UAI301', 'Artificial Intelligence - Core Concepts and Applications', 'active'),
('UAI302', 'Artificial Intelligence - Advanced Methods and Practice', 'active'),
('UCA301', 'Computer Applications - Core Concepts and Applications', 'active'),
('UCA302', 'Computer Applications - Advanced Methods and Practice', 'active'),
('UCC301', 'Cyber Security - Core Concepts and Applications', 'active'),
('UCC302', 'Cyber Security - Advanced Methods and Practice', 'active'),
('UCD301', 'Data Science - Core Concepts and Applications', 'active'),
('UCD302', 'Data Science - Advanced Methods and Practice', 'active'),
('UCM301', 'Machine Learning - Core Concepts and Applications', 'active'),
('UCM302', 'Machine Learning - Advanced Methods and Practice', 'active'),
('UCS501', 'Computer Science and Engineering - Core Concepts and Applications', 'active'),
('UCS502', 'Computer Science and Engineering - Advanced Methods and Practice', 'active'),
('UEA301', 'Electronics AI and Machine Learning - Core Concepts and Applications', 'active'),
('UEA302', 'Electronics AI and Machine Learning - Advanced Methods and Practice', 'active'),
('UEC301', 'Electronics and Communication Engineering - Core Concepts and Applications', 'active'),
('UEC302', 'Electronics and Communication Engineering - Advanced Methods and Practice', 'active'),
('UIT301', 'Information Technology - Core Concepts and Applications', 'active'),
('UIT302', 'Information Technology - Advanced Methods and Practice', 'active'),
('UVL301', 'VLSI Design and Embedded Systems - Core Concepts and Applications', 'active'),
('UVL302', 'VLSI Design and Embedded Systems - Advanced Methods and Practice', 'active')
ON DUPLICATE KEY UPDATE id = courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'CE103'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'CS101'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'CS102'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'CS105'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'CS181'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'CS183'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'CS201'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'CS202'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'CS203'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'CS204'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'CS205'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'CS206'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'CS207'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'CS208'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'CS209'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'CS210'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'CS212'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'CS281'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'CS282'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'CS283'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'CS284'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'CS285'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'CS286'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS301'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS302'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS303'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS304'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS305'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS306'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS307'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS308'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS309'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS310'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS311'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS312'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS313'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS314'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS315'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS316'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS317'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS318'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS319'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS320'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS321'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS322'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS323'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS324'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS325'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS326'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS327'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS328'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS381'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS382'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS383'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS384'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'CS385'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'CS386'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS401'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS403'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS405'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS407'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS409'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS411'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS413'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'elective', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS415'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS481'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 8, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(8/2)
FROM programmes p JOIN courses c ON c.code = 'CS490'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS491'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 8, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(8/2)
FROM programmes p JOIN courses c ON c.code = 'CS492'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'CS493'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 8, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(8/2)
FROM programmes p JOIN courses c ON c.code = 'CS494'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'EC101'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'EC181'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'EE102'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'EE104'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'EN101'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'EN151'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'ES101'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'common', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'GP'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'common', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'GP'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'common', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'GP'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 4, 'ALL', 'common', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(4/2)
FROM programmes p JOIN courses c ON c.code = 'GP'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'common', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'GP'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 6, 'ALL', 'common', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(6/2)
FROM programmes p JOIN courses c ON c.code = 'GP'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'common', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'GP'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 8, 'ALL', 'common', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(8/2)
FROM programmes p JOIN courses c ON c.code = 'GP'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'ICS501'
WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'ICS502'
WHERE p.code = 'ICS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'IEC501'
WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'IEC502'
WHERE p.code = 'IEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'LCS301'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'LCS302'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'LEA301'
WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'LEA302'
WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'LIT301'
WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'LIT302'
WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'MA101'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 2, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(2/2)
FROM programmes p JOIN courses c ON c.code = 'MA102'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'MA201'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 7, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(7/2)
FROM programmes p JOIN courses c ON c.code = 'MA401'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'ME101'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'ME102'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'PCS101'
WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'PCS102'
WHERE p.code = 'PCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'PCW101'
WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'PCW102'
WHERE p.code = 'PCW' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'PH102'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 1, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(1/2)
FROM programmes p JOIN courses c ON c.code = 'PH104'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UAI301'
WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UAI302'
WHERE p.code = 'UAI' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UCA301'
WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UCA302'
WHERE p.code = 'UCA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UCC301'
WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UCC302'
WHERE p.code = 'UCC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UCD301'
WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UCD302'
WHERE p.code = 'UCD' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UCM301'
WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UCM302'
WHERE p.code = 'UCM' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'UCS501'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 5, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(5/2)
FROM programmes p JOIN courses c ON c.code = 'UCS502'
WHERE p.code = 'UCS' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UEA301'
WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UEA302'
WHERE p.code = 'UEA' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UEC301'
WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UEC302'
WHERE p.code = 'UEC' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UIT301'
WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UIT302'
WHERE p.code = 'UIT' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UVL301'
WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

INSERT INTO programme_courses (programme_id, batch_id, course_id, semester, section, category, course_level, course_year)
SELECT p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), c.id, 3, 'ALL', 'core', IF(p.level = 'postgraduate', 'PG', 'UG'), CEIL(3/2)
FROM programmes p JOIN courses c ON c.code = 'UVL302'
WHERE p.code = 'UVL' AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL
ON DUPLICATE KEY UPDATE id = programme_courses.id;

-- Create the sample draft, calendar and shifts once using the active admin's real ID.
INSERT INTO exam_cycles (name, academic_year, exam_type, start_date, end_date, default_duration_minutes, status, created_by)
SELECT 'GBU Demo Mid-Semester 2026', '2026-2027', 'mid_sem', '2026-08-23', '2026-09-20', 90, 'draft', u.id
FROM users u JOIN roles r ON r.id = u.role_id
WHERE u.username = 'admin' AND u.status = 'active' AND r.code = 'admin'
AND NOT EXISTS (SELECT 1 FROM exam_cycles WHERE name = 'GBU Demo Mid-Semester 2026' AND academic_year = '2026-2027');
SET @seed2_cycle_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO exam_shifts (cycle_id, name, start_time, end_time, duration_minutes, sequence_no)
SELECT @seed2_cycle_id, 'Morning Shift', '09:30', '11:00', 90, 1 WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, 'Evening Shift', '14:00', '15:30', 90, 2 WHERE @seed2_cycle_id IS NOT NULL;

INSERT INTO exam_calendar_dates (cycle_id, exam_date, is_exam_day, day_type, note)
SELECT @seed2_cycle_id, '2026-08-23', 0, 'sunday', 'Sunday' WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-08-24', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-08-25', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-08-26', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-08-27', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-08-28', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-08-29', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-08-30', 0, 'sunday', 'Sunday' WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-08-31', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-01', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-02', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-03', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-04', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-05', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-06', 0, 'sunday', 'Sunday' WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-07', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-08', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-09', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-10', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-11', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-12', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-13', 0, 'sunday', 'Sunday' WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-14', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-15', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-16', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-17', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-18', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-19', 1, 'exam_day', NULL WHERE @seed2_cycle_id IS NOT NULL
UNION ALL SELECT @seed2_cycle_id, '2026-09-20', 0, 'sunday', 'Sunday' WHERE @seed2_cycle_id IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'ICS' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'IEC' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'PCS' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'PCW' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UAI' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UCA' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UCC' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UCD' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UCM' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UCS' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UCS' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UEA' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UEA' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UEC' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UIT' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UIT' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_cycle_batches (cycle_id, batch_id)
SELECT @seed2_cycle_id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) FROM programmes p
WHERE p.code = 'UVL' AND @seed2_cycle_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-24', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'ICS501'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 5, 'ALL', 'Integrated B.Tech Computer Science and Engineering Semester 5'
FROM programmes p WHERE p.code = 'ICS' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235ICS001', '235ICS002', '235ICS003', '235ICS004', '235ICS005', '235ICS006', '235ICS007', '235ICS008', '235ICS009', '235ICS010', '235ICS011', '235ICS012', '235ICS013', '235ICS014', '235ICS015', '235ICS016', '235ICS017', '235ICS018', '235ICS019', '235ICS020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-24', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'ICS502'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 5, 'ALL', 'Integrated B.Tech Computer Science and Engineering Semester 5'
FROM programmes p WHERE p.code = 'ICS' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235ICS001', '235ICS002', '235ICS003', '235ICS004', '235ICS005', '235ICS006', '235ICS007', '235ICS008', '235ICS009', '235ICS010', '235ICS011', '235ICS012', '235ICS013', '235ICS014', '235ICS015', '235ICS016', '235ICS017', '235ICS018', '235ICS019', '235ICS020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-25', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'IEC501'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 5, 'ALL', 'Integrated Electronics and Communication Engineering Semester 5'
FROM programmes p WHERE p.code = 'IEC' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235IEC001', '235IEC002', '235IEC003', '235IEC004', '235IEC005', '235IEC006', '235IEC007', '235IEC008', '235IEC009', '235IEC010', '235IEC011', '235IEC012', '235IEC013', '235IEC014', '235IEC015', '235IEC016', '235IEC017', '235IEC018', '235IEC019', '235IEC020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-25', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'IEC502'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 5, 'ALL', 'Integrated Electronics and Communication Engineering Semester 5'
FROM programmes p WHERE p.code = 'IEC' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235IEC001', '235IEC002', '235IEC003', '235IEC004', '235IEC005', '235IEC006', '235IEC007', '235IEC008', '235IEC009', '235IEC010', '235IEC011', '235IEC012', '235IEC013', '235IEC014', '235IEC015', '235IEC016', '235IEC017', '235IEC018', '235IEC019', '235IEC020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-26', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'LCS301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'CSE Lateral Entry Semester 3'
FROM programmes p WHERE p.code = 'UCS' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235LCS001', '235LCS002', '235LCS003', '235LCS004', '235LCS005', '235LCS006', '235LCS007', '235LCS008', '235LCS009', '235LCS010', '235LCS011', '235LCS012', '235LCS013', '235LCS014', '235LCS015', '235LCS016', '235LCS017', '235LCS018', '235LCS019', '235LCS020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-26', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'LCS302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'CSE Lateral Entry Semester 3'
FROM programmes p WHERE p.code = 'UCS' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235LCS001', '235LCS002', '235LCS003', '235LCS004', '235LCS005', '235LCS006', '235LCS007', '235LCS008', '235LCS009', '235LCS010', '235LCS011', '235LCS012', '235LCS013', '235LCS014', '235LCS015', '235LCS016', '235LCS017', '235LCS018', '235LCS019', '235LCS020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-27', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'LEA301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'ECE AI and ML Lateral Entry Semester 3'
FROM programmes p WHERE p.code = 'UEA' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235LEA001', '235LEA002', '235LEA003', '235LEA004', '235LEA005', '235LEA006', '235LEA007', '235LEA008', '235LEA009', '235LEA010', '235LEA011', '235LEA012', '235LEA013', '235LEA014', '235LEA015', '235LEA016', '235LEA017', '235LEA018', '235LEA019', '235LEA020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-27', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'LEA302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'ECE AI and ML Lateral Entry Semester 3'
FROM programmes p WHERE p.code = 'UEA' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235LEA001', '235LEA002', '235LEA003', '235LEA004', '235LEA005', '235LEA006', '235LEA007', '235LEA008', '235LEA009', '235LEA010', '235LEA011', '235LEA012', '235LEA013', '235LEA014', '235LEA015', '235LEA016', '235LEA017', '235LEA018', '235LEA019', '235LEA020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-28', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'LIT301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'IT Lateral Entry Semester 3'
FROM programmes p WHERE p.code = 'UIT' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235LIT001', '235LIT002', '235LIT003', '235LIT004', '235LIT005', '235LIT006', '235LIT007', '235LIT008', '235LIT009', '235LIT010', '235LIT011', '235LIT012', '235LIT013', '235LIT014', '235LIT015', '235LIT016', '235LIT017', '235LIT018', '235LIT019', '235LIT020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-28', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'LIT302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'IT Lateral Entry Semester 3'
FROM programmes p WHERE p.code = 'UIT' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2022 AND end_year = 2022 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235LIT001', '235LIT002', '235LIT003', '235LIT004', '235LIT005', '235LIT006', '235LIT007', '235LIT008', '235LIT009', '235LIT010', '235LIT011', '235LIT012', '235LIT013', '235LIT014', '235LIT015', '235LIT016', '235LIT017', '235LIT018', '235LIT019', '235LIT020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-29', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'PCS101'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 1, 'ALL', 'M.Tech Computer Science and Engineering Semester 1'
FROM programmes p WHERE p.code = 'PCS' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235PCS001', '235PCS002', '235PCS003', '235PCS004', '235PCS005', '235PCS006', '235PCS007', '235PCS008', '235PCS009', '235PCS010', '235PCS011', '235PCS012', '235PCS013', '235PCS014', '235PCS015', '235PCS016', '235PCS017', '235PCS018', '235PCS019', '235PCS020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-29', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'PCS102'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 1, 'ALL', 'M.Tech Computer Science and Engineering Semester 1'
FROM programmes p WHERE p.code = 'PCS' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235PCS001', '235PCS002', '235PCS003', '235PCS004', '235PCS005', '235PCS006', '235PCS007', '235PCS008', '235PCS009', '235PCS010', '235PCS011', '235PCS012', '235PCS013', '235PCS014', '235PCS015', '235PCS016', '235PCS017', '235PCS018', '235PCS019', '235PCS020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-31', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'PCW101'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 1, 'ALL', 'M.Tech CSE Working Professional Semester 1'
FROM programmes p WHERE p.code = 'PCW' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235PCW001', '235PCW002', '235PCW003', '235PCW004', '235PCW005', '235PCW006', '235PCW007', '235PCW008', '235PCW009', '235PCW010', '235PCW011', '235PCW012', '235PCW013', '235PCW014', '235PCW015', '235PCW016', '235PCW017', '235PCW018', '235PCW019', '235PCW020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-08-31', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'PCW102'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 1, 'ALL', 'M.Tech CSE Working Professional Semester 1'
FROM programmes p WHERE p.code = 'PCW' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235PCW001', '235PCW002', '235PCW003', '235PCW004', '235PCW005', '235PCW006', '235PCW007', '235PCW008', '235PCW009', '235PCW010', '235PCW011', '235PCW012', '235PCW013', '235PCW014', '235PCW015', '235PCW016', '235PCW017', '235PCW018', '235PCW019', '235PCW020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-01', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UAI301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Artificial Intelligence Semester 3'
FROM programmes p WHERE p.code = 'UAI' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UAI001', '235UAI002', '235UAI003', '235UAI004', '235UAI005', '235UAI006', '235UAI007', '235UAI008', '235UAI009', '235UAI010', '235UAI011', '235UAI012', '235UAI013', '235UAI014', '235UAI015', '235UAI016', '235UAI017', '235UAI018', '235UAI019', '235UAI020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-01', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UAI302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Artificial Intelligence Semester 3'
FROM programmes p WHERE p.code = 'UAI' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UAI001', '235UAI002', '235UAI003', '235UAI004', '235UAI005', '235UAI006', '235UAI007', '235UAI008', '235UAI009', '235UAI010', '235UAI011', '235UAI012', '235UAI013', '235UAI014', '235UAI015', '235UAI016', '235UAI017', '235UAI018', '235UAI019', '235UAI020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-02', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCA301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'Bachelor of Computer Applications Semester 3'
FROM programmes p WHERE p.code = 'UCA' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCA001', '235UCA002', '235UCA003', '235UCA004', '235UCA005', '235UCA006', '235UCA007', '235UCA008', '235UCA009', '235UCA010', '235UCA011', '235UCA012', '235UCA013', '235UCA014', '235UCA015', '235UCA016', '235UCA017', '235UCA018', '235UCA019', '235UCA020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-02', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCA302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'Bachelor of Computer Applications Semester 3'
FROM programmes p WHERE p.code = 'UCA' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCA001', '235UCA002', '235UCA003', '235UCA004', '235UCA005', '235UCA006', '235UCA007', '235UCA008', '235UCA009', '235UCA010', '235UCA011', '235UCA012', '235UCA013', '235UCA014', '235UCA015', '235UCA016', '235UCA017', '235UCA018', '235UCA019', '235UCA020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-03', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCC301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Cyber Security Semester 3'
FROM programmes p WHERE p.code = 'UCC' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCC001', '235UCC002', '235UCC003', '235UCC004', '235UCC005', '235UCC006', '235UCC007', '235UCC008', '235UCC009', '235UCC010', '235UCC011', '235UCC012', '235UCC013', '235UCC014', '235UCC015', '235UCC016', '235UCC017', '235UCC018', '235UCC019', '235UCC020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-03', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCC302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Cyber Security Semester 3'
FROM programmes p WHERE p.code = 'UCC' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCC001', '235UCC002', '235UCC003', '235UCC004', '235UCC005', '235UCC006', '235UCC007', '235UCC008', '235UCC009', '235UCC010', '235UCC011', '235UCC012', '235UCC013', '235UCC014', '235UCC015', '235UCC016', '235UCC017', '235UCC018', '235UCC019', '235UCC020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-04', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCD301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Data Science Semester 3'
FROM programmes p WHERE p.code = 'UCD' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCD001', '235UCD002', '235UCD003', '235UCD004', '235UCD005', '235UCD006', '235UCD007', '235UCD008', '235UCD009', '235UCD010', '235UCD011', '235UCD012', '235UCD013', '235UCD014', '235UCD015', '235UCD016', '235UCD017', '235UCD018', '235UCD019', '235UCD020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-04', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCD302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Data Science Semester 3'
FROM programmes p WHERE p.code = 'UCD' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCD001', '235UCD002', '235UCD003', '235UCD004', '235UCD005', '235UCD006', '235UCD007', '235UCD008', '235UCD009', '235UCD010', '235UCD011', '235UCD012', '235UCD013', '235UCD014', '235UCD015', '235UCD016', '235UCD017', '235UCD018', '235UCD019', '235UCD020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-05', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCM301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Machine Learning Semester 3'
FROM programmes p WHERE p.code = 'UCM' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCM001', '235UCM002', '235UCM003', '235UCM004', '235UCM005', '235UCM006', '235UCM007', '235UCM008', '235UCM009', '235UCM010', '235UCM011', '235UCM012', '235UCM013', '235UCM014', '235UCM015', '235UCM016', '235UCM017', '235UCM018', '235UCM019', '235UCM020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-05', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCM302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Machine Learning Semester 3'
FROM programmes p WHERE p.code = 'UCM' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCM001', '235UCM002', '235UCM003', '235UCM004', '235UCM005', '235UCM006', '235UCM007', '235UCM008', '235UCM009', '235UCM010', '235UCM011', '235UCM012', '235UCM013', '235UCM014', '235UCM015', '235UCM016', '235UCM017', '235UCM018', '235UCM019', '235UCM020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-07', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCS501'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 5, 'ALL', 'B.Tech Computer Science and Engineering Semester 5'
FROM programmes p WHERE p.code = 'UCS' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCS001', '235UCS002', '235UCS003', '235UCS004', '235UCS005', '235UCS006', '235UCS007', '235UCS008', '235UCS009', '235UCS010', '235UCS011', '235UCS012', '235UCS013', '235UCS014', '235UCS015', '235UCS016', '235UCS017', '235UCS018', '235UCS019', '235UCS020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-07', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UCS502'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 5, 'ALL', 'B.Tech Computer Science and Engineering Semester 5'
FROM programmes p WHERE p.code = 'UCS' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UCS001', '235UCS002', '235UCS003', '235UCS004', '235UCS005', '235UCS006', '235UCS007', '235UCS008', '235UCS009', '235UCS010', '235UCS011', '235UCS012', '235UCS013', '235UCS014', '235UCS015', '235UCS016', '235UCS017', '235UCS018', '235UCS019', '235UCS020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-08', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UEA301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech ECE Artificial Intelligence and Machine Learning Semester 3'
FROM programmes p WHERE p.code = 'UEA' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UEA001', '235UEA002', '235UEA003', '235UEA004', '235UEA005', '235UEA006', '235UEA007', '235UEA008', '235UEA009', '235UEA010', '235UEA011', '235UEA012', '235UEA013', '235UEA014', '235UEA015', '235UEA016', '235UEA017', '235UEA018', '235UEA019', '235UEA020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-08', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UEA302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech ECE Artificial Intelligence and Machine Learning Semester 3'
FROM programmes p WHERE p.code = 'UEA' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UEA001', '235UEA002', '235UEA003', '235UEA004', '235UEA005', '235UEA006', '235UEA007', '235UEA008', '235UEA009', '235UEA010', '235UEA011', '235UEA012', '235UEA013', '235UEA014', '235UEA015', '235UEA016', '235UEA017', '235UEA018', '235UEA019', '235UEA020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-09', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UEC301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Electronics and Communication Engineering Semester 3'
FROM programmes p WHERE p.code = 'UEC' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UEC001', '235UEC002', '235UEC003', '235UEC004', '235UEC005', '235UEC006', '235UEC007', '235UEC008', '235UEC009', '235UEC010', '235UEC011', '235UEC012', '235UEC013', '235UEC014', '235UEC015', '235UEC016', '235UEC017', '235UEC018', '235UEC019', '235UEC020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-09', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UEC302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Electronics and Communication Engineering Semester 3'
FROM programmes p WHERE p.code = 'UEC' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UEC001', '235UEC002', '235UEC003', '235UEC004', '235UEC005', '235UEC006', '235UEC007', '235UEC008', '235UEC009', '235UEC010', '235UEC011', '235UEC012', '235UEC013', '235UEC014', '235UEC015', '235UEC016', '235UEC017', '235UEC018', '235UEC019', '235UEC020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-10', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UIT301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Information Technology Semester 3'
FROM programmes p WHERE p.code = 'UIT' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UIT001', '235UIT002', '235UIT003', '235UIT004', '235UIT005', '235UIT006', '235UIT007', '235UIT008', '235UIT009', '235UIT010', '235UIT011', '235UIT012', '235UIT013', '235UIT014', '235UIT015', '235UIT016', '235UIT017', '235UIT018', '235UIT019', '235UIT020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-10', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UIT302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech Information Technology Semester 3'
FROM programmes p WHERE p.code = 'UIT' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UIT001', '235UIT002', '235UIT003', '235UIT004', '235UIT005', '235UIT006', '235UIT007', '235UIT008', '235UIT009', '235UIT010', '235UIT011', '235UIT012', '235UIT013', '235UIT014', '235UIT015', '235UIT016', '235UIT017', '235UIT018', '235UIT019', '235UIT020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-11', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UVL301'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Morning Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech ECE VLSI Design and Embedded Systems Semester 3'
FROM programmes p WHERE p.code = 'UVL' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UVL001', '235UVL002', '235UVL003', '235UVL004', '235UVL005', '235UVL006', '235UVL007', '235UVL008', '235UVL009', '235UVL010', '235UVL011', '235UVL012', '235UVL013', '235UVL014', '235UVL015', '235UVL016', '235UVL017', '235UVL018', '235UVL019', '235UVL020');

INSERT INTO examinations (cycle_id, shift_id, course_id, exam_date, category, status, generation_source)
SELECT @seed2_cycle_id, s.id, c.id, '2026-09-11', 'regular', 'draft', 'import'
FROM exam_shifts s JOIN courses c ON c.code = 'UVL302'
WHERE s.cycle_id = @seed2_cycle_id AND s.name = 'Evening Shift';
SET @seed2_exam_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);

INSERT INTO examination_cohorts (examination_id, programme_id, batch_id, semester, section, display_label)
SELECT @seed2_exam_id, p.id, (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)), 3, 'ALL', 'B.Tech ECE VLSI Design and Embedded Systems Semester 3'
FROM programmes p WHERE p.code = 'UVL' AND @seed2_exam_id IS NOT NULL AND (SELECT MIN(id) FROM batches WHERE programme_id = p.id AND start_year = 2023 AND end_year = 2023 + CEIL(p.duration_semesters / 2)) IS NOT NULL;

INSERT INTO exam_eligibility (examination_id, student_id, eligibility_status, source)
SELECT e.examination_id, s.id, 'eligible', 'cohort'
FROM examination_cohorts e JOIN students s ON s.programme_id = e.programme_id AND s.batch_id = e.batch_id AND s.semester = e.semester
WHERE e.examination_id = @seed2_exam_id AND s.status = 'active' AND s.normalized_roll_no IN ('235UVL001', '235UVL002', '235UVL003', '235UVL004', '235UVL005', '235UVL006', '235UVL007', '235UVL008', '235UVL009', '235UVL010', '235UVL011', '235UVL012', '235UVL013', '235UVL014', '235UVL015', '235UVL016', '235UVL017', '235UVL018', '235UVL019', '235UVL020');

COMMIT;

SELECT id, username, status FROM users WHERE username = 'admin';
SELECT id, name, status FROM exam_cycles WHERE name = 'GBU Demo Mid-Semester 2026';
