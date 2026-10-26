# Rooms by school

Each room belongs to one school. A student’s programme determines their school; the free-text school name on their student record is not used for allocation.

- Add or edit a room in Rooms and choose its School. The directory can be filtered by school, and the seat map shows the school code.
- For imports, use the new CSV template containing School Code. Older CSV/XLSX files work when you select a default school on the upload page. An explicit per-row code overrides that default. Unknown or missing schools fail validation; ownership is never guessed from room names.
- Generation maintains separate seat pools for each school, including when a common paper contains multiple schools. A shortage remains unallocated even if another school has spare seats. The generation page reports shortages by school.
- Manual correction choices depend on the selected student’s school. The server independently checks moves and unallocated assignments. Publication rejects any school mismatch.
- Rooms without a school cannot receive students. A school with inactive status cannot supply examination rooms.
- Published or superseded seating history prevents a room changing schools. Initial school assignment to a legacy room is allowed only when all its published students belong to that school. Editing room identity or ownership preserves the seat map when its geometry and disabled seats are unchanged.

## Installation and upgrade

Fresh installations use database/schema.sql and database/seed.sql, or database/install.php. The rooms table includes a school foreign key and an index on school/status. The baseline seed does not create rooms or overwrite operational ownership.

For an existing database, back up and apply the additive migration:

```powershell
C:\xampp\php\php.exe database/upgrade-room-schools.php
```

The command saves the rooms table and its previous definition under storage/backups before adding the nullable ownership column. It is safe to repeat. Nullable ownership accommodates legacy rooms; the application requires a school for new room records and excludes unassigned legacy rooms from allocation. Existing seat maps, published plans and attendance are preserved.

The 20 imported DEMO-RM-01 through DEMO-RM-20 rooms in this workspace have been explicitly assigned to ICT at the user’s request. The command tools/assign-demo-room-schools.php --apply performs only this specific mapping, checks published history, saves a backup and records an audit event. Other legacy rooms need an explicit choice in the room form.

The multi-school sample storage/demo-data/large-multi-branch/gbu_rooms_proposed_demo.csv includes explicit School Code values. The hosted room seed builder emits school references for these sample rooms; use that geometry seed for sample installations, not to rebuild rooms already used for examinations.

## Verification

```powershell
C:\xampp\php\php.exe tests/SchoolRoomSeatingTest.php
```

This uses and removes an isolated test database. It covers repeatable upgrades, a common paper shared by two schools, school-specific shortages, unassigned rooms, form handlers, rendered views, initial legacy ownership, published-history protection, publication checks and import school validation.
