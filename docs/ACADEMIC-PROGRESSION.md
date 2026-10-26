# Academic progression and automatic rollover

## Behaviour

The academic calendar defaults to 1 July for a new academic session / odd semester and 1 January for the even semester. An academic administrator can change both recurring dates in **Academic progression**. This is a calendar-based promotion policy for normal active students, not a claim that the student has passed examinations.

Normal students progress from their admission batch, programme duration and configured calendar. For admission in 2024 on an eight-semester programme: October 2026 is Year 3 / Semester 5, January 2027 is Year 3 / Semester 6, and July 2027 is Year 4 / Semester 7. A calendar year change alone does not increment the study year.

The student directory's academic session, study year, semester and active/inactive status are materialized from this policy. Identity, admission batch and roll/enrollment identifiers stay unchanged. Sections carry forward.

## UI

- **Academic progression** in the academic sidebar: calendar, enable/disable, last-check date, future-date previews, today's reconciliation, counts and recent runs.
- **Review filter**: changes, missing curriculum/data, held students, awaiting completion, withdrawn students and confirmed completion. Review results are paginated at 100 records.
- **History & progression** on each student: term placements, course-registration counts, change history, hold/withdraw/completion controls and a semester delay.
- Exam creation defaults to the actual academic session and updates it when the start date changes. New regular cycles are checked against the calendar. Automatic scheduling rejects an inconsistent legacy cycle. The progression screen provides an audited session-alignment action for empty draft cycles only.

## Exceptions and completion

- **Hold** freezes the saved year and semester. Imported repeat/not-promoted/unverified students default to held rather than being advanced silently.
- **Semester delay** persists after a hold is released. Two semesters represent a repeated year. Resuming automatic progression with zero delay returns to the batch's nominal calendar semester.
- **Withdrawn** excludes the student from regular cohorts.
- After the normal programme duration, a student becomes **Awaiting completion**, with inactive master status and the final year/semester retained. This does not mean graduated. Completion requires an academic administrator's explicit verified-completion selection and recorded evidence/reason.
- Completed batches mean normal teaching duration ended. Students with approved delays retain their own progression controls. Explicit repeat/special registrations remain available to eligible pass-out students; withdrawn students are excluded.
- Existing inactive/completed students are preserved as exceptions on initial reconciliation.

## Registrations and historical exams

`student_term_enrollments` stores each student's observed session/term placement. The first run preserves original placements before updating current records. Subsequent transitions create new snapshots. Missed terms are not fabricated as passed or attended; after downtime the system catches up directly to the current period and retains the last observed placement.

Matching active batch/semester/section core, common and bridge curriculum mappings receive idempotent course registrations. A department elective selected in a regular date sheet registers the entire matching class. Unscheduled elective alternatives are not assigned automatically. Back papers require explicit student registrations; passed results are never invented. Missing curriculum is reported without guessing. Inactive course mappings are excluded from new registration generation.

Exam cohort eligibility reads the placement recorded for the examination session. Later promotions do not rewrite published papers, existing eligibility, seating or attendance. For legacy records without any term snapshots, the previous saved-placement matching remains available. Automatic draft generation creates cohort eligibility and registers department-assigned electives for the whole cohort and leaves only back-paper candidates pending explicit registration. Existing elective registrations can also be reconciled before seating, including published papers without published seating; the change is audited.

## Scheduling and deployment

For an existing installation, run `php database/upgrade-academic-rollover.php`. It saves a full pre-upgrade JSON database snapshot under `storage/backups/` before installing the six additive tables. Do not reinstall the main schema over existing data. Clean installations already include the tables in `database/schema.sql`.

Windows/XAMPP: run `tools/install-academic-rollover-task.ps1` to register **AutoExamAcademicRollover** at 00:15 daily. It runs as the installing user while that user is signed in. The PC and MySQL must be running. Start-when-available handles missed triggers. On other hosts, configure their scheduler to run `php /absolute/project/path/tools/academic-rollover.php` daily. This is a local server task, not a Codex reminder.

The first authorized app request also checks for due progression. This catches up when the daily job could not run. A singleton row lock serializes concurrent jobs, and one transaction protects placements, registrations, history and last-check metadata. Repeated runs cannot double-promote students. Within the same academic period the daily check is constant-time unless a data change invalidated it. Student saves/imports reconcile immediately; academic-master and curriculum changes invalidate the check for the next request.

CLI diagnostics:

```text
php tools/academic-rollover.php --preview
php tools/academic-rollover.php
php tools/academic-rollover.php --force
```

Production CLI runs always use today's date. Future dates are allowed only in read-only UI previews. Historical runs cannot move the rollover clock backwards. Failures roll back the rollover and return a nonzero CLI status; web requests report that academic administration needs attention rather than continuing with partially updated eligibility.

## Validation

`tests/AcademicCalendarTest.php` checks exact boundaries, delays, custom calendars and scheduler consistency. `tests/AcademicRolloverTest.php` uses a disposable database to test preview purity, core registrations, held/withdrawn/future students, Year 3 to Year 4, verified completion, historical exam matching, repeated execution, rollback after a simulated database failure and disabled progression. Existing scheduling and seating regression tests also exercise the new schema.

Results import, elective self-service, changing a student's original admission batch for repeats, and automatic creation of new admission intakes are not part of calendar progression. Staff still supply admissions, approved curriculum changes, department elective offerings and back-paper registrations and academic exceptions.
