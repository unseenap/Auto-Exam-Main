GBU AUTOMATED EXAMINATION SYSTEM - DEMO CSV DATA

These records are fictional and are intended only for local application testing.

RECOMMENDED IMPORT ORDER
1. students_demo.csv
   Open: /public/students/import
   Contains 24 valid students across UCS semester 5, UCM semester 3, and UCD semester 3.

2. faculty_demo.csv
   Open: /public/faculty/import
   Contains 12 faculty members. Its school codes match the current active school master.

3. date_sheet_cycle_1_demo.csv
   Open cycle 1 (Mid sem), then choose Import workbook.
   Contains 12 papers on valid examination dates and uses the existing Morning Shift and Evening Shift names.

IMPORTANT
- Validate each upload and review its preview before committing it.
- Import each file only once. Importing it again will report duplicate roll numbers or employee IDs.
- The date-sheet sample targets cycle ID 1, whose dates currently run from 23 August 2026 to 20 September 2026.
- The three sample programme codes are UCS, UCM, and UCD.
- Email addresses use the reserved example.test domain and do not represent real people.

IDENTIFIER FORMAT
- Roll number: 235 + three-letter programme code + three-digit sequence, for example 235UCS001.
- Enrollment number: a different unique 10-digit number beginning with admission year 23.
