# Deploy Auto-Exam on InfinityFree

Use the upload ZIP for the website and extract the setup ZIP on your computer. The setup ZIP contains the SQL import and your temporary administrator password. Keep it private.

## Set up a new database

1. Create a MySQL database in the InfinityFree Control Panel and note its hostname, name, username, and password.
2. Open phpMyAdmin and select the new, empty database.
3. Import `infinityfree_database_import.sql` from the setup ZIP. It creates the schema, seeds the academic master data, and creates your first administrator. Use an empty database for this fresh install.

## Upload the website

1. Open the domain's `htdocs` directory in InfinityFree File Manager. If the directory contains the default `index2.html` placeholder, remove that placeholder.
2. Use **Upload and unzip** with `Auto-Exam-InfinityFree-Upload.zip`. The ZIP root contains the files that go directly into `htdocs`.
3. Confirm that `.env`, `.htaccess`, `public/index.php`, and `public/.htaccess` are present. If the file manager skips any dotfiles or empty folders, extract the ZIP locally and upload the contents with FileZilla, including the three dotfiles and the `storage` subdirectories.
4. Edit `htdocs/.env`. Set `APP_URL` to your final HTTPS URL without a trailing slash. Set `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, and `DB_PASSWORD` to the values from your hosting account. Keep `APP_ENV=production` and `APP_DEBUG=false`.

The setup ZIP, SQL import, and administrator credentials stay on your computer.

## Verify the site

1. Visit `/health` and check that the database reports `connected`.
2. Visit `/login` and sign in with `ADMIN-CREDENTIALS.txt` from the setup ZIP.
3. Under **Users & Roles**, give the administrator a unique password of at least 12 characters.
4. Open the dashboard and Faculty Panel, then try a small CSV import or an XLSX export.

For an existing deployment, back up the database and use the relevant migrations. Preserve the live `.env` and `storage` while updating the application files.

[InfinityFree ZIP upload guidance](https://forum.infinityfree.com/t/unzip-files-in-the-new-file-manager/116215/2) · [File size limits](https://forum.infinityfree.com/t/file-size-and-upload-limits/49308)
