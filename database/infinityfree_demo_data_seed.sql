-- GBU hosted demo data seed for phpMyAdmin
-- Repeatable: existing records are updated by their unique identifiers.
-- Contains 340 students, 64 faculty members, and 94 UCS curriculum mappings.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

INSERT INTO schools (code,name,short_name,status) VALUES
('SOM','School of Management','Management','active'),
('SOBT','School of Biotechnology','Biotechnology','active'),
('ICT','School of Information and Communication Technology','SOICT','active'),
('SOE','School of Engineering','Engineering','active'),
('SOVSAS','School of Vocational Studies and Applied Sciences','Vocational & Applied Sciences','active'),
('SOHSS','School of Humanities and Social Sciences','Humanities & Social Sciences','active'),
('SOBSC','School of Buddhist Studies and Civilization','Buddhist Studies','active'),
('SOLJG','School of Law, Justice and Governance','Law, Justice & Governance','active')
ON DUPLICATE KEY UPDATE name=VALUES(name),short_name=VALUES(short_name),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UCS','B.Tech Computer Science and Engineering','undergraduate',8,0,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UCM','B.Tech Machine Learning','undergraduate',8,0,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UCD','B.Tech Data Science','undergraduate',8,0,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UCC','B.Tech Cyber Security','undergraduate',8,0,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UAI','B.Tech Artificial Intelligence','undergraduate',8,0,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UIT','B.Tech Information Technology','undergraduate',8,0,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UCA','Bachelor of Computer Applications','undergraduate',6,0,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'LCS','CSE Lateral Entry','undergraduate',6,1,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'LIT','IT Lateral Entry','undergraduate',6,1,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'PCS','M.Tech Computer Science and Engineering','postgraduate',4,0,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'PCW','M.Tech CSE Working Professional','postgraduate',4,0,0,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'ICS','Integrated B.Tech Computer Science and Engineering','integrated',10,0,1,'active' FROM schools WHERE code='ICT'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UEC','B.Tech Electronics and Communication Engineering','undergraduate',8,0,0,'active' FROM schools WHERE code='SOE'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UVL','B.Tech ECE VLSI Design and Embedded Systems','undergraduate',8,0,0,'active' FROM schools WHERE code='SOE'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'UEA','B.Tech ECE Artificial Intelligence and Machine Learning','undergraduate',8,0,0,'active' FROM schools WHERE code='SOE'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'LEA','ECE AI and ML Lateral Entry','undergraduate',6,1,0,'active' FROM schools WHERE code='SOE'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO programmes (school_id,code,name,level,duration_semesters,lateral_entry,legacy,status)
SELECT id,'IEC','Integrated Electronics and Communication Engineering','integrated',10,0,1,'active' FROM schools WHERE code='SOE'
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),level=VALUES(level),duration_semesters=VALUES(duration_semesters),lateral_entry=VALUES(lateral_entry),legacy=VALUES(legacy),status='active';

INSERT INTO courses (code,name,status) VALUES
('MA101','Engineering Mathematics-I','active'),
('PH102','Engineering Physics','active'),
('EE102','Basic Electrical Engineering','active'),
('ME101','Engineering Mechanics','active'),
('ES101','Environmental Studies','active'),
('PH104','Engineering Physics Lab','active'),
('EE104','Basic Electrical Engineering Lab','active'),
('EN151','Language Lab','active'),
('ME102','Workshop Practice','active'),
('GP','General Proficiency','active'),
('CS101','Fundamentals of Computer Programming','active'),
('CS102','Computer Organization and Architecture','active'),
('MA102','Engineering Mathematics-II','active'),
('EC101','Basic Electronics Engineering','active'),
('CS105','Introduction to Artificial Intelligence','active'),
('EN101','English Proficiency','active'),
('CE103','Engineering Graphics','active'),
('CS181','Computer Programming Lab','active'),
('CS183','Computer Organization and Architecture Lab','active'),
('EC181','Basic Electronics Engineering Lab','active'),
('GP','General Proficiency','active'),
('CS201','Internet Technology','active'),
('CS203','Concepts of Operating Systems','active'),
('CS205','Data Structure and Algorithms','active'),
('CS207','Problem Solving using C++','active'),
('CS209','Logic Design','active'),
('MA201','Engineering Mathematics- III','active'),
('CS281','Data Structure and Algorithms Lab','active'),
('CS283','Object- Oriented Programming Lab','active'),
('CS285','Logic Design Lab','active'),
('GP','General Proficiency','active'),
('CS202','Software Engineering','active'),
('CS204','Database Management System','active'),
('CS206','Java Programming','active'),
('CS208','Artificial Intelligence','active'),
('CS210','Theory of Automata','active'),
('CS212','Discrete Structure','active'),
('CS282','Database Management System Lab','active'),
('CS284','Java Programming Lab','active'),
('CS286','Artificial Intelligence Lab','active'),
('GP','General Proficiency','active'),
('CS301','Computer Networks','active'),
('CS303','Compiler Design','active'),
('CS305','Wireless Communication','active'),
('CS307','Python','active'),
('CS381','Computer Networks Lab','active'),
('CS383','Compiler Design Lab','active'),
('CS385','Python Programming Lab','active'),
('GP','General Proficiency','active'),
('CS309','Computer Graphics','active'),
('CS311','Computer Vision','active'),
('CS313','Android Operating System','active'),
('CS315','Computer Based Numerical and Statistical Techniques','active'),
('CS317','Data Mining','active'),
('CS319','System Analysis & Design','active'),
('CS321','Software Project Management','active'),
('CS323','Information Retrieval System','active'),
('CS325','Graph Theory','active'),
('CS327','Knowledge Engineering','active'),
('CS302','Web Development using PHP','active'),
('CS304','Software Testing','active'),
('CS306','Analysis and Design of Algorithms','active'),
('CS308','Cyber Security','active'),
('CS382','Web Development using PHP Lab','active'),
('CS384','Analysis and Design of Algorithms Lab','active'),
('CS386','Cyber Security Lab','active'),
('GP','General Proficiency','active'),
('CS310','Digital Image Processing','active'),
('CS312','Adhoc & Sensor Networks','active'),
('CS314','Expert System','active'),
('CS316','Fault tolerant System','active'),
('CS318','Mobile Computing','active'),
('CS320','Computer security','active'),
('CS322','Management Information system','active'),
('CS324','Evolutionary Computation','active'),
('CS326','Fuzzy logic','active'),
('CS328','Big Data Analytics','active'),
('MA401','Modeling and Simulation','active'),
('CS401','Internet of Things','active'),
('CS403','Soft Computing Techniques','active'),
('CS405','Machine Learning','active'),
('CS481','Internet of Things Lab','active'),
('CS491','Minor Project','active'),
('CS493','Industrial Training','active'),
('GP','General Proficiency','active'),
('CS407','Pattern Recognition','active'),
('CS409','Robotics','active'),
('CS411','Optimization Techniques','active'),
('CS413','Cloud Computing','active'),
('CS415','Information Security','active'),
('CS490','Seminar','active'),
('CS492','Major Project','active'),
('CS494','Internship','active'),
('GP','General Proficiency','active')
ON DUPLICATE KEY UPDATE name=VALUES(name),status=VALUES(status);

INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'core' FROM programmes p JOIN courses c ON c.code='MA101' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'core' FROM programmes p JOIN courses c ON c.code='PH102' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'core' FROM programmes p JOIN courses c ON c.code='EE102' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'core' FROM programmes p JOIN courses c ON c.code='ME101' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'core' FROM programmes p JOIN courses c ON c.code='ES101' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'core' FROM programmes p JOIN courses c ON c.code='PH104' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'core' FROM programmes p JOIN courses c ON c.code='EE104' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'core' FROM programmes p JOIN courses c ON c.code='EN151' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'core' FROM programmes p JOIN courses c ON c.code='ME102' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,1,'common' FROM programmes p JOIN courses c ON c.code='GP' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='CS101' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='CS102' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='MA102' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='EC101' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='CS105' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='EN101' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='CE103' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='CS181' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='CS183' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'core' FROM programmes p JOIN courses c ON c.code='EC181' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,2,'common' FROM programmes p JOIN courses c ON c.code='GP' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'core' FROM programmes p JOIN courses c ON c.code='CS201' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'core' FROM programmes p JOIN courses c ON c.code='CS203' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'core' FROM programmes p JOIN courses c ON c.code='CS205' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'core' FROM programmes p JOIN courses c ON c.code='CS207' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'core' FROM programmes p JOIN courses c ON c.code='CS209' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'core' FROM programmes p JOIN courses c ON c.code='MA201' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'core' FROM programmes p JOIN courses c ON c.code='CS281' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'core' FROM programmes p JOIN courses c ON c.code='CS283' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'core' FROM programmes p JOIN courses c ON c.code='CS285' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,3,'common' FROM programmes p JOIN courses c ON c.code='GP' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'core' FROM programmes p JOIN courses c ON c.code='CS202' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'core' FROM programmes p JOIN courses c ON c.code='CS204' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'core' FROM programmes p JOIN courses c ON c.code='CS206' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'core' FROM programmes p JOIN courses c ON c.code='CS208' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'core' FROM programmes p JOIN courses c ON c.code='CS210' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'core' FROM programmes p JOIN courses c ON c.code='CS212' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'core' FROM programmes p JOIN courses c ON c.code='CS282' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'core' FROM programmes p JOIN courses c ON c.code='CS284' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'core' FROM programmes p JOIN courses c ON c.code='CS286' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,4,'common' FROM programmes p JOIN courses c ON c.code='GP' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'core' FROM programmes p JOIN courses c ON c.code='CS301' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'core' FROM programmes p JOIN courses c ON c.code='CS303' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'core' FROM programmes p JOIN courses c ON c.code='CS305' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'core' FROM programmes p JOIN courses c ON c.code='CS307' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'core' FROM programmes p JOIN courses c ON c.code='CS381' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'core' FROM programmes p JOIN courses c ON c.code='CS383' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'core' FROM programmes p JOIN courses c ON c.code='CS385' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'common' FROM programmes p JOIN courses c ON c.code='GP' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS309' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS311' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS313' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS315' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS317' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS319' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS321' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS323' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS325' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,5,'elective' FROM programmes p JOIN courses c ON c.code='CS327' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'core' FROM programmes p JOIN courses c ON c.code='CS302' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'core' FROM programmes p JOIN courses c ON c.code='CS304' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'core' FROM programmes p JOIN courses c ON c.code='CS306' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'core' FROM programmes p JOIN courses c ON c.code='CS308' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'core' FROM programmes p JOIN courses c ON c.code='CS382' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'core' FROM programmes p JOIN courses c ON c.code='CS384' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'core' FROM programmes p JOIN courses c ON c.code='CS386' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'common' FROM programmes p JOIN courses c ON c.code='GP' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS310' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS312' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS314' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS316' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS318' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS320' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS322' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS324' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS326' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,6,'elective' FROM programmes p JOIN courses c ON c.code='CS328' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'core' FROM programmes p JOIN courses c ON c.code='MA401' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'core' FROM programmes p JOIN courses c ON c.code='CS401' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'core' FROM programmes p JOIN courses c ON c.code='CS403' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'core' FROM programmes p JOIN courses c ON c.code='CS405' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'core' FROM programmes p JOIN courses c ON c.code='CS481' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'core' FROM programmes p JOIN courses c ON c.code='CS491' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'core' FROM programmes p JOIN courses c ON c.code='CS493' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'common' FROM programmes p JOIN courses c ON c.code='GP' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'elective' FROM programmes p JOIN courses c ON c.code='CS407' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'elective' FROM programmes p JOIN courses c ON c.code='CS409' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'elective' FROM programmes p JOIN courses c ON c.code='CS411' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'elective' FROM programmes p JOIN courses c ON c.code='CS413' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,7,'elective' FROM programmes p JOIN courses c ON c.code='CS415' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,8,'core' FROM programmes p JOIN courses c ON c.code='CS490' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,8,'core' FROM programmes p JOIN courses c ON c.code='CS492' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,8,'core' FROM programmes p JOIN courses c ON c.code='CS494' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);
INSERT INTO programme_courses (programme_id,course_id,semester,category)
SELECT p.id,c.id,8,'common' FROM programmes p JOIN courses c ON c.code='GP' WHERE p.code='UCS'
ON DUPLICATE KEY UPDATE category=VALUES(category);

INSERT INTO students (programme_id,batch_id,roll_no_original,enrollment_number,academic_session,normalized_roll_no,registration_prefix,programme_code_detected,student_sequence,name,branch,mobile_number,address,department_name,school_name,current_year_of_study,semester,section,admission_type,special_status,parsing_status,status) VALUES
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS001','2300100001','2026-2027','235ICS001','235','ICS','001','Aarav Yadav','Integrated B.Tech Computer Science and Engineering','9876000001','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS002','2300100002','2026-2027','235ICS002','235','ICS','002','Aditi Tiwari','Integrated B.Tech Computer Science and Engineering','9876000002','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS003','2300100003','2026-2027','235ICS003','235','ICS','003','Advik Khan','Integrated B.Tech Computer Science and Engineering','9876000003','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS004','2300100004','2026-2027','235ICS004','235','ICS','004','Ananya Kumar','Integrated B.Tech Computer Science and Engineering','9876000004','Delhi','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS005','2300100005','2026-2027','235ICS005','235','ICS','005','Arjun Kapoor','Integrated B.Tech Computer Science and Engineering','9876000005','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS006','2300100006','2026-2027','235ICS006','235','ICS','006','Avni Saini','Integrated B.Tech Computer Science and Engineering','9876000006','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS007','2300100007','2026-2027','235ICS007','235','ICS','007','Dev Verma','Integrated B.Tech Computer Science and Engineering','9876000007','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS008','2300100008','2026-2027','235ICS008','235','ICS','008','Diya Mehta','Integrated B.Tech Computer Science and Engineering','9876000008','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS009','2300100009','2026-2027','235ICS009','235','ICS','009','Ishaan Agarwal','Integrated B.Tech Computer Science and Engineering','9876000009','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS010','2300100010','2026-2027','235ICS010','235','ICS','010','Kavya Srivastava','Integrated B.Tech Computer Science and Engineering','9876000010','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS011','2300100011','2026-2027','235ICS011','235','ICS','011','Krish Mishra','Integrated B.Tech Computer Science and Engineering','9876000011','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS012','2300100012','2026-2027','235ICS012','235','ICS','012','Meera Chauhan','Integrated B.Tech Computer Science and Engineering','9876000012','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS013','2300100013','2026-2027','235ICS013','235','ICS','013','Naksh Arora','Integrated B.Tech Computer Science and Engineering','9876000013','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS014','2300100014','2026-2027','235ICS014','235','ICS','014','Navya Singh','Integrated B.Tech Computer Science and Engineering','9876000014','Delhi','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS015','2300100015','2026-2027','235ICS015','235','ICS','015','Pranav Joshi','Integrated B.Tech Computer Science and Engineering','9876000015','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS016','2300100016','2026-2027','235ICS016','235','ICS','016','Riya Jain','Integrated B.Tech Computer Science and Engineering','9876000016','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS017','2300100017','2026-2027','235ICS017','235','ICS','017','Rohan Chandra','Integrated B.Tech Computer Science and Engineering','9876000017','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS018','2300100018','2026-2027','235ICS018','235','ICS','018','Saanvi Patel','Integrated B.Tech Computer Science and Engineering','9876000018','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS019','2300100019','2026-2027','235ICS019','235','ICS','019','Samarth Saxena','Integrated B.Tech Computer Science and Engineering','9876000019','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='ICS' LIMIT 1),NULL,'235ICS020','2300100020','2026-2027','235ICS020','235','ICS','020','Siya Rao','Integrated B.Tech Computer Science and Engineering','9876000020','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC001','2300100021','2026-2027','235IEC001','235','IEC','001','Vedant Gupta','Electronics and Communication Engineering','9876000021','Greater Noida Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC002','2300100022','2026-2027','235IEC002','235','IEC','002','Vanya Bansal','Electronics and Communication Engineering','9876000022','Noida Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC003','2300100023','2026-2027','235IEC003','235','IEC','003','Vihaan Malhotra','Electronics and Communication Engineering','9876000023','Ghaziabad Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC004','2300100024','2026-2027','235IEC004','235','IEC','004','Zara Sharma','Electronics and Communication Engineering','9876000024','Delhi','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC005','2300100025','2026-2027','235IEC005','235','IEC','005','Aarav Yadav','Electronics and Communication Engineering','9876000025','Meerut Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC006','2300100026','2026-2027','235IEC006','235','IEC','006','Aditi Tiwari','Electronics and Communication Engineering','9876000026','Agra Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC007','2300100027','2026-2027','235IEC007','235','IEC','007','Advik Khan','Electronics and Communication Engineering','9876000027','Mathura Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC008','2300100028','2026-2027','235IEC008','235','IEC','008','Ananya Kumar','Electronics and Communication Engineering','9876000028','Aligarh Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC009','2300100029','2026-2027','235IEC009','235','IEC','009','Arjun Kapoor','Electronics and Communication Engineering','9876000029','Hapur Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC010','2300100030','2026-2027','235IEC010','235','IEC','010','Avni Saini','Electronics and Communication Engineering','9876000030','Bulandshahr Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'A','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC011','2300100031','2026-2027','235IEC011','235','IEC','011','Dev Verma','Electronics and Communication Engineering','9876000031','Greater Noida Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC012','2300100032','2026-2027','235IEC012','235','IEC','012','Diya Mehta','Electronics and Communication Engineering','9876000032','Noida Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC013','2300100033','2026-2027','235IEC013','235','IEC','013','Ishaan Agarwal','Electronics and Communication Engineering','9876000033','Ghaziabad Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC014','2300100034','2026-2027','235IEC014','235','IEC','014','Kavya Srivastava','Electronics and Communication Engineering','9876000034','Delhi','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC015','2300100035','2026-2027','235IEC015','235','IEC','015','Krish Mishra','Electronics and Communication Engineering','9876000035','Meerut Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC016','2300100036','2026-2027','235IEC016','235','IEC','016','Meera Chauhan','Electronics and Communication Engineering','9876000036','Agra Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC017','2300100037','2026-2027','235IEC017','235','IEC','017','Naksh Arora','Electronics and Communication Engineering','9876000037','Mathura Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC018','2300100038','2026-2027','235IEC018','235','IEC','018','Navya Singh','Electronics and Communication Engineering','9876000038','Aligarh Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC019','2300100039','2026-2027','235IEC019','235','IEC','019','Pranav Joshi','Electronics and Communication Engineering','9876000039','Hapur Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='IEC' LIMIT 1),NULL,'235IEC020','2300100040','2026-2027','235IEC020','235','IEC','020','Riya Jain','Electronics and Communication Engineering','9876000040','Bulandshahr Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',3,5,'B','legacy','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS001','2300100041','2026-2027','235LCS001','235','LCS','001','Rohan Chandra','Computer Science and Engineering','9876000041','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS002','2300100042','2026-2027','235LCS002','235','LCS','002','Saanvi Patel','Computer Science and Engineering','9876000042','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS003','2300100043','2026-2027','235LCS003','235','LCS','003','Samarth Saxena','Computer Science and Engineering','9876000043','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS004','2300100044','2026-2027','235LCS004','235','LCS','004','Siya Rao','Computer Science and Engineering','9876000044','Delhi','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS005','2300100045','2026-2027','235LCS005','235','LCS','005','Vedant Gupta','Computer Science and Engineering','9876000045','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS006','2300100046','2026-2027','235LCS006','235','LCS','006','Vanya Bansal','Computer Science and Engineering','9876000046','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS007','2300100047','2026-2027','235LCS007','235','LCS','007','Vihaan Malhotra','Computer Science and Engineering','9876000047','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS008','2300100048','2026-2027','235LCS008','235','LCS','008','Zara Sharma','Computer Science and Engineering','9876000048','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS009','2300100049','2026-2027','235LCS009','235','LCS','009','Aarav Yadav','Computer Science and Engineering','9876000049','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS010','2300100050','2026-2027','235LCS010','235','LCS','010','Aditi Tiwari','Computer Science and Engineering','9876000050','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS011','2300100051','2026-2027','235LCS011','235','LCS','011','Advik Khan','Computer Science and Engineering','9876000051','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS012','2300100052','2026-2027','235LCS012','235','LCS','012','Ananya Kumar','Computer Science and Engineering','9876000052','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS013','2300100053','2026-2027','235LCS013','235','LCS','013','Arjun Kapoor','Computer Science and Engineering','9876000053','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS014','2300100054','2026-2027','235LCS014','235','LCS','014','Avni Saini','Computer Science and Engineering','9876000054','Delhi','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS015','2300100055','2026-2027','235LCS015','235','LCS','015','Dev Verma','Computer Science and Engineering','9876000055','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS016','2300100056','2026-2027','235LCS016','235','LCS','016','Diya Mehta','Computer Science and Engineering','9876000056','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS017','2300100057','2026-2027','235LCS017','235','LCS','017','Ishaan Agarwal','Computer Science and Engineering','9876000057','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS018','2300100058','2026-2027','235LCS018','235','LCS','018','Kavya Srivastava','Computer Science and Engineering','9876000058','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS019','2300100059','2026-2027','235LCS019','235','LCS','019','Krish Mishra','Computer Science and Engineering','9876000059','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LCS' LIMIT 1),NULL,'235LCS020','2300100060','2026-2027','235LCS020','235','LCS','020','Meera Chauhan','Computer Science and Engineering','9876000060','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA001','2300100061','2026-2027','235LEA001','235','LEA','001','Naksh Arora','Electronics AI and Machine Learning','9876000061','Greater Noida Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA002','2300100062','2026-2027','235LEA002','235','LEA','002','Navya Singh','Electronics AI and Machine Learning','9876000062','Noida Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA003','2300100063','2026-2027','235LEA003','235','LEA','003','Pranav Joshi','Electronics AI and Machine Learning','9876000063','Ghaziabad Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA004','2300100064','2026-2027','235LEA004','235','LEA','004','Riya Jain','Electronics AI and Machine Learning','9876000064','Delhi','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA005','2300100065','2026-2027','235LEA005','235','LEA','005','Rohan Chandra','Electronics AI and Machine Learning','9876000065','Meerut Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA006','2300100066','2026-2027','235LEA006','235','LEA','006','Saanvi Patel','Electronics AI and Machine Learning','9876000066','Agra Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA007','2300100067','2026-2027','235LEA007','235','LEA','007','Samarth Saxena','Electronics AI and Machine Learning','9876000067','Mathura Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA008','2300100068','2026-2027','235LEA008','235','LEA','008','Siya Rao','Electronics AI and Machine Learning','9876000068','Aligarh Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA009','2300100069','2026-2027','235LEA009','235','LEA','009','Vedant Gupta','Electronics AI and Machine Learning','9876000069','Hapur Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA010','2300100070','2026-2027','235LEA010','235','LEA','010','Vanya Bansal','Electronics AI and Machine Learning','9876000070','Bulandshahr Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA011','2300100071','2026-2027','235LEA011','235','LEA','011','Vihaan Malhotra','Electronics AI and Machine Learning','9876000071','Greater Noida Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA012','2300100072','2026-2027','235LEA012','235','LEA','012','Zara Sharma','Electronics AI and Machine Learning','9876000072','Noida Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA013','2300100073','2026-2027','235LEA013','235','LEA','013','Aarav Yadav','Electronics AI and Machine Learning','9876000073','Ghaziabad Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA014','2300100074','2026-2027','235LEA014','235','LEA','014','Aditi Tiwari','Electronics AI and Machine Learning','9876000074','Delhi','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA015','2300100075','2026-2027','235LEA015','235','LEA','015','Advik Khan','Electronics AI and Machine Learning','9876000075','Meerut Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA016','2300100076','2026-2027','235LEA016','235','LEA','016','Ananya Kumar','Electronics AI and Machine Learning','9876000076','Agra Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA017','2300100077','2026-2027','235LEA017','235','LEA','017','Arjun Kapoor','Electronics AI and Machine Learning','9876000077','Mathura Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA018','2300100078','2026-2027','235LEA018','235','LEA','018','Avni Saini','Electronics AI and Machine Learning','9876000078','Aligarh Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA019','2300100079','2026-2027','235LEA019','235','LEA','019','Dev Verma','Electronics AI and Machine Learning','9876000079','Hapur Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LEA' LIMIT 1),NULL,'235LEA020','2300100080','2026-2027','235LEA020','235','LEA','020','Diya Mehta','Electronics AI and Machine Learning','9876000080','Bulandshahr Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT001','2300100081','2026-2027','235LIT001','235','LIT','001','Ishaan Agarwal','Information Technology','9876000081','Greater Noida Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT002','2300100082','2026-2027','235LIT002','235','LIT','002','Kavya Srivastava','Information Technology','9876000082','Noida Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT003','2300100083','2026-2027','235LIT003','235','LIT','003','Krish Mishra','Information Technology','9876000083','Ghaziabad Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT004','2300100084','2026-2027','235LIT004','235','LIT','004','Meera Chauhan','Information Technology','9876000084','Delhi','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT005','2300100085','2026-2027','235LIT005','235','LIT','005','Naksh Arora','Information Technology','9876000085','Meerut Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT006','2300100086','2026-2027','235LIT006','235','LIT','006','Navya Singh','Information Technology','9876000086','Agra Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT007','2300100087','2026-2027','235LIT007','235','LIT','007','Pranav Joshi','Information Technology','9876000087','Mathura Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT008','2300100088','2026-2027','235LIT008','235','LIT','008','Riya Jain','Information Technology','9876000088','Aligarh Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT009','2300100089','2026-2027','235LIT009','235','LIT','009','Rohan Chandra','Information Technology','9876000089','Hapur Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT010','2300100090','2026-2027','235LIT010','235','LIT','010','Saanvi Patel','Information Technology','9876000090','Bulandshahr Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT011','2300100091','2026-2027','235LIT011','235','LIT','011','Samarth Saxena','Information Technology','9876000091','Greater Noida Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT012','2300100092','2026-2027','235LIT012','235','LIT','012','Siya Rao','Information Technology','9876000092','Noida Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT013','2300100093','2026-2027','235LIT013','235','LIT','013','Vedant Gupta','Information Technology','9876000093','Ghaziabad Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT014','2300100094','2026-2027','235LIT014','235','LIT','014','Vanya Bansal','Information Technology','9876000094','Delhi','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT015','2300100095','2026-2027','235LIT015','235','LIT','015','Vihaan Malhotra','Information Technology','9876000095','Meerut Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT016','2300100096','2026-2027','235LIT016','235','LIT','016','Zara Sharma','Information Technology','9876000096','Agra Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT017','2300100097','2026-2027','235LIT017','235','LIT','017','Aarav Yadav','Information Technology','9876000097','Mathura Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT018','2300100098','2026-2027','235LIT018','235','LIT','018','Aditi Tiwari','Information Technology','9876000098','Aligarh Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT019','2300100099','2026-2027','235LIT019','235','LIT','019','Advik Khan','Information Technology','9876000099','Hapur Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active'),
((SELECT id FROM programmes WHERE code='LIT' LIMIT 1),NULL,'235LIT020','2300100100','2026-2027','235LIT020','235','LIT','020','Ananya Kumar','Information Technology','9876000100','Bulandshahr Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','lateral','none','verified','active')
ON DUPLICATE KEY UPDATE programme_id=VALUES(programme_id),enrollment_number=VALUES(enrollment_number),academic_session=VALUES(academic_session),roll_no_original=VALUES(roll_no_original),registration_prefix=VALUES(registration_prefix),programme_code_detected=VALUES(programme_code_detected),student_sequence=VALUES(student_sequence),name=VALUES(name),branch=VALUES(branch),mobile_number=VALUES(mobile_number),address=VALUES(address),department_name=VALUES(department_name),school_name=VALUES(school_name),current_year_of_study=VALUES(current_year_of_study),semester=VALUES(semester),section=VALUES(section),admission_type=VALUES(admission_type),parsing_status='verified',status='active';

INSERT INTO students (programme_id,batch_id,roll_no_original,enrollment_number,academic_session,normalized_roll_no,registration_prefix,programme_code_detected,student_sequence,name,branch,mobile_number,address,department_name,school_name,current_year_of_study,semester,section,admission_type,special_status,parsing_status,status) VALUES
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS001','2300100101','2026-2027','235PCS001','235','PCS','001','Arjun Kapoor','Computer Science and Engineering','9876000101','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS002','2300100102','2026-2027','235PCS002','235','PCS','002','Avni Saini','Computer Science and Engineering','9876000102','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS003','2300100103','2026-2027','235PCS003','235','PCS','003','Dev Verma','Computer Science and Engineering','9876000103','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS004','2300100104','2026-2027','235PCS004','235','PCS','004','Diya Mehta','Computer Science and Engineering','9876000104','Delhi','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS005','2300100105','2026-2027','235PCS005','235','PCS','005','Ishaan Agarwal','Computer Science and Engineering','9876000105','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS006','2300100106','2026-2027','235PCS006','235','PCS','006','Kavya Srivastava','Computer Science and Engineering','9876000106','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS007','2300100107','2026-2027','235PCS007','235','PCS','007','Krish Mishra','Computer Science and Engineering','9876000107','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS008','2300100108','2026-2027','235PCS008','235','PCS','008','Meera Chauhan','Computer Science and Engineering','9876000108','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS009','2300100109','2026-2027','235PCS009','235','PCS','009','Naksh Arora','Computer Science and Engineering','9876000109','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS010','2300100110','2026-2027','235PCS010','235','PCS','010','Navya Singh','Computer Science and Engineering','9876000110','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS011','2300100111','2026-2027','235PCS011','235','PCS','011','Pranav Joshi','Computer Science and Engineering','9876000111','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS012','2300100112','2026-2027','235PCS012','235','PCS','012','Riya Jain','Computer Science and Engineering','9876000112','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS013','2300100113','2026-2027','235PCS013','235','PCS','013','Rohan Chandra','Computer Science and Engineering','9876000113','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS014','2300100114','2026-2027','235PCS014','235','PCS','014','Saanvi Patel','Computer Science and Engineering','9876000114','Delhi','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS015','2300100115','2026-2027','235PCS015','235','PCS','015','Samarth Saxena','Computer Science and Engineering','9876000115','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS016','2300100116','2026-2027','235PCS016','235','PCS','016','Siya Rao','Computer Science and Engineering','9876000116','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS017','2300100117','2026-2027','235PCS017','235','PCS','017','Vedant Gupta','Computer Science and Engineering','9876000117','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS018','2300100118','2026-2027','235PCS018','235','PCS','018','Vanya Bansal','Computer Science and Engineering','9876000118','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS019','2300100119','2026-2027','235PCS019','235','PCS','019','Vihaan Malhotra','Computer Science and Engineering','9876000119','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCS' LIMIT 1),NULL,'235PCS020','2300100120','2026-2027','235PCS020','235','PCS','020','Zara Sharma','Computer Science and Engineering','9876000120','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW001','2300100121','2026-2027','235PCW001','235','PCW','001','Aarav Yadav','Computer Science and Engineering','9876000121','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW002','2300100122','2026-2027','235PCW002','235','PCW','002','Aditi Tiwari','Computer Science and Engineering','9876000122','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW003','2300100123','2026-2027','235PCW003','235','PCW','003','Advik Khan','Computer Science and Engineering','9876000123','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW004','2300100124','2026-2027','235PCW004','235','PCW','004','Ananya Kumar','Computer Science and Engineering','9876000124','Delhi','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW005','2300100125','2026-2027','235PCW005','235','PCW','005','Arjun Kapoor','Computer Science and Engineering','9876000125','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW006','2300100126','2026-2027','235PCW006','235','PCW','006','Avni Saini','Computer Science and Engineering','9876000126','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW007','2300100127','2026-2027','235PCW007','235','PCW','007','Dev Verma','Computer Science and Engineering','9876000127','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW008','2300100128','2026-2027','235PCW008','235','PCW','008','Diya Mehta','Computer Science and Engineering','9876000128','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW009','2300100129','2026-2027','235PCW009','235','PCW','009','Ishaan Agarwal','Computer Science and Engineering','9876000129','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW010','2300100130','2026-2027','235PCW010','235','PCW','010','Kavya Srivastava','Computer Science and Engineering','9876000130','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW011','2300100131','2026-2027','235PCW011','235','PCW','011','Krish Mishra','Computer Science and Engineering','9876000131','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW012','2300100132','2026-2027','235PCW012','235','PCW','012','Meera Chauhan','Computer Science and Engineering','9876000132','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW013','2300100133','2026-2027','235PCW013','235','PCW','013','Naksh Arora','Computer Science and Engineering','9876000133','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW014','2300100134','2026-2027','235PCW014','235','PCW','014','Navya Singh','Computer Science and Engineering','9876000134','Delhi','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW015','2300100135','2026-2027','235PCW015','235','PCW','015','Pranav Joshi','Computer Science and Engineering','9876000135','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW016','2300100136','2026-2027','235PCW016','235','PCW','016','Riya Jain','Computer Science and Engineering','9876000136','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW017','2300100137','2026-2027','235PCW017','235','PCW','017','Rohan Chandra','Computer Science and Engineering','9876000137','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW018','2300100138','2026-2027','235PCW018','235','PCW','018','Saanvi Patel','Computer Science and Engineering','9876000138','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW019','2300100139','2026-2027','235PCW019','235','PCW','019','Samarth Saxena','Computer Science and Engineering','9876000139','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='PCW' LIMIT 1),NULL,'235PCW020','2300100140','2026-2027','235PCW020','235','PCW','020','Siya Rao','Computer Science and Engineering','9876000140','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',1,1,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI001','2300100141','2026-2027','235UAI001','235','UAI','001','Vedant Gupta','Artificial Intelligence','9876000141','Greater Noida Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI002','2300100142','2026-2027','235UAI002','235','UAI','002','Vanya Bansal','Artificial Intelligence','9876000142','Noida Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI003','2300100143','2026-2027','235UAI003','235','UAI','003','Vihaan Malhotra','Artificial Intelligence','9876000143','Ghaziabad Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI004','2300100144','2026-2027','235UAI004','235','UAI','004','Zara Sharma','Artificial Intelligence','9876000144','Delhi','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI005','2300100145','2026-2027','235UAI005','235','UAI','005','Aarav Yadav','Artificial Intelligence','9876000145','Meerut Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI006','2300100146','2026-2027','235UAI006','235','UAI','006','Aditi Tiwari','Artificial Intelligence','9876000146','Agra Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI007','2300100147','2026-2027','235UAI007','235','UAI','007','Advik Khan','Artificial Intelligence','9876000147','Mathura Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI008','2300100148','2026-2027','235UAI008','235','UAI','008','Ananya Kumar','Artificial Intelligence','9876000148','Aligarh Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI009','2300100149','2026-2027','235UAI009','235','UAI','009','Arjun Kapoor','Artificial Intelligence','9876000149','Hapur Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI010','2300100150','2026-2027','235UAI010','235','UAI','010','Avni Saini','Artificial Intelligence','9876000150','Bulandshahr Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI011','2300100151','2026-2027','235UAI011','235','UAI','011','Dev Verma','Artificial Intelligence','9876000151','Greater Noida Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI012','2300100152','2026-2027','235UAI012','235','UAI','012','Diya Mehta','Artificial Intelligence','9876000152','Noida Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI013','2300100153','2026-2027','235UAI013','235','UAI','013','Ishaan Agarwal','Artificial Intelligence','9876000153','Ghaziabad Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI014','2300100154','2026-2027','235UAI014','235','UAI','014','Kavya Srivastava','Artificial Intelligence','9876000154','Delhi','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI015','2300100155','2026-2027','235UAI015','235','UAI','015','Krish Mishra','Artificial Intelligence','9876000155','Meerut Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI016','2300100156','2026-2027','235UAI016','235','UAI','016','Meera Chauhan','Artificial Intelligence','9876000156','Agra Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI017','2300100157','2026-2027','235UAI017','235','UAI','017','Naksh Arora','Artificial Intelligence','9876000157','Mathura Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI018','2300100158','2026-2027','235UAI018','235','UAI','018','Navya Singh','Artificial Intelligence','9876000158','Aligarh Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI019','2300100159','2026-2027','235UAI019','235','UAI','019','Pranav Joshi','Artificial Intelligence','9876000159','Hapur Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UAI' LIMIT 1),NULL,'235UAI020','2300100160','2026-2027','235UAI020','235','UAI','020','Riya Jain','Artificial Intelligence','9876000160','Bulandshahr Uttar Pradesh','Artificial Intelligence','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA001','2300100161','2026-2027','235UCA001','235','UCA','001','Rohan Chandra','Computer Applications','9876000161','Greater Noida Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA002','2300100162','2026-2027','235UCA002','235','UCA','002','Saanvi Patel','Computer Applications','9876000162','Noida Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA003','2300100163','2026-2027','235UCA003','235','UCA','003','Samarth Saxena','Computer Applications','9876000163','Ghaziabad Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA004','2300100164','2026-2027','235UCA004','235','UCA','004','Siya Rao','Computer Applications','9876000164','Delhi','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA005','2300100165','2026-2027','235UCA005','235','UCA','005','Vedant Gupta','Computer Applications','9876000165','Meerut Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA006','2300100166','2026-2027','235UCA006','235','UCA','006','Vanya Bansal','Computer Applications','9876000166','Agra Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA007','2300100167','2026-2027','235UCA007','235','UCA','007','Vihaan Malhotra','Computer Applications','9876000167','Mathura Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA008','2300100168','2026-2027','235UCA008','235','UCA','008','Zara Sharma','Computer Applications','9876000168','Aligarh Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA009','2300100169','2026-2027','235UCA009','235','UCA','009','Aarav Yadav','Computer Applications','9876000169','Hapur Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA010','2300100170','2026-2027','235UCA010','235','UCA','010','Aditi Tiwari','Computer Applications','9876000170','Bulandshahr Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA011','2300100171','2026-2027','235UCA011','235','UCA','011','Advik Khan','Computer Applications','9876000171','Greater Noida Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA012','2300100172','2026-2027','235UCA012','235','UCA','012','Ananya Kumar','Computer Applications','9876000172','Noida Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA013','2300100173','2026-2027','235UCA013','235','UCA','013','Arjun Kapoor','Computer Applications','9876000173','Ghaziabad Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA014','2300100174','2026-2027','235UCA014','235','UCA','014','Avni Saini','Computer Applications','9876000174','Delhi','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA015','2300100175','2026-2027','235UCA015','235','UCA','015','Dev Verma','Computer Applications','9876000175','Meerut Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA016','2300100176','2026-2027','235UCA016','235','UCA','016','Diya Mehta','Computer Applications','9876000176','Agra Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA017','2300100177','2026-2027','235UCA017','235','UCA','017','Ishaan Agarwal','Computer Applications','9876000177','Mathura Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA018','2300100178','2026-2027','235UCA018','235','UCA','018','Kavya Srivastava','Computer Applications','9876000178','Aligarh Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA019','2300100179','2026-2027','235UCA019','235','UCA','019','Krish Mishra','Computer Applications','9876000179','Hapur Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCA' LIMIT 1),NULL,'235UCA020','2300100180','2026-2027','235UCA020','235','UCA','020','Meera Chauhan','Computer Applications','9876000180','Bulandshahr Uttar Pradesh','Computer Applications','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC001','2300100181','2026-2027','235UCC001','235','UCC','001','Naksh Arora','Cyber Security','9876000181','Greater Noida Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC002','2300100182','2026-2027','235UCC002','235','UCC','002','Navya Singh','Cyber Security','9876000182','Noida Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC003','2300100183','2026-2027','235UCC003','235','UCC','003','Pranav Joshi','Cyber Security','9876000183','Ghaziabad Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC004','2300100184','2026-2027','235UCC004','235','UCC','004','Riya Jain','Cyber Security','9876000184','Delhi','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC005','2300100185','2026-2027','235UCC005','235','UCC','005','Rohan Chandra','Cyber Security','9876000185','Meerut Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC006','2300100186','2026-2027','235UCC006','235','UCC','006','Saanvi Patel','Cyber Security','9876000186','Agra Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC007','2300100187','2026-2027','235UCC007','235','UCC','007','Samarth Saxena','Cyber Security','9876000187','Mathura Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC008','2300100188','2026-2027','235UCC008','235','UCC','008','Siya Rao','Cyber Security','9876000188','Aligarh Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC009','2300100189','2026-2027','235UCC009','235','UCC','009','Vedant Gupta','Cyber Security','9876000189','Hapur Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC010','2300100190','2026-2027','235UCC010','235','UCC','010','Vanya Bansal','Cyber Security','9876000190','Bulandshahr Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC011','2300100191','2026-2027','235UCC011','235','UCC','011','Vihaan Malhotra','Cyber Security','9876000191','Greater Noida Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC012','2300100192','2026-2027','235UCC012','235','UCC','012','Zara Sharma','Cyber Security','9876000192','Noida Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC013','2300100193','2026-2027','235UCC013','235','UCC','013','Aarav Yadav','Cyber Security','9876000193','Ghaziabad Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC014','2300100194','2026-2027','235UCC014','235','UCC','014','Aditi Tiwari','Cyber Security','9876000194','Delhi','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC015','2300100195','2026-2027','235UCC015','235','UCC','015','Advik Khan','Cyber Security','9876000195','Meerut Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC016','2300100196','2026-2027','235UCC016','235','UCC','016','Ananya Kumar','Cyber Security','9876000196','Agra Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC017','2300100197','2026-2027','235UCC017','235','UCC','017','Arjun Kapoor','Cyber Security','9876000197','Mathura Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC018','2300100198','2026-2027','235UCC018','235','UCC','018','Avni Saini','Cyber Security','9876000198','Aligarh Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC019','2300100199','2026-2027','235UCC019','235','UCC','019','Dev Verma','Cyber Security','9876000199','Hapur Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCC' LIMIT 1),NULL,'235UCC020','2300100200','2026-2027','235UCC020','235','UCC','020','Diya Mehta','Cyber Security','9876000200','Bulandshahr Uttar Pradesh','Cyber Security','School of Information and Communication Technology',2,3,'B','regular','none','verified','active')
ON DUPLICATE KEY UPDATE programme_id=VALUES(programme_id),enrollment_number=VALUES(enrollment_number),academic_session=VALUES(academic_session),roll_no_original=VALUES(roll_no_original),registration_prefix=VALUES(registration_prefix),programme_code_detected=VALUES(programme_code_detected),student_sequence=VALUES(student_sequence),name=VALUES(name),branch=VALUES(branch),mobile_number=VALUES(mobile_number),address=VALUES(address),department_name=VALUES(department_name),school_name=VALUES(school_name),current_year_of_study=VALUES(current_year_of_study),semester=VALUES(semester),section=VALUES(section),admission_type=VALUES(admission_type),parsing_status='verified',status='active';

INSERT INTO students (programme_id,batch_id,roll_no_original,enrollment_number,academic_session,normalized_roll_no,registration_prefix,programme_code_detected,student_sequence,name,branch,mobile_number,address,department_name,school_name,current_year_of_study,semester,section,admission_type,special_status,parsing_status,status) VALUES
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD001','2300100201','2026-2027','235UCD001','235','UCD','001','Ishaan Agarwal','Data Science','9876000201','Greater Noida Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD002','2300100202','2026-2027','235UCD002','235','UCD','002','Kavya Srivastava','Data Science','9876000202','Noida Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD003','2300100203','2026-2027','235UCD003','235','UCD','003','Krish Mishra','Data Science','9876000203','Ghaziabad Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD004','2300100204','2026-2027','235UCD004','235','UCD','004','Meera Chauhan','Data Science','9876000204','Delhi','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD005','2300100205','2026-2027','235UCD005','235','UCD','005','Naksh Arora','Data Science','9876000205','Meerut Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD006','2300100206','2026-2027','235UCD006','235','UCD','006','Navya Singh','Data Science','9876000206','Agra Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD007','2300100207','2026-2027','235UCD007','235','UCD','007','Pranav Joshi','Data Science','9876000207','Mathura Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD008','2300100208','2026-2027','235UCD008','235','UCD','008','Riya Jain','Data Science','9876000208','Aligarh Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD009','2300100209','2026-2027','235UCD009','235','UCD','009','Rohan Chandra','Data Science','9876000209','Hapur Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD010','2300100210','2026-2027','235UCD010','235','UCD','010','Saanvi Patel','Data Science','9876000210','Bulandshahr Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD011','2300100211','2026-2027','235UCD011','235','UCD','011','Samarth Saxena','Data Science','9876000211','Greater Noida Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD012','2300100212','2026-2027','235UCD012','235','UCD','012','Siya Rao','Data Science','9876000212','Noida Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD013','2300100213','2026-2027','235UCD013','235','UCD','013','Vedant Gupta','Data Science','9876000213','Ghaziabad Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD014','2300100214','2026-2027','235UCD014','235','UCD','014','Vanya Bansal','Data Science','9876000214','Delhi','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD015','2300100215','2026-2027','235UCD015','235','UCD','015','Vihaan Malhotra','Data Science','9876000215','Meerut Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD016','2300100216','2026-2027','235UCD016','235','UCD','016','Zara Sharma','Data Science','9876000216','Agra Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD017','2300100217','2026-2027','235UCD017','235','UCD','017','Aarav Yadav','Data Science','9876000217','Mathura Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD018','2300100218','2026-2027','235UCD018','235','UCD','018','Aditi Tiwari','Data Science','9876000218','Aligarh Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD019','2300100219','2026-2027','235UCD019','235','UCD','019','Advik Khan','Data Science','9876000219','Hapur Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCD' LIMIT 1),NULL,'235UCD020','2300100220','2026-2027','235UCD020','235','UCD','020','Ananya Kumar','Data Science','9876000220','Bulandshahr Uttar Pradesh','Data Science','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM001','2300100221','2026-2027','235UCM001','235','UCM','001','Arjun Kapoor','Machine Learning','9876000221','Greater Noida Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM002','2300100222','2026-2027','235UCM002','235','UCM','002','Avni Saini','Machine Learning','9876000222','Noida Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM003','2300100223','2026-2027','235UCM003','235','UCM','003','Dev Verma','Machine Learning','9876000223','Ghaziabad Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM004','2300100224','2026-2027','235UCM004','235','UCM','004','Diya Mehta','Machine Learning','9876000224','Delhi','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM005','2300100225','2026-2027','235UCM005','235','UCM','005','Ishaan Agarwal','Machine Learning','9876000225','Meerut Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM006','2300100226','2026-2027','235UCM006','235','UCM','006','Kavya Srivastava','Machine Learning','9876000226','Agra Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM007','2300100227','2026-2027','235UCM007','235','UCM','007','Krish Mishra','Machine Learning','9876000227','Mathura Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM008','2300100228','2026-2027','235UCM008','235','UCM','008','Meera Chauhan','Machine Learning','9876000228','Aligarh Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM009','2300100229','2026-2027','235UCM009','235','UCM','009','Naksh Arora','Machine Learning','9876000229','Hapur Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM010','2300100230','2026-2027','235UCM010','235','UCM','010','Navya Singh','Machine Learning','9876000230','Bulandshahr Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM011','2300100231','2026-2027','235UCM011','235','UCM','011','Pranav Joshi','Machine Learning','9876000231','Greater Noida Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM012','2300100232','2026-2027','235UCM012','235','UCM','012','Riya Jain','Machine Learning','9876000232','Noida Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM013','2300100233','2026-2027','235UCM013','235','UCM','013','Rohan Chandra','Machine Learning','9876000233','Ghaziabad Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM014','2300100234','2026-2027','235UCM014','235','UCM','014','Saanvi Patel','Machine Learning','9876000234','Delhi','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM015','2300100235','2026-2027','235UCM015','235','UCM','015','Samarth Saxena','Machine Learning','9876000235','Meerut Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM016','2300100236','2026-2027','235UCM016','235','UCM','016','Siya Rao','Machine Learning','9876000236','Agra Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM017','2300100237','2026-2027','235UCM017','235','UCM','017','Vedant Gupta','Machine Learning','9876000237','Mathura Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM018','2300100238','2026-2027','235UCM018','235','UCM','018','Vanya Bansal','Machine Learning','9876000238','Aligarh Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM019','2300100239','2026-2027','235UCM019','235','UCM','019','Vihaan Malhotra','Machine Learning','9876000239','Hapur Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCM' LIMIT 1),NULL,'235UCM020','2300100240','2026-2027','235UCM020','235','UCM','020','Zara Sharma','Machine Learning','9876000240','Bulandshahr Uttar Pradesh','Machine Learning','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS001','2300100241','2026-2027','235UCS001','235','UCS','001','Aarav Yadav','Computer Science and Engineering','9876000241','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS002','2300100242','2026-2027','235UCS002','235','UCS','002','Aditi Tiwari','Computer Science and Engineering','9876000242','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS003','2300100243','2026-2027','235UCS003','235','UCS','003','Advik Khan','Computer Science and Engineering','9876000243','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS004','2300100244','2026-2027','235UCS004','235','UCS','004','Ananya Kumar','Computer Science and Engineering','9876000244','Delhi','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS005','2300100245','2026-2027','235UCS005','235','UCS','005','Arjun Kapoor','Computer Science and Engineering','9876000245','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS006','2300100246','2026-2027','235UCS006','235','UCS','006','Avni Saini','Computer Science and Engineering','9876000246','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS007','2300100247','2026-2027','235UCS007','235','UCS','007','Dev Verma','Computer Science and Engineering','9876000247','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS008','2300100248','2026-2027','235UCS008','235','UCS','008','Diya Mehta','Computer Science and Engineering','9876000248','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS009','2300100249','2026-2027','235UCS009','235','UCS','009','Ishaan Agarwal','Computer Science and Engineering','9876000249','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS010','2300100250','2026-2027','235UCS010','235','UCS','010','Kavya Srivastava','Computer Science and Engineering','9876000250','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS011','2300100251','2026-2027','235UCS011','235','UCS','011','Krish Mishra','Computer Science and Engineering','9876000251','Greater Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS012','2300100252','2026-2027','235UCS012','235','UCS','012','Meera Chauhan','Computer Science and Engineering','9876000252','Noida Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS013','2300100253','2026-2027','235UCS013','235','UCS','013','Naksh Arora','Computer Science and Engineering','9876000253','Ghaziabad Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS014','2300100254','2026-2027','235UCS014','235','UCS','014','Navya Singh','Computer Science and Engineering','9876000254','Delhi','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS015','2300100255','2026-2027','235UCS015','235','UCS','015','Pranav Joshi','Computer Science and Engineering','9876000255','Meerut Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS016','2300100256','2026-2027','235UCS016','235','UCS','016','Riya Jain','Computer Science and Engineering','9876000256','Agra Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS017','2300100257','2026-2027','235UCS017','235','UCS','017','Rohan Chandra','Computer Science and Engineering','9876000257','Mathura Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS018','2300100258','2026-2027','235UCS018','235','UCS','018','Saanvi Patel','Computer Science and Engineering','9876000258','Aligarh Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS019','2300100259','2026-2027','235UCS019','235','UCS','019','Samarth Saxena','Computer Science and Engineering','9876000259','Hapur Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UCS' LIMIT 1),NULL,'235UCS020','2300100260','2026-2027','235UCS020','235','UCS','020','Siya Rao','Computer Science and Engineering','9876000260','Bulandshahr Uttar Pradesh','Computer Science and Engineering','School of Information and Communication Technology',3,5,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA001','2300100261','2026-2027','235UEA001','235','UEA','001','Vedant Gupta','Electronics AI and Machine Learning','9876000261','Greater Noida Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA002','2300100262','2026-2027','235UEA002','235','UEA','002','Vanya Bansal','Electronics AI and Machine Learning','9876000262','Noida Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA003','2300100263','2026-2027','235UEA003','235','UEA','003','Vihaan Malhotra','Electronics AI and Machine Learning','9876000263','Ghaziabad Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA004','2300100264','2026-2027','235UEA004','235','UEA','004','Zara Sharma','Electronics AI and Machine Learning','9876000264','Delhi','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA005','2300100265','2026-2027','235UEA005','235','UEA','005','Aarav Yadav','Electronics AI and Machine Learning','9876000265','Meerut Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA006','2300100266','2026-2027','235UEA006','235','UEA','006','Aditi Tiwari','Electronics AI and Machine Learning','9876000266','Agra Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA007','2300100267','2026-2027','235UEA007','235','UEA','007','Advik Khan','Electronics AI and Machine Learning','9876000267','Mathura Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA008','2300100268','2026-2027','235UEA008','235','UEA','008','Ananya Kumar','Electronics AI and Machine Learning','9876000268','Aligarh Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA009','2300100269','2026-2027','235UEA009','235','UEA','009','Arjun Kapoor','Electronics AI and Machine Learning','9876000269','Hapur Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA010','2300100270','2026-2027','235UEA010','235','UEA','010','Avni Saini','Electronics AI and Machine Learning','9876000270','Bulandshahr Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA011','2300100271','2026-2027','235UEA011','235','UEA','011','Dev Verma','Electronics AI and Machine Learning','9876000271','Greater Noida Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA012','2300100272','2026-2027','235UEA012','235','UEA','012','Diya Mehta','Electronics AI and Machine Learning','9876000272','Noida Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA013','2300100273','2026-2027','235UEA013','235','UEA','013','Ishaan Agarwal','Electronics AI and Machine Learning','9876000273','Ghaziabad Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA014','2300100274','2026-2027','235UEA014','235','UEA','014','Kavya Srivastava','Electronics AI and Machine Learning','9876000274','Delhi','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA015','2300100275','2026-2027','235UEA015','235','UEA','015','Krish Mishra','Electronics AI and Machine Learning','9876000275','Meerut Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA016','2300100276','2026-2027','235UEA016','235','UEA','016','Meera Chauhan','Electronics AI and Machine Learning','9876000276','Agra Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA017','2300100277','2026-2027','235UEA017','235','UEA','017','Naksh Arora','Electronics AI and Machine Learning','9876000277','Mathura Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA018','2300100278','2026-2027','235UEA018','235','UEA','018','Navya Singh','Electronics AI and Machine Learning','9876000278','Aligarh Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA019','2300100279','2026-2027','235UEA019','235','UEA','019','Pranav Joshi','Electronics AI and Machine Learning','9876000279','Hapur Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEA' LIMIT 1),NULL,'235UEA020','2300100280','2026-2027','235UEA020','235','UEA','020','Riya Jain','Electronics AI and Machine Learning','9876000280','Bulandshahr Uttar Pradesh','Electronics AI and Machine Learning','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC001','2300100281','2026-2027','235UEC001','235','UEC','001','Rohan Chandra','Electronics and Communication Engineering','9876000281','Greater Noida Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC002','2300100282','2026-2027','235UEC002','235','UEC','002','Saanvi Patel','Electronics and Communication Engineering','9876000282','Noida Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC003','2300100283','2026-2027','235UEC003','235','UEC','003','Samarth Saxena','Electronics and Communication Engineering','9876000283','Ghaziabad Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC004','2300100284','2026-2027','235UEC004','235','UEC','004','Siya Rao','Electronics and Communication Engineering','9876000284','Delhi','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC005','2300100285','2026-2027','235UEC005','235','UEC','005','Vedant Gupta','Electronics and Communication Engineering','9876000285','Meerut Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC006','2300100286','2026-2027','235UEC006','235','UEC','006','Vanya Bansal','Electronics and Communication Engineering','9876000286','Agra Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC007','2300100287','2026-2027','235UEC007','235','UEC','007','Vihaan Malhotra','Electronics and Communication Engineering','9876000287','Mathura Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC008','2300100288','2026-2027','235UEC008','235','UEC','008','Zara Sharma','Electronics and Communication Engineering','9876000288','Aligarh Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC009','2300100289','2026-2027','235UEC009','235','UEC','009','Aarav Yadav','Electronics and Communication Engineering','9876000289','Hapur Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC010','2300100290','2026-2027','235UEC010','235','UEC','010','Aditi Tiwari','Electronics and Communication Engineering','9876000290','Bulandshahr Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC011','2300100291','2026-2027','235UEC011','235','UEC','011','Advik Khan','Electronics and Communication Engineering','9876000291','Greater Noida Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC012','2300100292','2026-2027','235UEC012','235','UEC','012','Ananya Kumar','Electronics and Communication Engineering','9876000292','Noida Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC013','2300100293','2026-2027','235UEC013','235','UEC','013','Arjun Kapoor','Electronics and Communication Engineering','9876000293','Ghaziabad Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC014','2300100294','2026-2027','235UEC014','235','UEC','014','Avni Saini','Electronics and Communication Engineering','9876000294','Delhi','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC015','2300100295','2026-2027','235UEC015','235','UEC','015','Dev Verma','Electronics and Communication Engineering','9876000295','Meerut Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC016','2300100296','2026-2027','235UEC016','235','UEC','016','Diya Mehta','Electronics and Communication Engineering','9876000296','Agra Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC017','2300100297','2026-2027','235UEC017','235','UEC','017','Ishaan Agarwal','Electronics and Communication Engineering','9876000297','Mathura Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC018','2300100298','2026-2027','235UEC018','235','UEC','018','Kavya Srivastava','Electronics and Communication Engineering','9876000298','Aligarh Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC019','2300100299','2026-2027','235UEC019','235','UEC','019','Krish Mishra','Electronics and Communication Engineering','9876000299','Hapur Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UEC' LIMIT 1),NULL,'235UEC020','2300100300','2026-2027','235UEC020','235','UEC','020','Meera Chauhan','Electronics and Communication Engineering','9876000300','Bulandshahr Uttar Pradesh','Electronics and Communication Engineering','School of Engineering',2,3,'B','regular','none','verified','active')
ON DUPLICATE KEY UPDATE programme_id=VALUES(programme_id),enrollment_number=VALUES(enrollment_number),academic_session=VALUES(academic_session),roll_no_original=VALUES(roll_no_original),registration_prefix=VALUES(registration_prefix),programme_code_detected=VALUES(programme_code_detected),student_sequence=VALUES(student_sequence),name=VALUES(name),branch=VALUES(branch),mobile_number=VALUES(mobile_number),address=VALUES(address),department_name=VALUES(department_name),school_name=VALUES(school_name),current_year_of_study=VALUES(current_year_of_study),semester=VALUES(semester),section=VALUES(section),admission_type=VALUES(admission_type),parsing_status='verified',status='active';

INSERT INTO students (programme_id,batch_id,roll_no_original,enrollment_number,academic_session,normalized_roll_no,registration_prefix,programme_code_detected,student_sequence,name,branch,mobile_number,address,department_name,school_name,current_year_of_study,semester,section,admission_type,special_status,parsing_status,status) VALUES
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT001','2300100301','2026-2027','235UIT001','235','UIT','001','Naksh Arora','Information Technology','9876000301','Greater Noida Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT002','2300100302','2026-2027','235UIT002','235','UIT','002','Navya Singh','Information Technology','9876000302','Noida Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT003','2300100303','2026-2027','235UIT003','235','UIT','003','Pranav Joshi','Information Technology','9876000303','Ghaziabad Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT004','2300100304','2026-2027','235UIT004','235','UIT','004','Riya Jain','Information Technology','9876000304','Delhi','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT005','2300100305','2026-2027','235UIT005','235','UIT','005','Rohan Chandra','Information Technology','9876000305','Meerut Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT006','2300100306','2026-2027','235UIT006','235','UIT','006','Saanvi Patel','Information Technology','9876000306','Agra Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT007','2300100307','2026-2027','235UIT007','235','UIT','007','Samarth Saxena','Information Technology','9876000307','Mathura Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT008','2300100308','2026-2027','235UIT008','235','UIT','008','Siya Rao','Information Technology','9876000308','Aligarh Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT009','2300100309','2026-2027','235UIT009','235','UIT','009','Vedant Gupta','Information Technology','9876000309','Hapur Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT010','2300100310','2026-2027','235UIT010','235','UIT','010','Vanya Bansal','Information Technology','9876000310','Bulandshahr Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT011','2300100311','2026-2027','235UIT011','235','UIT','011','Vihaan Malhotra','Information Technology','9876000311','Greater Noida Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT012','2300100312','2026-2027','235UIT012','235','UIT','012','Zara Sharma','Information Technology','9876000312','Noida Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT013','2300100313','2026-2027','235UIT013','235','UIT','013','Aarav Yadav','Information Technology','9876000313','Ghaziabad Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT014','2300100314','2026-2027','235UIT014','235','UIT','014','Aditi Tiwari','Information Technology','9876000314','Delhi','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT015','2300100315','2026-2027','235UIT015','235','UIT','015','Advik Khan','Information Technology','9876000315','Meerut Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT016','2300100316','2026-2027','235UIT016','235','UIT','016','Ananya Kumar','Information Technology','9876000316','Agra Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT017','2300100317','2026-2027','235UIT017','235','UIT','017','Arjun Kapoor','Information Technology','9876000317','Mathura Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT018','2300100318','2026-2027','235UIT018','235','UIT','018','Avni Saini','Information Technology','9876000318','Aligarh Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT019','2300100319','2026-2027','235UIT019','235','UIT','019','Dev Verma','Information Technology','9876000319','Hapur Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UIT' LIMIT 1),NULL,'235UIT020','2300100320','2026-2027','235UIT020','235','UIT','020','Diya Mehta','Information Technology','9876000320','Bulandshahr Uttar Pradesh','Information Technology','School of Information and Communication Technology',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL001','2300100321','2026-2027','235UVL001','235','UVL','001','Ishaan Agarwal','VLSI Design and Embedded Systems','9876000321','Greater Noida Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL002','2300100322','2026-2027','235UVL002','235','UVL','002','Kavya Srivastava','VLSI Design and Embedded Systems','9876000322','Noida Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL003','2300100323','2026-2027','235UVL003','235','UVL','003','Krish Mishra','VLSI Design and Embedded Systems','9876000323','Ghaziabad Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL004','2300100324','2026-2027','235UVL004','235','UVL','004','Meera Chauhan','VLSI Design and Embedded Systems','9876000324','Delhi','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL005','2300100325','2026-2027','235UVL005','235','UVL','005','Naksh Arora','VLSI Design and Embedded Systems','9876000325','Meerut Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL006','2300100326','2026-2027','235UVL006','235','UVL','006','Navya Singh','VLSI Design and Embedded Systems','9876000326','Agra Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL007','2300100327','2026-2027','235UVL007','235','UVL','007','Pranav Joshi','VLSI Design and Embedded Systems','9876000327','Mathura Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL008','2300100328','2026-2027','235UVL008','235','UVL','008','Riya Jain','VLSI Design and Embedded Systems','9876000328','Aligarh Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL009','2300100329','2026-2027','235UVL009','235','UVL','009','Rohan Chandra','VLSI Design and Embedded Systems','9876000329','Hapur Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL010','2300100330','2026-2027','235UVL010','235','UVL','010','Saanvi Patel','VLSI Design and Embedded Systems','9876000330','Bulandshahr Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'A','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL011','2300100331','2026-2027','235UVL011','235','UVL','011','Samarth Saxena','VLSI Design and Embedded Systems','9876000331','Greater Noida Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL012','2300100332','2026-2027','235UVL012','235','UVL','012','Siya Rao','VLSI Design and Embedded Systems','9876000332','Noida Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL013','2300100333','2026-2027','235UVL013','235','UVL','013','Vedant Gupta','VLSI Design and Embedded Systems','9876000333','Ghaziabad Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL014','2300100334','2026-2027','235UVL014','235','UVL','014','Vanya Bansal','VLSI Design and Embedded Systems','9876000334','Delhi','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL015','2300100335','2026-2027','235UVL015','235','UVL','015','Vihaan Malhotra','VLSI Design and Embedded Systems','9876000335','Meerut Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL016','2300100336','2026-2027','235UVL016','235','UVL','016','Zara Sharma','VLSI Design and Embedded Systems','9876000336','Agra Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL017','2300100337','2026-2027','235UVL017','235','UVL','017','Aarav Yadav','VLSI Design and Embedded Systems','9876000337','Mathura Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL018','2300100338','2026-2027','235UVL018','235','UVL','018','Aditi Tiwari','VLSI Design and Embedded Systems','9876000338','Aligarh Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL019','2300100339','2026-2027','235UVL019','235','UVL','019','Advik Khan','VLSI Design and Embedded Systems','9876000339','Hapur Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active'),
((SELECT id FROM programmes WHERE code='UVL' LIMIT 1),NULL,'235UVL020','2300100340','2026-2027','235UVL020','235','UVL','020','Ananya Kumar','VLSI Design and Embedded Systems','9876000340','Bulandshahr Uttar Pradesh','VLSI Design and Embedded Systems','School of Engineering',2,3,'B','regular','none','verified','active')
ON DUPLICATE KEY UPDATE programme_id=VALUES(programme_id),enrollment_number=VALUES(enrollment_number),academic_session=VALUES(academic_session),roll_no_original=VALUES(roll_no_original),registration_prefix=VALUES(registration_prefix),programme_code_detected=VALUES(programme_code_detected),student_sequence=VALUES(student_sequence),name=VALUES(name),branch=VALUES(branch),mobile_number=VALUES(mobile_number),address=VALUES(address),department_name=VALUES(department_name),school_name=VALUES(school_name),current_year_of_study=VALUES(current_year_of_study),semester=VALUES(semester),section=VALUES(section),admission_type=VALUES(admission_type),parsing_status='verified',status='active';

INSERT INTO faculty (school_id,department_id,employee_id,name,designation,email,phone,status,duty_count) VALUES
((SELECT id FROM schools WHERE code='ICT' LIMIT 1),NULL,'GBU-LARGE-F001','Dr. Ananya Mishra','Professor','ananya.mishra.1@example.test','9765000001','active',0),
((SELECT id FROM schools WHERE code='ICT' LIMIT 1),NULL,'GBU-LARGE-F002','Dr. Dev Bansal','Associate Professor','dev.bansal.2@example.test','9765000002','active',0),
((SELECT id FROM schools WHERE code='ICT' LIMIT 1),NULL,'GBU-LARGE-F003','Dr. Kavya Agarwal','Associate Professor','kavya.agarwal.3@example.test','9765000003','active',0),
((SELECT id FROM schools WHERE code='ICT' LIMIT 1),NULL,'GBU-LARGE-F004','Dr. Naksh Rao','Assistant Professor','naksh.rao.4@example.test','9765000004','active',0),
((SELECT id FROM schools WHERE code='ICT' LIMIT 1),NULL,'GBU-LARGE-F005','Dr. Riya Verma','Assistant Professor','riya.verma.5@example.test','9765000005','active',0),
((SELECT id FROM schools WHERE code='ICT' LIMIT 1),NULL,'GBU-LARGE-F006','Dr. Samarth Patel','Assistant Professor','samarth.patel.6@example.test','9765000006','active',0),
((SELECT id FROM schools WHERE code='ICT' LIMIT 1),NULL,'GBU-LARGE-F007','Dr. Vanya Kapoor','Assistant Professor','vanya.kapoor.7@example.test','9765000007','active',0),
((SELECT id FROM schools WHERE code='ICT' LIMIT 1),NULL,'GBU-LARGE-F008','Dr. Aarav Jain','Assistant Professor','aarav.jain.8@example.test','9765000008','active',0),
((SELECT id FROM schools WHERE code='SOE' LIMIT 1),NULL,'GBU-LARGE-F009','Dr. Ananya Khan','Professor','ananya.khan.9@example.test','9765000009','active',0),
((SELECT id FROM schools WHERE code='SOE' LIMIT 1),NULL,'GBU-LARGE-F010','Dr. Dev Singh','Associate Professor','dev.singh.10@example.test','9765000010','active',0),
((SELECT id FROM schools WHERE code='SOE' LIMIT 1),NULL,'GBU-LARGE-F011','Dr. Kavya Yadav','Associate Professor','kavya.yadav.11@example.test','9765000011','active',0),
((SELECT id FROM schools WHERE code='SOE' LIMIT 1),NULL,'GBU-LARGE-F012','Dr. Naksh Chauhan','Assistant Professor','naksh.chauhan.12@example.test','9765000012','active',0),
((SELECT id FROM schools WHERE code='SOE' LIMIT 1),NULL,'GBU-LARGE-F013','Dr. Riya Malhotra','Assistant Professor','riya.malhotra.13@example.test','9765000013','active',0),
((SELECT id FROM schools WHERE code='SOE' LIMIT 1),NULL,'GBU-LARGE-F014','Dr. Samarth Srivastava','Assistant Professor','samarth.srivastava.14@example.test','9765000014','active',0),
((SELECT id FROM schools WHERE code='SOE' LIMIT 1),NULL,'GBU-LARGE-F015','Dr. Vanya Gupta','Assistant Professor','vanya.gupta.15@example.test','9765000015','active',0),
((SELECT id FROM schools WHERE code='SOE' LIMIT 1),NULL,'GBU-LARGE-F016','Dr. Aarav Mehta','Assistant Professor','aarav.mehta.16@example.test','9765000016','active',0),
((SELECT id FROM schools WHERE code='SOM' LIMIT 1),NULL,'GBU-LARGE-F017','Dr. Ananya Saxena','Professor','ananya.saxena.17@example.test','9765000017','active',0),
((SELECT id FROM schools WHERE code='SOM' LIMIT 1),NULL,'GBU-LARGE-F018','Dr. Dev Saini','Associate Professor','dev.saini.18@example.test','9765000018','active',0),
((SELECT id FROM schools WHERE code='SOM' LIMIT 1),NULL,'GBU-LARGE-F019','Dr. Kavya Chandra','Associate Professor','kavya.chandra.19@example.test','9765000019','active',0),
((SELECT id FROM schools WHERE code='SOM' LIMIT 1),NULL,'GBU-LARGE-F020','Dr. Naksh Kumar','Assistant Professor','naksh.kumar.20@example.test','9765000020','active',0),
((SELECT id FROM schools WHERE code='SOM' LIMIT 1),NULL,'GBU-LARGE-F021','Dr. Riya Joshi','Assistant Professor','riya.joshi.21@example.test','9765000021','active',0),
((SELECT id FROM schools WHERE code='SOM' LIMIT 1),NULL,'GBU-LARGE-F022','Dr. Samarth Tiwari','Assistant Professor','samarth.tiwari.22@example.test','9765000022','active',0),
((SELECT id FROM schools WHERE code='SOM' LIMIT 1),NULL,'GBU-LARGE-F023','Dr. Vanya Arora','Assistant Professor','vanya.arora.23@example.test','9765000023','active',0),
((SELECT id FROM schools WHERE code='SOM' LIMIT 1),NULL,'GBU-LARGE-F024','Dr. Aarav Sharma','Assistant Professor','aarav.sharma.24@example.test','9765000024','active',0),
((SELECT id FROM schools WHERE code='SOBT' LIMIT 1),NULL,'GBU-LARGE-F025','Dr. Ananya Mishra','Professor','ananya.mishra.25@example.test','9765000025','active',0),
((SELECT id FROM schools WHERE code='SOBT' LIMIT 1),NULL,'GBU-LARGE-F026','Dr. Dev Bansal','Associate Professor','dev.bansal.26@example.test','9765000026','active',0),
((SELECT id FROM schools WHERE code='SOBT' LIMIT 1),NULL,'GBU-LARGE-F027','Dr. Kavya Agarwal','Associate Professor','kavya.agarwal.27@example.test','9765000027','active',0),
((SELECT id FROM schools WHERE code='SOBT' LIMIT 1),NULL,'GBU-LARGE-F028','Dr. Naksh Rao','Assistant Professor','naksh.rao.28@example.test','9765000028','active',0),
((SELECT id FROM schools WHERE code='SOBT' LIMIT 1),NULL,'GBU-LARGE-F029','Dr. Riya Verma','Assistant Professor','riya.verma.29@example.test','9765000029','active',0),
((SELECT id FROM schools WHERE code='SOBT' LIMIT 1),NULL,'GBU-LARGE-F030','Dr. Samarth Patel','Assistant Professor','samarth.patel.30@example.test','9765000030','active',0),
((SELECT id FROM schools WHERE code='SOBT' LIMIT 1),NULL,'GBU-LARGE-F031','Dr. Vanya Kapoor','Assistant Professor','vanya.kapoor.31@example.test','9765000031','active',0),
((SELECT id FROM schools WHERE code='SOBT' LIMIT 1),NULL,'GBU-LARGE-F032','Dr. Aarav Jain','Assistant Professor','aarav.jain.32@example.test','9765000032','active',0),
((SELECT id FROM schools WHERE code='SOVSAS' LIMIT 1),NULL,'GBU-LARGE-F033','Dr. Ananya Khan','Professor','ananya.khan.33@example.test','9765000033','active',0),
((SELECT id FROM schools WHERE code='SOVSAS' LIMIT 1),NULL,'GBU-LARGE-F034','Dr. Dev Singh','Associate Professor','dev.singh.34@example.test','9765000034','active',0),
((SELECT id FROM schools WHERE code='SOVSAS' LIMIT 1),NULL,'GBU-LARGE-F035','Dr. Kavya Yadav','Associate Professor','kavya.yadav.35@example.test','9765000035','active',0),
((SELECT id FROM schools WHERE code='SOVSAS' LIMIT 1),NULL,'GBU-LARGE-F036','Dr. Naksh Chauhan','Assistant Professor','naksh.chauhan.36@example.test','9765000036','active',0),
((SELECT id FROM schools WHERE code='SOVSAS' LIMIT 1),NULL,'GBU-LARGE-F037','Dr. Riya Malhotra','Assistant Professor','riya.malhotra.37@example.test','9765000037','active',0),
((SELECT id FROM schools WHERE code='SOVSAS' LIMIT 1),NULL,'GBU-LARGE-F038','Dr. Samarth Srivastava','Assistant Professor','samarth.srivastava.38@example.test','9765000038','active',0),
((SELECT id FROM schools WHERE code='SOVSAS' LIMIT 1),NULL,'GBU-LARGE-F039','Dr. Vanya Gupta','Assistant Professor','vanya.gupta.39@example.test','9765000039','active',0),
((SELECT id FROM schools WHERE code='SOVSAS' LIMIT 1),NULL,'GBU-LARGE-F040','Dr. Aarav Mehta','Assistant Professor','aarav.mehta.40@example.test','9765000040','active',0),
((SELECT id FROM schools WHERE code='SOHSS' LIMIT 1),NULL,'GBU-LARGE-F041','Dr. Ananya Saxena','Professor','ananya.saxena.41@example.test','9765000041','active',0),
((SELECT id FROM schools WHERE code='SOHSS' LIMIT 1),NULL,'GBU-LARGE-F042','Dr. Dev Saini','Associate Professor','dev.saini.42@example.test','9765000042','active',0),
((SELECT id FROM schools WHERE code='SOHSS' LIMIT 1),NULL,'GBU-LARGE-F043','Dr. Kavya Chandra','Associate Professor','kavya.chandra.43@example.test','9765000043','active',0),
((SELECT id FROM schools WHERE code='SOHSS' LIMIT 1),NULL,'GBU-LARGE-F044','Dr. Naksh Kumar','Assistant Professor','naksh.kumar.44@example.test','9765000044','active',0),
((SELECT id FROM schools WHERE code='SOHSS' LIMIT 1),NULL,'GBU-LARGE-F045','Dr. Riya Joshi','Assistant Professor','riya.joshi.45@example.test','9765000045','active',0),
((SELECT id FROM schools WHERE code='SOHSS' LIMIT 1),NULL,'GBU-LARGE-F046','Dr. Samarth Tiwari','Assistant Professor','samarth.tiwari.46@example.test','9765000046','active',0),
((SELECT id FROM schools WHERE code='SOHSS' LIMIT 1),NULL,'GBU-LARGE-F047','Dr. Vanya Arora','Assistant Professor','vanya.arora.47@example.test','9765000047','active',0),
((SELECT id FROM schools WHERE code='SOHSS' LIMIT 1),NULL,'GBU-LARGE-F048','Dr. Aarav Sharma','Assistant Professor','aarav.sharma.48@example.test','9765000048','active',0),
((SELECT id FROM schools WHERE code='SOBSC' LIMIT 1),NULL,'GBU-LARGE-F049','Dr. Ananya Mishra','Professor','ananya.mishra.49@example.test','9765000049','active',0),
((SELECT id FROM schools WHERE code='SOBSC' LIMIT 1),NULL,'GBU-LARGE-F050','Dr. Dev Bansal','Associate Professor','dev.bansal.50@example.test','9765000050','active',0),
((SELECT id FROM schools WHERE code='SOBSC' LIMIT 1),NULL,'GBU-LARGE-F051','Dr. Kavya Agarwal','Associate Professor','kavya.agarwal.51@example.test','9765000051','active',0),
((SELECT id FROM schools WHERE code='SOBSC' LIMIT 1),NULL,'GBU-LARGE-F052','Dr. Naksh Rao','Assistant Professor','naksh.rao.52@example.test','9765000052','active',0),
((SELECT id FROM schools WHERE code='SOBSC' LIMIT 1),NULL,'GBU-LARGE-F053','Dr. Riya Verma','Assistant Professor','riya.verma.53@example.test','9765000053','active',0),
((SELECT id FROM schools WHERE code='SOBSC' LIMIT 1),NULL,'GBU-LARGE-F054','Dr. Samarth Patel','Assistant Professor','samarth.patel.54@example.test','9765000054','active',0),
((SELECT id FROM schools WHERE code='SOBSC' LIMIT 1),NULL,'GBU-LARGE-F055','Dr. Vanya Kapoor','Assistant Professor','vanya.kapoor.55@example.test','9765000055','active',0),
((SELECT id FROM schools WHERE code='SOBSC' LIMIT 1),NULL,'GBU-LARGE-F056','Dr. Aarav Jain','Assistant Professor','aarav.jain.56@example.test','9765000056','active',0),
((SELECT id FROM schools WHERE code='SOLJG' LIMIT 1),NULL,'GBU-LARGE-F057','Dr. Ananya Khan','Professor','ananya.khan.57@example.test','9765000057','active',0),
((SELECT id FROM schools WHERE code='SOLJG' LIMIT 1),NULL,'GBU-LARGE-F058','Dr. Dev Singh','Associate Professor','dev.singh.58@example.test','9765000058','active',0),
((SELECT id FROM schools WHERE code='SOLJG' LIMIT 1),NULL,'GBU-LARGE-F059','Dr. Kavya Yadav','Associate Professor','kavya.yadav.59@example.test','9765000059','active',0),
((SELECT id FROM schools WHERE code='SOLJG' LIMIT 1),NULL,'GBU-LARGE-F060','Dr. Naksh Chauhan','Assistant Professor','naksh.chauhan.60@example.test','9765000060','active',0),
((SELECT id FROM schools WHERE code='SOLJG' LIMIT 1),NULL,'GBU-LARGE-F061','Dr. Riya Malhotra','Assistant Professor','riya.malhotra.61@example.test','9765000061','active',0),
((SELECT id FROM schools WHERE code='SOLJG' LIMIT 1),NULL,'GBU-LARGE-F062','Dr. Samarth Srivastava','Assistant Professor','samarth.srivastava.62@example.test','9765000062','active',0),
((SELECT id FROM schools WHERE code='SOLJG' LIMIT 1),NULL,'GBU-LARGE-F063','Dr. Vanya Gupta','Assistant Professor','vanya.gupta.63@example.test','9765000063','active',0),
((SELECT id FROM schools WHERE code='SOLJG' LIMIT 1),NULL,'GBU-LARGE-F064','Dr. Aarav Mehta','Assistant Professor','aarav.mehta.64@example.test','9765000064','active',0)
ON DUPLICATE KEY UPDATE school_id=VALUES(school_id),name=VALUES(name),designation=VALUES(designation),email=VALUES(email),phone=VALUES(phone),status='active';

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

-- Import verification
SELECT COUNT(*) AS demo_students FROM students WHERE normalized_roll_no REGEXP '^[0-9]{3}[A-Z]{3}[0-9]{3}$';
SELECT COUNT(*) AS demo_faculty FROM faculty WHERE employee_id LIKE 'GBU-LARGE-F%';
SELECT COUNT(*) AS ucs_curriculum_mappings FROM programme_courses pc JOIN programmes p ON p.id=pc.programme_id WHERE p.code='UCS';
