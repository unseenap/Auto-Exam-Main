USE gbu_exam_operations;

INSERT IGNORE INTO programme_courses (programme_id,course_id,semester,category)
SELECT DISTINCT ec.programme_id,e.course_id,ec.semester,'core'
FROM examinations e
JOIN examination_cohorts ec ON ec.examination_id=e.id
WHERE ec.semester IS NOT NULL;
