# Security baseline

- All database writes use prepared PDO statements.
- Passwords use PHP `password_hash` and `password_verify`.
- State-changing browser requests require CSRF tokens.
- Sessions use HTTP-only, SameSite=Lax cookies and a configurable inactivity timeout.
- A centralized authorization boundary rejects every authenticated non-administrator POST request; sensitive handlers retain defense-in-depth checks.
- Uploads are restricted to CSV/XLSX, capped at 10 MB, stored outside `public/`, validated, staged, and committed separately.
- Official seating publication is transactional and requires validation.
- Manual seat corrections are restricted to draft versions, require a reason, and create audit entries.
- Attendance, seating, faculty, room, student, import, and replacement operations retain database history where implemented.
- Production deployments must set `APP_DEBUG=false`, use HTTPS, use a dedicated database user, and change the initial administrator password.

## Production checklist

1. Restrict `storage/` and database backups to the web-server account.
2. Enable secure cookies under HTTPS.
3. Remove database root credentials from `.env` and use a least-privilege account.
4. Configure daily database backups and test restoration.
5. Review Apache access/error logs and application audit logs.
6. Keep PHP, Apache, MariaDB, and export libraries patched.
