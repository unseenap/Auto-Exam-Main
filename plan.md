# School-wise Automatic Date-Sheet Generator — Implementation Plan

## 1. Purpose

Extend the GBU Examination Operations Platform so an authorized examination user can generate a complete draft date sheet for every selected programme and semester within a school in one operation.

The generator must:

- schedule all eligible programme subjects within the examination cycle;
- exclude Sundays and administrator-defined holidays;
- give higher-priority subjects earlier valid examination dates;
- maintain a configurable gap between examinations for the same student cohort;
- identify missing or contradictory data before generation;
- prevent programme, semester, subject, shift and calendar conflicts;
- allow users to lock or manually adjust papers and regenerate only the remaining papers;
- save every generated version as a draft before publication;
- preserve an audit trail of generation, changes and publication.

## 2. Terminology

| Term | Meaning |
|---|---|
| School | University school such as ICT, SOE or SOM |
| Programme/branch | Academic programme such as UCS, UCM or UAI |
| Cohort | Students belonging to a programme, semester and optional batch |
| Subject priority | Programme-specific scheduling rank; higher priority is scheduled earlier |
| Hard constraint | Rule that the generator is never permitted to violate |
| Soft preference | Rule the generator should optimize but may relax after explicit approval |
| Gap | Number of complete non-examination days required between two papers for one cohort |
| Locked paper | A generated or manual paper whose date and shift cannot be changed by regeneration |

## 3. User roles

| Action | Authorized roles |
|---|---|
| Maintain curriculum priority | System Administrator, Academic Coordinator |
| Maintain holidays | System Administrator, Controller of Examinations |
| Configure generation rules | System Administrator, Controller of Examinations |
| Generate school-wise draft | System Administrator, Controller of Examinations |
| Review and adjust draft | System Administrator, Controller of Examinations |
| Publish date sheet | System Administrator, Controller of Examinations |
| View reports and validation | Existing report-authorized roles |

Existing permissions can initially be reused:

- `academic.manage` for subject-priority maintenance;
- `exams.manage` for holidays, generation, review and publication.

## 4. Functional scope

### 4.1 School-wise selection

The generation wizard will provide:

- examination cycle;
- one or more schools;
- all active programmes within each selected school;
- optional exclusion of individual programmes;
- applicable semesters: odd, even or individually selected;
- examination category: regular, repeat, back paper, special or another supported category;
- batch scope where required;
- include/exclude subjects with zero eligible students;
- combine genuinely common subjects into one examination slot.

Selecting a school will select all eligible programmes by default. The user can expand the school and clear programmes that should not participate.

### 4.2 Holiday management

The existing `exam_calendar_dates` table remains the authoritative cycle calendar.

The calendar screen will support:

- automatic Sunday exclusion;
- optional Saturday exclusion;
- university holidays;
- restricted/local holidays;
- non-examination preparation days;
- manually reopened dates;
- a holiday name or administrative note;
- bulk holiday entry by date list or CSV.

A date is usable only when `is_exam_day = 1`. Holidays remain stored in the calendar with `is_exam_day = 0` and a meaningful note.

### 4.3 Programme-specific subject priority

Priority belongs to a curriculum mapping, not to the global subject, because the same course may have a different importance for another programme.

Priority scale:

| Priority | Meaning | Scheduling behavior |
|---:|---|---|
| 100 | Critical/core priority | Earliest valid dates |
| 80 | High | Scheduled before normal subjects |
| 50 | Normal | Default priority |
| 20 | Low | Later valid dates |
| 0 | No preference | Ordered using remaining scheduling rules |

The user interface should display priorities as Critical, High, Normal, Low and No preference while storing the numeric value.

If two subjects have equal priority, the scheduler uses these tie-breakers in order:

1. number of participating programmes for a common subject;
2. eligible-student count, highest first;
3. fewer available valid slots first;
4. core before elective before other categories;
5. subject code for deterministic output.

Priority controls ordering but never overrides a hard constraint. A high-priority paper may move later if an earlier position would break the cohort gap or create a conflict.

### 4.4 Gap configuration

Generation rules will allow:

- minimum complete gap days between papers for the same cohort;
- maximum papers per cohort per calendar week;
- maximum one paper per cohort per day;
- whether holidays count as gap days;
- whether Sundays count as gap days;
- separate gap rules for regular and back-paper examinations;
- optional programme-specific overrides;
- rule-relaxation policy when the requested schedule is mathematically infeasible.

Recommended default:

```text
Minimum complete gap days: 1
Maximum papers per cohort per day: 1
Maximum papers per cohort per week: 3
Sunday: holiday
Holiday counts toward gap: yes
Automatic hard-rule relaxation: disabled
```

## 5. Generation wizard

### Step 1 — Select scope

The page asks for the examination cycle, schools, programmes, semesters and examination category.

### Step 2 — Calendar

The page shows every date from the cycle start to end with these states:

- available examination day;
- Sunday;
- holiday;
- blocked/preparation day;
- manually reopened day.

The user can add or remove holidays before proceeding.

### Step 3 — Rules

The user configures minimum gap, weekly limit, allowed shifts, priority behavior, common-subject behavior and capacity checking.

### Step 4 — Pre-generation validation

The application produces a grouped checklist before enabling generation.

#### Academic validation

- every selected programme belongs to the selected school;
- every selected programme has an active curriculum;
- selected semesters contain subjects;
- curriculum mappings have valid subject priorities;
- courses are active;
- active-student totals are informational only and do not block date-sheet generation;
- common subjects have consistent codes and names.

#### Calendar validation

- cycle dates exist;
- at least one examination day remains after holidays;
- at least one shift is selected;
- selected shifts belong to the cycle;
- no generated date is outside the cycle;
- existing locked papers occupy valid dates and shifts.

#### Feasibility validation

- required papers compared with available slots;
- minimum number of calendar days required for the requested gap;
- conflicts with already scheduled or locked papers;
- common-subject cohort overlaps;
- optional available seating capacity for the combined eligible-student count;
- programmes that cannot be fully scheduled under current rules.

Validation states:

```text
PASS     Safe to generate
WARNING  Generation is possible but review is required
BLOCKED  A hard constraint or missing prerequisite prevents generation
```

The Generate button remains disabled while any BLOCKED item exists.

### Step 5 — Generate draft

The generator creates a new versioned run and places papers into valid slots. Nothing is published automatically.

### Step 6 — Review

The review screen contains:

- date-sheet matrix grouped by school, programme and semester;
- priority and reason for each placement;
- eligible-student count;
- gap before and after each paper;
- warnings and relaxed preferences;
- unscheduled papers with explicit reasons;
- drag/move action restricted to valid target slots;
- paper lock/unlock action;
- regenerate unlocked papers action;
- comparison with the previous generated version.

### Step 7 — Approve and publish

Publication requires a final validation pass. Publishing records the user, timestamp, run version and rule snapshot.

## 6. Scheduling rules

### 6.1 Hard constraints

The generator must never violate:

1. The date must be an enabled examination date.
2. Sundays and holidays marked unavailable cannot receive a paper.
3. The shift must belong to the selected cycle.
4. A subject must belong to the programme and semester curriculum.
5. A cohort cannot have more than one examination in the same date/shift.
6. A cohort cannot exceed its configured daily paper limit.
7. The configured mandatory minimum gap must be satisfied.
8. The same course/category cannot be duplicated in the same cycle slot.
9. A locked paper cannot be moved or replaced.
10. A common examination cannot include the same cohort twice.
11. When capacity checking is mandatory, combined eligible students cannot exceed available usable seats.

### 6.2 Soft preferences

The scoring system should prefer:

- higher-priority subjects on earlier dates;
- balanced papers across the examination window;
- morning shifts for larger cohorts;
- fewer consecutive examination days;
- core subjects before elective subjects when priorities are equal;
- fewer gaps substantially longer than requested;
- stable placement of papers retained from the previous version;
- balanced daily student load across the university.

Each soft-rule penalty must be recorded so users can understand why one schedule scored better than another.

## 7. Scheduling algorithm

Use a deterministic constraint-based algorithm with backtracking and repair.

### 7.1 Build scheduling tasks

Create one task for every selected programme, semester and subject. Merge tasks only when the subject is genuinely common and the participating cohorts do not conflict.

Each task includes:

- school and programme;
- semester and optional batch;
- course and category;
- subject priority;
- eligible-student count;
- allowed dates and shifts;
- associated cohorts;
- locked status;
- list of constraints.

### 7.2 Sort hardest tasks first

Order tasks by:

1. locked/common papers;
2. priority descending;
3. fewest valid slots;
4. eligible-student count descending;
5. deterministic programme, semester and course code.

### 7.3 Generate candidate slots

For every task, remove slots that violate hard constraints. Score remaining slots using date order, gap quality, shift preference, capacity and schedule balance.

### 7.4 Assign and backtrack

Assign the highest-scoring slot. If a later task has no valid slot, backtrack and try the next-best earlier assignment. Use a defined attempt/time limit suitable for shared PHP hosting.

### 7.5 Repair and report

After the first pass, attempt local swaps to improve soft-rule scores. Any task that still cannot be placed becomes an unscheduled item with a machine-readable reason and a clear user message.

### 7.6 Determinism

Identical data, rule configuration and locked papers must produce identical output. Store a checksum of the inputs and rule snapshot with each run.

## 8. Database changes

Create a new migration, suggested name:

```text
database/schema.sql
```

### 8.1 Extend `programme_courses`

Add:

```sql
subject_priority SMALLINT UNSIGNED NOT NULL DEFAULT 50
```

Recommended index:

```sql
INDEX idx_curriculum_scheduler
    (programme_id, semester, subject_priority, category)
```

### 8.2 Extend `exam_calendar_dates`

Add a calendar classification:

```sql
day_type ENUM(
  'exam_day',
  'sunday',
  'holiday',
  'restricted_holiday',
  'preparation_day',
  'blocked'
) NOT NULL DEFAULT 'exam_day'
```

Continue using `is_exam_day` as the fast availability flag and `note` for the holiday name or reason.

### 8.3 Add `scheduling_rules`

Suggested fields:

```text
id
cycle_id
name
minimum_gap_days
maximum_papers_per_day
maximum_papers_per_week
holidays_count_as_gap
sundays_count_as_gap
capacity_check_mode
common_subject_mode
allow_soft_rule_relaxation
created_by
created_at
updated_at
```

### 8.4 Add `scheduling_runs`

Suggested fields:

```text
id
cycle_id
rule_id
version_no
scope_type
scope_snapshot_json
rule_snapshot_json
input_checksum
status
score
scheduled_count
unscheduled_count
warning_count
generated_by
generated_at
approved_by
approved_at
published_at
```

Suggested statuses:

```text
validating, blocked, generating, draft, approved, published, superseded, failed
```

### 8.5 Add `scheduling_run_items`

Suggested fields:

```text
id
run_id
examination_id
programme_id
batch_id
semester
course_id
subject_priority
eligible_count
assigned_date
shift_id
is_locked
placement_score
placement_reason_json
status
failure_reason
```

### 8.6 Add `scheduling_conflicts`

Suggested fields:

```text
id
run_id
run_item_id
severity
conflict_code
message
details_json
is_resolved
resolved_by
resolved_at
```

### 8.7 Extend `examinations`

Add:

```text
generated_by_run_id
is_locked
generation_source
rule_relaxation_reason
```

The migration and canonical `database/schema.sql` must both be updated. `database/seed.sql` should add default scheduler settings without hard-coding a database name.

## 9. Application components

### 9.1 New domain services

```text
app/Exams/AutomaticScheduler.php
app/Exams/SchedulingValidator.php
app/Exams/SchedulingRuleRepository.php
app/Exams/SchedulingRunRepository.php
app/Exams/SchedulingScorer.php
app/Exams/CommonSubjectResolver.php
```

Responsibilities must remain separated: validation, candidate generation, assignment, scoring and persistence should not be placed directly in the main application router.

### 9.2 New views

```text
resources/views/exams/automatic-scope.php
resources/views/exams/automatic-calendar.php
resources/views/exams/automatic-rules.php
resources/views/exams/automatic-validation.php
resources/views/exams/automatic-review.php
resources/views/exams/automatic-history.php
resources/views/exams/holidays.php
```

### 9.3 Suggested routes

```text
GET  /exam-cycles/{cycle}/holidays
POST /exam-cycles/{cycle}/holidays

GET  /date-sheets/{cycle}/automatic
POST /date-sheets/{cycle}/automatic/validate
POST /date-sheets/{cycle}/automatic/generate
GET  /date-sheets/{cycle}/automatic/runs/{run}
POST /date-sheets/{cycle}/automatic/runs/{run}/items/{item}/lock
POST /date-sheets/{cycle}/automatic/runs/{run}/items/{item}/move
POST /date-sheets/{cycle}/automatic/runs/{run}/regenerate
POST /date-sheets/{cycle}/automatic/runs/{run}/approve
POST /date-sheets/{cycle}/automatic/runs/{run}/publish
```

All POST routes require CSRF validation and `exams.manage` permission.

## 10. User-interface requirements

- Use a seven-step progress indicator for the generation wizard.
- Preserve selected scope and rules while moving between steps.
- Display schools as expandable cards with programme and semester counts.
- Provide Select all, Clear all, Odd semesters and Even semesters actions.
- Display holidays in a calendar and accessible list view.
- Allow curriculum priority to be edited individually and through bulk CSV/XLSX import.
- Use clear PASS, WARNING and BLOCKED validation states with icons and text.
- Explain every conflict in plain language.
- Never hide unscheduled papers.
- Show a summary before any destructive regeneration.
- Make printed output follow the existing Gautam Buddha University date-sheet format.
- Ensure keyboard navigation, visible focus, responsive tables and print styles.

## 11. Priority bulk-upload format

Provide this template:

```csv
School Code,Programme Code,Semester,Course Code,Subject Priority
ICT,UCS,1,MA101,100
ICT,UCS,1,PH102,80
ICT,UCS,1,EE102,50
```

Validation rules:

- school, programme and course must exist;
- programme must belong to the school;
- course must be mapped to the programme and semester;
- priority must be between 0 and 100;
- duplicate programme-semester-course rows must be rejected;
- preview is required before commit.

## 12. Holiday bulk-upload format

Provide this template:

```csv
Date,Day Type,Is Exam Day,Note
2026-12-06,sunday,0,Sunday
2026-12-08,holiday,0,University holiday
2026-12-12,exam_day,1,Saturday examination permitted
```

Validation rules:

- date must be inside the examination cycle;
- day type must be supported;
- duplicate dates must be merged only after confirmation;
- reopening a Sunday or holiday requires an explicit warning;
- preview is required before commit.

## 13. Validation codes

Use stable codes for testing and reporting:

```text
MISSING_CURRICULUM
NO_ACTIVE_SUBJECTS
NO_ACTIVE_STUDENTS
INVALID_SUBJECT_PRIORITY
NO_EXAM_DATES
NO_SELECTED_SHIFTS
INSUFFICIENT_SLOTS
GAP_RULE_INFEASIBLE
COHORT_SLOT_CONFLICT
DUPLICATE_PAPER
LOCKED_PAPER_CONFLICT
COMMON_SUBJECT_MISMATCH
INSUFFICIENT_SEAT_CAPACITY
PAPER_UNSCHEDULED
```

## 14. Audit requirements

Record these actions:

```text
scheduling.validation_completed
scheduling.generation_started
scheduling.generation_completed
scheduling.generation_failed
scheduling.paper_locked
scheduling.paper_unlocked
scheduling.paper_moved
scheduling.regenerated
scheduling.rules_relaxed
scheduling.approved
scheduling.published
calendar.holiday_created
calendar.holiday_updated
curriculum.priority_updated
```

Audit data should include cycle ID, run ID, selected scope, rules, affected paper IDs and before/after values where applicable.

## 15. Implementation phases

### Implementation status — started 4 September 2026

- Phase 1 foundation implemented: priority and day-type columns, scheduling rule/run/item/conflict tables, examination generation metadata, canonical schema, MariaDB upgrade script, and hosted-package inclusion.
- Phase 2 partially implemented: per-programme subject priority in manual and bulk curriculum workflows; cycle calendar supports Sundays, holidays, preparation days, blocked days, availability, and notes.
- Phase 3 readiness validation implemented for school/programme/semester scope, curriculum prerequisites, calendar and shifts, available slots, requested gap, and existing-paper warnings. Student presence is intentionally not a generation prerequisite. Every run and result is persisted and audited.
- Phase 4 deterministic draft generation implemented: priority-ordered tasks, enabled-date and cycle-shift candidates, mandatory cohort gaps, daily limits, preservation of existing papers, generated examinations and eligibility, persisted placement reasons, unscheduled conflicts, and run review.
- Phase 5 controlled review implemented: lock/unlock, validated manual moves, locked-paper preservation, unlocked-only regeneration into a new run, audit events, and previous/current run comparison.
- Phase 6 publication workflow implemented: final validation gate, separate approval and publication actions, publication timestamps/users, generated-paper release to seating operations, audit events, and CSV export.
- Phase 7 delivery work implemented: isolated automatic-scheduling regression coverage, operator documentation, canonical README/schema documentation, hosted upgrade inclusion, and rebuilt InfinityFree package. Final live execution depends on an available local MariaDB service or the target hosted database.

### Phase 1 — Data model and migration

- Add subject priority and calendar day type.
- Create scheduling rule, run, item and conflict tables.
- Extend examinations with generation metadata.
- Update `schema.sql`, `seed.sql` and InfinityFree installer.
- Add rollback-safe migration verification queries.

**Completion condition:** both clean installation and existing-database upgrade succeed on MariaDB without privileged or temporary-table commands.

### Phase 2 — Priority and holiday management

- Add curriculum-priority fields and bulk import.
- Add cycle holiday calendar and bulk import.
- Add permissions, validation and audit events.

**Completion condition:** users can maintain priorities and holidays before generation, with preview and validation.

### Phase 3 — Readiness validator

- Implement academic, calendar and feasibility validation.
- Build grouped PASS/WARNING/BLOCKED results.
- Prevent generation when blocked.

**Completion condition:** incomplete data produces exact actionable messages and no examination records are changed.

### Phase 4 — Scheduling engine

- Build tasks and common-subject groups.
- Generate candidate slots.
- Implement priority ordering, hard constraints, scoring and backtracking.
- Persist run snapshots and unscheduled reasons.

**Completion condition:** identical inputs generate identical valid drafts and no hard constraint is violated.

### Phase 5 — Review and controlled regeneration

- Add date-sheet matrix review.
- Add lock, unlock and validated move actions.
- Regenerate unlocked items only.
- Compare run versions.

**Completion condition:** locked papers remain unchanged and every manual operation is audited.

### Phase 6 — Approval, publication and reports

- Add final validation gate.
- Add approval and publication states.
- Create university print/PDF layout and CSV export.
- Link published examinations to seating generation.

**Completion condition:** only approved, conflict-free runs can be published and used for downstream seating.

### Phase 7 — Quality and hosted deployment

- Add unit, integration and end-to-end tests.
- Test large multi-school data.
- Test InfinityFree PHP/MariaDB compatibility and request limits.
- Update the deployment package and operator documentation.

**Completion condition:** the production package installs cleanly and the full workflow passes with representative data.

## 16. Test plan

### Unit tests

- priority sorting and tie-breakers;
- Sunday and holiday exclusion;
- complete-gap calculation;
- candidate-slot generation;
- weekly and daily cohort limits;
- common-subject grouping;
- deterministic scoring;
- conflict-code generation.

### Integration tests

- school-to-programme scope resolution;
- curriculum and eligible-student loading;
- locked-paper handling;
- generated examination and cohort persistence;
- run rollback when generation fails;
- audit events;
- priority and holiday bulk import.

### End-to-end scenarios

1. Generate all ICT programmes for odd semesters with a one-day gap.
2. Generate all SOE programmes while excluding Sundays and two holidays.
3. Confirm higher-priority UCS subjects appear earlier when constraints allow.
4. Schedule a common subject for several programmes in one slot.
5. Produce a BLOCKED result when available slots are insufficient.
6. Lock two papers and regenerate the remaining schedule.
7. Move a paper and reject an invalid target slot.
8. Publish an approved schedule and use it for seating generation.
9. Repeat generation with identical inputs and confirm identical output.
10. Generate with large multi-school data under shared-host execution limits.

## 17. Acceptance criteria

The feature is complete when:

- an authorized user can select a school and schedule all selected programme subjects at once;
- Sundays and configured holidays never receive papers unless explicitly reopened;
- programme-specific subject priority influences earlier placement without violating hard constraints;
- configurable cohort gaps are enforced;
- validation clearly lists every missing prerequisite and conflict;
- generation produces a versioned draft rather than immediately publishing;
- common subjects can be scheduled for multiple cohorts in one examination;
- unscheduled papers are never silently omitted;
- users can lock, move and regenerate draft papers safely;
- final publication requires conflict-free validation and authorization;
- the process is deterministic, audited and compatible with InfinityFree MariaDB;
- `schema.sql`, `seed.sql`, upgrades, tests and deployment package remain synchronized.

## 18. Recommended delivery order

Implement in this order:

```text
Database migration
→ Priority management
→ Holiday calendar
→ Validation engine
→ Automatic scheduler
→ Review and locking
→ Approval/publication
→ Reports and deployment verification
```

This order makes each phase independently testable and prevents the scheduling engine from being built before its required academic and calendar data is reliable.
