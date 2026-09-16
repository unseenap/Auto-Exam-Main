# Automatic Date-Sheet Operations Guide

## Before scheduling

1. Import the current database schema or apply upgrades `005` and `006` to an existing database.
2. Confirm each programme has active subjects mapped to the correct semester.
3. Set each subject priority from 1 to 100. A smaller number is scheduled earlier.
4. Create an examination cycle and its shifts.
5. Open **Calendar & holidays** and classify every unavailable date.

## Generate a school-wise draft

1. Open **Exam cycles**, then the required date sheet.
2. Select **Automatic scheduling**.
3. Select one school, its programmes and required semesters.
4. Configure the mandatory gap and maximum papers per cohort per day.
5. Run pre-generation validation.
6. Resolve every BLOCKED check. WARNING items require review but do not prevent generation.
7. Select **Generate deterministic draft**.

The generator considers subject priority, enabled dates, shifts, existing papers, cohort gaps and daily limits. Student records are not required to create a date sheet; a paper has zero eligible students until matching active students are loaded. Generated papers remain drafts.

## Review and regenerate

- Lock a placement that must not change.
- Unlock a paper before moving it.
- Manual moves are rejected if they violate the calendar, cycle shift, mandatory gap, daily limit or duplicate-subject constraint.
- **Regenerate unlocked papers** creates a new run. Locked examinations retain their existing IDs and slots.
- Use **Compare runs** to see added, removed, moved and unchanged placements.

## Approve and publish

The final gate checks that every subject is scheduled, no blocking conflict remains, and every paper uses an enabled date and valid shift.

1. Select **Approve run** after all checks pass.
2. Review the approved run; editing controls are closed.
3. Select **Publish date sheet**.

Publication marks the run, cycle and included examinations as published and makes the papers available to downstream seating operations. Approval, publication, locks, moves and regeneration are written to the audit log.

## Database deployment

- For a local clean installation, import `database/schema.sql` and then `database/seed.sql`.
- For InfinityFree, import the generated `SETUP/infinityfree_database_import.sql`; it is built from those same two canonical files.
- Always select the correct application database in phpMyAdmin before importing.
