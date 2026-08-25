-- Run once on an existing installation that still has the row_number columns.
ALTER TABLE import_errors
  CHANGE COLUMN `row_number` source_row_number INT UNSIGNED NULL;

ALTER TABLE import_rows
  CHANGE COLUMN `row_number` source_row_number INT UNSIGNED NOT NULL;

