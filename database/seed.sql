-- Import this file while the target application database is selected.
-- No database name is hard-coded, so the same seed works with hosted database names.
INSERT INTO roles (code, name) VALUES
('admin', 'System Administrator'),
('examination_controller', 'Controller of Examinations'),
('academic_coordinator', 'Academic Coordinator'),
('seating_coordinator', 'Seating Coordinator'),
('invigilation_coordinator', 'Invigilation Coordinator'),
('faculty', 'Faculty / Invigilator'),
('auditor', 'Audit and Compliance Viewer'),
('viewer', 'Authorized Read-only Viewer')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT IGNORE INTO schools (code, name, short_name) VALUES
('SOM', 'School of Management', 'Management'),
('SOBT', 'School of Biotechnology', 'Biotechnology'),
('ICT', 'School of Information and Communication Technology', 'SOICT'),
('SOE', 'School of Engineering', 'Engineering'),
('SOVSAS', 'School of Vocational Studies and Applied Sciences', 'Vocational & Applied Sciences'),
('SOHSS', 'School of Humanities and Social Sciences', 'Humanities & Social Sciences'),
('SOBSC', 'School of Buddhist Studies and Civilization', 'Buddhist Studies'),
('SOLJG', 'School of Law, Justice and Governance', 'Law, Justice & Governance');

INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UCS', 'B.Tech Computer Science and Engineering', 'undergraduate', 8, 0, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UCM', 'B.Tech Machine Learning', 'undergraduate', 8, 0, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UCD', 'B.Tech Data Science', 'undergraduate', 8, 0, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UCC', 'B.Tech Cyber Security', 'undergraduate', 8, 0, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UAI', 'B.Tech Artificial Intelligence', 'undergraduate', 8, 0, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UIT', 'B.Tech Information Technology', 'undergraduate', 8, 0, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UCA', 'Bachelor of Computer Applications', 'undergraduate', 6, 0, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'LCS', 'CSE Lateral Entry', 'undergraduate', 6, 1, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'LIT', 'IT Lateral Entry', 'undergraduate', 6, 1, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'PCS', 'M.Tech Computer Science and Engineering', 'postgraduate', 4, 0, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'PCW', 'M.Tech CSE Working Professional', 'postgraduate', 4, 0, 0, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'ICS', 'Integrated B.Tech Computer Science and Engineering', 'integrated', 10, 0, 1, 'active' FROM schools WHERE code='ICT';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UEC', 'B.Tech Electronics and Communication Engineering', 'undergraduate', 8, 0, 0, 'active' FROM schools WHERE code='SOE';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UVL', 'B.Tech ECE VLSI Design and Embedded Systems', 'undergraduate', 8, 0, 0, 'active' FROM schools WHERE code='SOE';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'UEA', 'B.Tech ECE Artificial Intelligence and Machine Learning', 'undergraduate', 8, 0, 0, 'active' FROM schools WHERE code='SOE';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'LEA', 'ECE AI and ML Lateral Entry', 'undergraduate', 6, 1, 0, 'active' FROM schools WHERE code='SOE';
INSERT IGNORE INTO programmes (school_id, code, name, level, duration_semesters, lateral_entry, legacy, status)
SELECT id, 'IEC', 'Integrated Electronics and Communication Engineering', 'integrated', 10, 0, 1, 'active' FROM schools WHERE code='SOE';

-- B.Tech Computer Science and Engineering (UCS), Self Finance curriculum
-- Effective from session 2022-23, 29th BOS dated 25 March 2023.
-- A short-lived regular staging table is used because some shared hosts do not
-- grant the CREATE TEMPORARY TABLES privilege.
DROP TABLE IF EXISTS seed_ucs_curriculum;
CREATE TABLE seed_ucs_curriculum (
  course_code VARCHAR(40) NOT NULL,
  course_name VARCHAR(255) NOT NULL,
  semester TINYINT UNSIGNED NOT NULL,
  category ENUM('core','elective','bridge','common','back_paper','other') NOT NULL
);
INSERT INTO seed_ucs_curriculum (course_code,course_name,semester,category) VALUES
('MA101','Engineering Mathematics-I',1,'core'),
('PH102','Engineering Physics',1,'core'),
('EE102','Basic Electrical Engineering',1,'core'),
('ME101','Engineering Mechanics',1,'core'),
('ES101','Environmental Studies',1,'core'),
('PH104','Engineering Physics Lab',1,'core'),
('EE104','Basic Electrical Engineering Lab',1,'core'),
('EN151','Language Lab',1,'core'),
('ME102','Workshop Practice',1,'core'),
('GP','General Proficiency',1,'common'),
('CS101','Fundamentals of Computer Programming',2,'core'),
('CS102','Computer Organization and Architecture',2,'core'),
('MA102','Engineering Mathematics-II',2,'core'),
('EC101','Basic Electronics Engineering',2,'core'),
('CS105','Introduction to Artificial Intelligence',2,'core'),
('EN101','English Proficiency',2,'core'),
('CE103','Engineering Graphics',2,'core'),
('CS181','Computer Programming Lab',2,'core'),
('CS183','Computer Organization and Architecture Lab',2,'core'),
('EC181','Basic Electronics Engineering Lab',2,'core'),
('GP','General Proficiency',2,'common'),
('CS201','Internet Technology',3,'core'),
('CS203','Concepts of Operating Systems',3,'core'),
('CS205','Data Structure and Algorithms',3,'core'),
('CS207','Problem Solving using C++',3,'core'),
('CS209','Logic Design',3,'core'),
('MA201','Engineering Mathematics- III',3,'core'),
('CS281','Data Structure and Algorithms Lab',3,'core'),
('CS283','Object- Oriented Programming Lab',3,'core'),
('CS285','Logic Design Lab',3,'core'),
('GP','General Proficiency',3,'common'),
('CS202','Software Engineering',4,'core'),
('CS204','Database Management System',4,'core'),
('CS206','Java Programming',4,'core'),
('CS208','Artificial Intelligence',4,'core'),
('CS210','Theory of Automata',4,'core'),
('CS212','Discrete Structure',4,'core'),
('CS282','Database Management System Lab',4,'core'),
('CS284','Java Programming Lab',4,'core'),
('CS286','Artificial Intelligence Lab',4,'core'),
('GP','General Proficiency',4,'common'),
('CS301','Computer Networks',5,'core'),
('CS303','Compiler Design',5,'core'),
('CS305','Wireless Communication',5,'core'),
('CS307','Python',5,'core'),
('CS381','Computer Networks Lab',5,'core'),
('CS383','Compiler Design Lab',5,'core'),
('CS385','Python Programming Lab',5,'core'),
('GP','General Proficiency',5,'common'),
('CS309','Computer Graphics',5,'elective'),
('CS311','Computer Vision',5,'elective'),
('CS313','Android Operating System',5,'elective'),
('CS315','Computer Based Numerical and Statistical Techniques',5,'elective'),
('CS317','Data Mining',5,'elective'),
('CS319','System Analysis & Design',5,'elective'),
('CS321','Software Project Management',5,'elective'),
('CS323','Information Retrieval System',5,'elective'),
('CS325','Graph Theory',5,'elective'),
('CS327','Knowledge Engineering',5,'elective'),
('CS302','Web Development using PHP',6,'core'),
('CS304','Software Testing',6,'core'),
('CS306','Analysis and Design of Algorithms',6,'core'),
('CS308','Cyber Security',6,'core'),
('CS382','Web Development using PHP Lab',6,'core'),
('CS384','Analysis and Design of Algorithms Lab',6,'core'),
('CS386','Cyber Security Lab',6,'core'),
('GP','General Proficiency',6,'common'),
('CS310','Digital Image Processing',6,'elective'),
('CS312','Adhoc & Sensor Networks',6,'elective'),
('CS314','Expert System',6,'elective'),
('CS316','Fault tolerant System',6,'elective'),
('CS318','Mobile Computing',6,'elective'),
('CS320','Computer security',6,'elective'),
('CS322','Management Information system',6,'elective'),
('CS324','Evolutionary Computation',6,'elective'),
('CS326','Fuzzy logic',6,'elective'),
('CS328','Big Data Analytics',6,'elective'),
('MA401','Modeling and Simulation',7,'core'),
('CS401','Internet of Things',7,'core'),
('CS403','Soft Computing Techniques',7,'core'),
('CS405','Machine Learning',7,'core'),
('CS481','Internet of Things Lab',7,'core'),
('CS491','Minor Project',7,'core'),
('CS493','Industrial Training',7,'core'),
('GP','General Proficiency',7,'common'),
('CS407','Pattern Recognition',7,'elective'),
('CS409','Robotics',7,'elective'),
('CS411','Optimization Techniques',7,'elective'),
('CS413','Cloud Computing',7,'elective'),
('CS415','Information Security',7,'elective'),
('CS490','Seminar',8,'core'),
('CS492','Major Project',8,'core'),
('CS494','Internship',8,'core'),
('GP','General Proficiency',8,'common');

INSERT INTO courses (code,name,status)
SELECT course_code,course_name,'active' FROM seed_ucs_curriculum
ON DUPLICATE KEY UPDATE name=VALUES(name),status='active';

INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,s.semester,s.category
FROM seed_ucs_curriculum s
JOIN programmes p ON p.code='UCS'
JOIN courses c ON c.code=s.course_code
ON DUPLICATE KEY UPDATE category=VALUES(category);

DROP TABLE seed_ucs_curriculum;

INSERT IGNORE INTO system_settings (setting_key, setting_value, value_type) VALUES
('university_name', 'Gautam Buddha University', 'string'),
('university_location', 'Greater Noida, Uttar Pradesh', 'string'),
('default_mid_sem_duration_minutes', '90', 'integer'),
('default_end_sem_duration_minutes', '180', 'integer'),
('default_seating_order', 'column_major', 'string'),
('allocation_versioning_enabled', 'true', 'boolean');
