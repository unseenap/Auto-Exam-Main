USE gbu_exam_operations;
CREATE TABLE IF NOT EXISTS seating_unallocated (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,allocation_id BIGINT UNSIGNED NOT NULL,examination_id BIGINT UNSIGNED NOT NULL,student_id BIGINT UNSIGNED NOT NULL,reason VARCHAR(120) NOT NULL DEFAULT 'insufficient_capacity',resolved_at DATETIME NULL,
 UNIQUE KEY uq_unallocated_student(allocation_id,student_id),
 CONSTRAINT fk_unallocated_allocation FOREIGN KEY(allocation_id) REFERENCES seating_allocations(id) ON DELETE CASCADE,
 CONSTRAINT fk_unallocated_exam FOREIGN KEY(examination_id) REFERENCES examinations(id),
 CONSTRAINT fk_unallocated_student FOREIGN KEY(student_id) REFERENCES students(id)
) ENGINE=InnoDB;
