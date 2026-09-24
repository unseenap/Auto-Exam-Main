<div align="center">
  <img src="public/assets/images/gbu-full-logo.png" alt="Gautam Buddha University" width="360">

  # Automated Examination Operations Platform

  **A role-governed university platform for curriculum management, automatic date-sheet generation, room-aware seating, attendance, invigilation, replacements, audit and reporting.**

  `PHP 8.2+` · `MariaDB / MySQL` · `Responsive & Accessible UI` · `CSV/XLSX Imports` · `Deterministic Scheduling` · `Print-ready Reports`
</div>

---

## About the application

The **GBU Examination Operations Platform** centralises the operational work required to conduct university examinations. It connects academic records, subject curricula, examination schedules, physical room layouts, student seating, attendance and faculty invigilation in one controlled workflow.

The system is designed for Gautam Buddha University and follows its school, programme and roll-number conventions. It replaces disconnected spreadsheets with validated imports, deterministic allocation, role-based access and an auditable record of operational changes.

### Core objectives

- Maintain reliable school, programme, subject, student, faculty and room master data.
- Build examination cycles, calendars, shifts and programme-wise date sheets.
- Model every physical seat and prevent disabled seats from being allocated.
- Generate reproducible room-wise seating plans with capacity exception reporting.
- Prepare attendance sheets, invigilation duties and replacement records.
- Produce university-ready print and CSV reports with a complete audit trail.

## Contents

- [System capabilities](#system-capabilities)
- [Automatic date-sheet scheduling](#automatic-date-sheet-scheduling)
- [Operational workflow](#operational-workflow)
- [Data-flow diagrams](#data-flow-diagrams)
- [Architecture](#architecture)
- [Roles and access](#roles-and-access)
- [Data conventions](#data-conventions)
- [Database design](#database-design)
- [Local installation](#local-installation)
- [InfinityFree deployment](#infinityfree-deployment)
- [Demo data](#demo-data)
- [Testing](#testing)
- [Security](#security)

## System capabilities

| Module | Implemented capabilities |
|---|---|
| Dashboard | Operational statistics, quick actions and role-aware navigation |
| Academic masters | Schools, departments, programmes, duration in semesters, admission-session batches and programme codes |
| Course structure | Course name, code, credits, UG/PG level, academic year, semester, mid/end-semester duration, category and scheduling priority by programme |
| Students | Individual records, large CSV/XLSX import, validation preview and programme detection |
| Faculty | Faculty master, bulk import, school association and availability |
| Rooms | Bulk room import, row/column geometry, visual layout, priority and disabled seats |
| Examination cycles | Academic session, required student-batch selection, examination type, calendar dates, shifts and lifecycle status |
| Date sheets | Manual/import scheduling, school-wise automatic generation, branch and subject selection, holidays, flexible gaps, priorities, live validation, locking, moving, regeneration, approval, publication and CSV export |
| Seating | Versioned generation, room capacity use, seat allocation and unallocated-student reporting |
| Attendance | Room-wise attendance sheets, marking and correction support |
| Invigilation | Faculty duty allocation, session conflict control and workload tracking |
| Replacements | Replacement requests, approval status and replacement history |
| Reports | Seating, attendance, date-sheet and operational CSV/print outputs |
| Governance | Eight application roles, CSRF protection, session control and audit logs |

## Automatic date-sheet scheduling

The automatic scheduler builds one independent date-sheet line for every selected **programme/branch and semester**. Papers from different branches may use the same date and shift when their own cohort rules allow it; they are not incorrectly combined into a single branch row.

### Scheduling workflow

1. Create an examination cycle with its date range, examination type, paper duration and shifts.
2. Mark Sundays, university holidays and any unavailable dates in **Calendar & holidays**.
3. Open **Automatic scheduling** and select one school.
4. Select only the programmes belonging to that school, followed by the required semesters.
5. Review the written subjects loaded for each selected branch. Eligible theory papers start selected and may be included or excluded individually.
6. Set the preferred rest gap, daily paper limit, priority handling and non-consecutive-day preference.
7. Review live academic, calendar and feasibility checks, then save validation.
8. Generate the draft, lock important placements, move a paper when needed or regenerate unlocked papers.
9. Approve the reviewed run and publish the final date sheet.

### Scheduling rules

- Course priority uses values from 1 to 100; lower numbers are placed earlier when priority scheduling is enabled.
- Lab and practical subjects are automatically excluded from written date sheets.
- A requested gap is treated as a preference when the available examination window cannot accommodate it. The engine still attempts to schedule every valid selected paper.
- Sundays and configured holidays are unavailable unless explicitly enabled as examination days.
- Existing papers are preserved and shown during validation so a new branch can be added without silently replacing another branch's schedule.
- Locked papers keep their placement during regeneration; unlocked papers may be recalculated.
- Student records are not required to build a draft date sheet. Eligibility counts remain zero until matching active students exist.
- Reopening Automatic Scheduling for an existing draft reconstructs the scope from the current database records. Its school, scheduled branches, semesters and written papers are selected automatically, including papers preserved from earlier runs.

### Draft lifecycle

```mermaid
flowchart LR
    S[Select school, branches,<br/>semesters and subjects] --> V[Live validation]
    V -->|No blockers| G[Generate draft]
    G --> R[Review, lock or move]
    R -->|Changes needed| N[Regenerate unlocked papers]
    N --> R
    R --> A[Approve run]
    A --> P[Publish date sheet]
    P --> D[Seating and downstream operations]
```

## Operational workflow

```mermaid
flowchart LR
    A[Configure schools, programmes and durations] --> B[Create admission batches]
    B --> C[Add curriculum by batch, semester and section]
    C --> D[Import students and faculty]
    D --> E[Create rooms and visual seat layouts]
    E --> F[Select batches and create examination cycle]
    F --> G[Generate, review and publish school-wise date sheet]
    G --> H[Generate and review room-wise seating plan]
    H --> I[Publish room and attendance sheets]
    I --> J[Allocate invigilation duties]
    J --> K[Record attendance and replacements]
    K --> L[Export reports and review audit history]
```

## Data-flow diagrams

### DFD Level 0 — system context

```mermaid
flowchart LR
    AC[Academic Coordinator]
    EC[Examination Cell]
    SC[Seating Coordinator]
    IC[Invigilation Coordinator]
    FV[Faculty / Viewer / Auditor]

    SYS((GBU Examination<br/>Operations Platform))
    DB[(Examination Database)]

    AC -->|Masters, curriculum and student data| SYS
    EC -->|Cycles, shifts and date sheets| SYS
    SC -->|Rooms, disabled seats and generation rules| SYS
    IC -->|Faculty availability, duties and replacements| SYS
    FV -->|Authorized views and attendance input| SYS

    SYS -->|Validation results, schedules and reports| AC
    SYS -->|Published date sheets and control reports| EC
    SYS -->|Room-wise seating and capacity exceptions| SC
    SYS -->|Duty rosters and replacement status| IC
    SYS -->|Assigned information and read-only reports| FV

    SYS <-->|Validated operational records| DB
```

### DFD Level 1 — internal examination flow

```mermaid
flowchart TB
    U1[Academic users]
    U2[Examination users]
    U3[Seating users]
    U4[Invigilation users]

    P1((1.0 Academic<br/>data management))
    P2((2.0 Examination<br/>scheduling))
    P3((3.0 Room and<br/>seating allocation))
    P4((4.0 Attendance and<br/>invigilation))
    P5((5.0 Reporting<br/>and audit))

    D1[(D1 Academic masters)]
    D2[(D2 Students and faculty)]
    D3[(D3 Cycles and examinations)]
    D4[(D4 Rooms and seats)]
    D5[(D5 Seating and attendance)]
    D6[(D6 Audit records)]

    U1 -->|Schools, programmes, courses, students| P1
    P1 --> D1
    P1 --> D2

    U2 -->|Session, dates, shifts, subjects| P2
    D1 --> P2
    P2 --> D3

    U3 -->|Room selection and generation request| P3
    D2 --> P3
    D3 --> P3
    D4 --> P3
    P3 --> D5
    P3 -->|Plan and exceptions| U3

    U4 -->|Availability, attendance, replacements| P4
    D2 --> P4
    D3 --> P4
    D5 --> P4
    P4 --> D5

    D1 --> P5
    D2 --> P5
    D3 --> P5
    D4 --> P5
    D5 --> P5
    P5 -->|Date sheets, seating, attendance and duties| U2
    P1 --> D6
    P2 --> D6
    P3 --> D6
    P4 --> D6
    P5 --> D6
```

## Architecture

```mermaid
flowchart LR
    B[Browser]
    A[Apache / OpenResty]
    F[public/index.php<br/>Front controller]
    APP[Application routing<br/>Authentication and policies]
    S[Domain services<br/>Import · Exams · Rooms · Seating]
    V[PHP views<br/>Responsive university UI]
    M[(MariaDB / MySQL)]
    FS[(Temporary uploads<br/>Exports and logs)]

    B <-->|HTTPS requests and responses| A
    A --> F
    F --> APP
    APP --> S
    APP --> V
    S <-->|PDO transactions| M
    S <--> FS
    V --> B
```

### Project structure

```text
Auto-Exam-Main/
├── app/
│   ├── Academic/       Roll-number and student-domain logic
│   ├── Auth/           Authentication and role policies
│   ├── Exams/          Examination scheduling services
│   ├── Foundation/     Application, database, session and environment
│   ├── Import/         CSV/XLSX staging, validation and commit services
│   ├── Rooms/          Physical seat generation
│   ├── Seating/        Seating allocation engine
│   └── View/           View rendering
├── bootstrap/          Application bootstrap and autoloading
├── config/             Application and database configuration
├── database/           Canonical schema, seed, installer and backup utility
├── deployment/
│   └── infinityfree/   Hosting package builder and deployment guide
├── docs/               Scheduling design and date-sheet review notes
├── public/             Web entry point, CSS, JavaScript, icons and branding
├── resources/views/    Accessible server-rendered application screens
├── storage/            Imports, exports, logs and demonstration datasets
├── tests/              Unit, integration and end-to-end verification
├── tools/              Repeatable dataset and deployment builders
├── OPERATOR_GUIDE.md   Day-to-day operator instructions
├── DEPLOYMENT.md       Deployment overview
└── README.md           Project overview and setup guide
```

## Roles and access

| Role | Main responsibility |
|---|---|
| System Administrator | Full system, users, roles, masters, operations and audit control |
| Controller of Examinations | Examination cycles, date sheets, seating publication, attendance and reports |
| Academic Coordinator | Academic masters, curriculum and student records |
| Seating Coordinator | Rooms, disabled seats, layouts, seating generation and reports |
| Invigilation Coordinator | Faculty, availability, duties, replacements and attendance operations |
| Faculty / Invigilator | Restricted authenticated faculty dashboard |
| Audit and Compliance Viewer | Read-only reports and audit history |
| Authorized Read-only Viewer | Dashboard and published operational reports |

Routes are checked against explicit permissions including `academic.manage`, `students.manage`, `rooms.manage`, `exams.manage`, `seating.manage`, `attendance.manage`, `invigilation.manage`, `reports.view`, `audit.view` and `users.manage`.

## Data conventions

### Student identifiers

The standard roll number contains nine characters:

```text
235UCS001
└┬┘└┬┘└┬┘
 │  │  └── Student sequence
 │  └───── Programme/branch code (UCS = B.Tech CSE)
 └──────── Admission identifier; first two digits represent admission year
```

Enrollment number is a separate ten-digit identifier, for example `2300100266`. Academic sessions use consecutive `YYYY-YYYY` format, such as `2026-2027`.

Student imports accept:

```text
Enrollment/Roll Number, Enrollment Number, Academic Session, Full Name,
Branch, Mobile Number, Address, Department, School,
Current Year of Study, Current Semester, Section
```

### Curriculum

Courses are associated with an exact programme batch, semester and section using a subject code, name and category. Use section `ALL` for subjects taken by the complete batch, or values such as `A` and `B` for section-specific papers. Automatic scheduling reads only the curriculum for batches assigned to the examination cycle and creates separate cohort rows for each batch/semester/section. The included B.Tech CSE dataset provides **87 unique courses and 94 curriculum mappings** across eight semesters.

### Rooms and disabled seats

Each room defines rows, columns and either `row_major` or `column_major` allocation order. Seats use labels such as `R01-C01`. Disabled coordinates remain visible in the room layout but cannot receive a student allocation.

### Imports

- Supported formats: CSV and first-worksheet XLSX.
- Maximum application-level size: 10 MB.
- Imports are staged and validated before commit.
- Invalid rows remain visible with row-specific messages.
- InfinityFree deployments can process the PHP temporary upload when persistent file writes are unavailable.

## Database design

The current schema contains **35 tables** grouped into these domains:

| Domain | Principal tables |
|---|---|
| Identity and governance | `roles`, `users`, `audit_logs`, `system_settings` |
| Academic masters | `schools`, `departments`, `programmes`, `batches`, `courses`, `programme_courses` |
| People | `students`, `faculty`, `faculty_availability` |
| Physical infrastructure | `rooms`, `room_seats` |
| Examination planning | `exam_cycles`, `exam_cycle_batches`, `exam_shifts`, `exam_calendar_dates`, `examinations`, `examination_cohorts`, `exam_eligibility`, `scheduling_rules`, `scheduling_runs`, `scheduling_run_items`, `scheduling_conflicts` |
| Seating | `seating_allocations`, `seating_assignments`, `seating_unallocated` |
| Operations | `invigilation_allocations`, `attendance`, `replacement_requests` |
| Imports | `import_batches`, `import_rows`, `import_errors` |

The canonical sources are [`database/schema.sql`](database/schema.sql) and [`database/seed.sql`](database/seed.sql). These are the only SQL files required for a clean installation: import the schema first and the seed second. The schema already contains the complete automatic-scheduling structure, including priorities, rules, runs, run items and conflicts.

## Local installation

### Requirements

- PHP 8.2 or newer with PDO MySQL and ZIP support
- MariaDB 10.4+ or MySQL 8+
- Apache with `mod_rewrite`
- XAMPP is recommended for Windows development

### Setup on XAMPP

1. Place the project at `C:\xampp\htdocs\Auto-Exam-Main`.
2. Start Apache and MySQL from XAMPP.
3. Copy `.env.example` to `.env` and review the database values.
4. Install the schema, seed data and administrator account:

```powershell
C:\xampp\php\php.exe database\install.php admin "a-strong-password-of-at-least-12-characters"
```

5. For a fresh manual installation, import the two canonical SQL files in this order:

```powershell
C:\xampp\mysql\bin\mysql.exe -u root -e "source C:/xampp/htdocs/Auto-Exam-Main/database/schema.sql"
C:\xampp\mysql\bin\mysql.exe -u root -D gbu_exam_operations -e "source C:/xampp/htdocs/Auto-Exam-Main/database/seed.sql"
```

6. Open [http://localhost/Auto-Exam-Main/public/](http://localhost/Auto-Exam-Main/public/). The login route is [http://localhost/Auto-Exam-Main/public/login](http://localhost/Auto-Exam-Main/public/login).

### Environment configuration

```env
APP_NAME="GBU Examination Operations"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost/Auto-Exam-Main/public
APP_TIMEZONE=Asia/Kolkata
SESSION_TIMEOUT_MINUTES=30
SESSION_SAVE_PATH=

DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=gbu_exam_operations
DB_USERNAME=root
DB_PASSWORD=
```

Never commit the live `.env` file or database credentials.

## InfinityFree deployment

Build the hosting package:

```powershell
.\deployment\infinityfree\build-package.ps1
```

The generated archive separates:

- `UPLOAD_TO_HTDOCS/` — application files placed directly inside the hosted `/htdocs` directory.
- `SETUP/` — database import, upgrades and optional demonstration seeds; this directory is not uploaded publicly.

For a clean hosted installation, select the provider-assigned database in phpMyAdmin and import `infinityfree_database_import.sql`. The hosted `.env` must use the exact InfinityFree MySQL hostname, database name, username and password; the database host is not `localhost`.

## Demo data

CSV demonstration datasets remain available under `storage/demo-data`, including large multi-branch students, faculty, course structures and room-layout examples. Database installation uses only the canonical `database/schema.sql` and `database/seed.sql` files.

Use the application import screens for operational data:

- **Students** — identifiers, session, programme, school, semester, section and contact information.
- **Faculty** — faculty identity, school association and availability data.
- **Courses** — programme/branch, subject code and name, credits, UG/PG level, course year, semester, category, examination duration and priority.
- **Rooms** — room geometry, allocation order, priority and optional disabled seat coordinates.

## Testing

Run parser and role-policy tests:

```powershell
C:\xampp\php\php.exe -d zend.assertions=1 -d assert.exception=1 tests\RollNumberParserTest.php
C:\xampp\php\php.exe -d zend.assertions=1 -d assert.exception=1 tests\RolePolicyTest.php
```

Run database-backed verification while MariaDB is available:

```powershell
C:\xampp\php\php.exe -d zend.assertions=1 -d assert.exception=1 tests\SeedTest.php
C:\xampp\php\php.exe -d zend.assertions=1 -d assert.exception=1 tests\CourseImportTest.php
C:\xampp\php\php.exe -d zend.assertions=1 -d assert.exception=1 tests\RoomImportTest.php
C:\xampp\php\php.exe -d zend.assertions=1 -d assert.exception=1 tests\BTechCseCurriculumDatasetTest.php
C:\xampp\php\php.exe -d zend.assertions=1 -d assert.exception=1 tests\EndToEndTest.php
C:\xampp\php\php.exe -d zend.assertions=1 -d assert.exception=1 tests\AutomaticSchedulingTest.php
```

Database-backed tests create isolated temporary databases and remove them after completion.

## Security

- Passwords are stored using PHP password hashing and verified with `password_verify`.
- Every protected route requires authentication and an authorized role permission.
- State-changing forms use CSRF tokens.
- Sessions use secure, HTTP-only, SameSite cookies where HTTPS is available.
- Login attempts receive a short session-based throttle.
- Operational changes are retained in the audit log.
- Output is HTML-escaped through shared view helpers.
- Database access uses PDO prepared statements and transactions.

Before production use, change temporary credentials, keep `APP_DEBUG=false`, use HTTPS, protect the hosting account and retain encrypted database backups outside the public web root.

## Reporting and printing

Print actions use the browser print dialog; choose **Save as PDF** for official PDF output. CSV exports are UTF-8 compatible and can be opened in spreadsheet applications. Always review the university header, examination cycle, date, shift, room and publication status before distribution.

---

<div align="center">
  <strong>Gautam Buddha University — Examination Operations</strong><br>
  Greater Noida, Uttar Pradesh, India
</div>
