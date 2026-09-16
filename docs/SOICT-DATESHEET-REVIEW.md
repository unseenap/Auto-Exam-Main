# SOICT reference review

Reference: Endsem information technologies.pdf, six scanned pages, May 2026.

The reference has two shifts (09:30-12:30 and 14:00-17:00), programme/batch/semester rows, common papers across programmes, and separate PhD, CSE, IT and ECE sections. The CSE/IT/ECE calendar spans 13-28 May; the PhD section ends 23 May. Blank cells do not automatically mean university holidays. ECE is explicitly in SOICT in this reference.

## Corrections made

- Manual scheduling and date-sheet import now reuse one draft examination for an identical subject/date/shift/category across different programmes, attaching separate cohorts. This supports MA112/EC104-style common papers.
- Manual/import scheduling rejects disabled dates and shifts outside the cycle.
- Seating rejects a student registered for two examinations in the same session with a readable error before writing assignments.
- Readiness compares available slots per cohort, allowing different programmes to examine concurrently. It counts calendar-day gaps consistently with the generator.
- Seed correction places the existing ECE programme codes under ICT, following the supplied reference.
- Automatic generation groups common subjects into one session, checks every affected cohort, honours the priority toggle, preserves existing papers, and checks the longest configured course duration against the shift.
- Zero-gap rules allow distinct shifts on the same day up to the daily limit; consecutive-day avoidance imposes at least one clear day.
- Shared-paper moves validate all attached cohorts. Approved or published drafts cannot be edited through the review service.
- Regeneration defers deletion until generation's transaction; an exception rolls back deletion. Shared papers with cohorts outside the regeneration scope are protected.
- Seating interleaves papers rather than programme names, respects each room's usable capacity and blocked seats, and refuses publication with unallocated students or over-capacity/inactive rooms.
- Date-sheet imports accept optional Batch Label and pipe-separated Roll Numbers. Batches must already exist under the programme. Repeat/special and elective papers require explicit registrations; repeated students may be in a later current semester.
- Automatic elective/back-paper eligibility is pending, not assumed. Explicit registration import confirms selected students and excludes the remaining pending students in that cohort. Seating waits until pending registrations have been resolved.

## Recommended workflow

For an already approved university date sheet, use date-sheet CSV/XLSX import to preserve the official dates and shifts, then generate seating per date and shift. Enter one import row per programme/semester/subject; use the same subject code/date/shift for a shared paper. A scanned PDF is a reference, not a supported direct import format.

1. Create the examination cycle and the official 09:30-12:30 / 14:00-17:00 shifts; enter university holidays explicitly.
2. Open the cycle's date-sheet import page and download its CSV template.
3. Enter one row per programme/semester/paper using the official date and shift. For a combined UG/PG row, supply separate rows for the actual programme/semester combinations with the same course code and session. Do not invent programme codes.
4. Use Batch Label where needed, and Roll Numbers separated by `|` for repeat/elective registrations. The label must exactly match the existing batch master. Regular papers with no roll list use the active cohort.
5. Validate the upload and review its registration scope before committing. Resolve any pending registrations before seating.
6. Choose a date/shift, select rooms, generate seating, review unallocated students and physical placement, then publish only a complete allocation.

Verify actual subject registrations before seating, especially repeats, electives and combined UG/PG cohorts. The date sheet alone does not identify which students are registered for each paper or the available rooms. CSV/XLSX remains the supported import route; the scanned PDF is not an automatically verified data source.

## Remaining compatibility gaps

The automatic generator remains greedy, not an optimiser that guarantees a solution whenever one exists. It does not reproduce the university matrix automatically or select department-specific morning/afternoon preferences. Use approved-date-sheet import to preserve those placements. Automatic scope is still programme/current-semester based; batch-specific scope is supported through import, not the automatic scope form. Integrated eighth-semester and PG second-semester combined rows cannot be inferred safely from programme names. The print view does not yet match all six department layouts. Paper round-robin seating does not guarantee same-paper separation between adjacent physical seats. These are remaining implementation limitations, not features inferred from the PDF.

These limitations mean the full workflow should not be described as fully compatible or production-verified for this reference yet.

## Verification and local-server blocker (13 September 2026)

All nine test scripts passed against an isolated MariaDB 10.4.32 instance, using fresh disposable databases and the repository schema/seed. Additional tests cover common subjects across two branches, preservation, zero-gap multi-shift scheduling, duration rejection, explicit repeats, batch selection, capacity and incomplete seating. PHP syntax checks passed across app, views and tests.

The user's normal XAMPP server fails startup with `Fatal error: Can't open and lock privilege tables: Incorrect file format 'db'`. Its system tables were not repaired, replaced or deleted. Testing used a separate temporary instance on port 33317, not the application database. The latest changes have therefore not been verified against the user's existing application database or through the browser.

No new schema columns or migration SQL were introduced by these compatibility fixes. Do not reimport schema.sql into the existing database as a remedy for the XAMPP system-table error. Back up the existing database files before any separately authorised recovery work.
