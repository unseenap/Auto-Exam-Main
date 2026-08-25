GBU LARGE MULTI-BRANCH DEMO DATA

Import order:
1. students_large_multi_branch.csv (340 students; 17 active programmes; sections A and B)
2. faculty_large_all_schools.csv (64 faculty; all 8 active schools)
3. date_sheet_cycle_1_large.csv (34 papers; cycle 1 valid dates and shifts)
4. gbu_rooms_proposed_demo.csv (20 proposed room layouts with disabled-seat examples)

ROOM DATA NOTICE
- The supplied project document describes room and seating requirements but does not provide GBU's official room inventory.
- Room codes, dimensions, capacities, floors, and disabled seats in this file are fictional test data modelled on GBU school/building names.
- Verify and replace these values with the university's official room register before production use.
- Upload this file from Rooms > Import Rooms. Disabled seats use coordinates such as R01-C01.

students_validation_errors_demo.csv is intentionally invalid and should be used only to test validation messages.

All records are fictional. Import valid files only once because identifiers are unique and duplicate imports will be rejected.

IDENTIFIER FORMAT
- Roll number: 235 + three-letter programme code + three-digit sequence, for example 235UCS001.
- The first two digits (23) represent the admission year 2023. The third digit is 5, following the supplied university example.
- Enrollment number: a separate unique 10-digit numeric value beginning with 23, for example 2300100001.

PROGRAMME CODE CLARIFICATION
- UCS: B.Tech Computer Science and Engineering.
- ICS: Integrated B.Tech Computer Science and Engineering.
