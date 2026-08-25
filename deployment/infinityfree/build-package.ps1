$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$packageRoot = Join-Path $PSScriptRoot 'package'
$uploadRoot = Join-Path $packageRoot 'UPLOAD_TO_HTDOCS'
$setupRoot = Join-Path $packageRoot 'SETUP'
$zipPath = Join-Path $PSScriptRoot 'Auto-Exam-InfinityFree-Ready.zip'

if (Test-Path -LiteralPath $packageRoot) {
    $resolvedPackage = (Resolve-Path -LiteralPath $packageRoot).Path
    if (-not $resolvedPackage.StartsWith($PSScriptRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clear unexpected path: $resolvedPackage"
    }
    Remove-Item -LiteralPath $resolvedPackage -Recurse -Force
}

New-Item -ItemType Directory -Path $uploadRoot, $setupRoot | Out-Null

foreach ($directory in @('app', 'bootstrap', 'config', 'public', 'resources')) {
    Copy-Item -LiteralPath (Join-Path $projectRoot $directory) -Destination $uploadRoot -Recurse
}

foreach ($directory in @('cache', 'exports', 'imports', 'logs', 'sessions')) {
    $target = Join-Path $uploadRoot "storage\$directory"
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target '.gitkeep') -Value '' -NoNewline
}

Copy-Item -LiteralPath (Join-Path $projectRoot 'storage\demo-data') -Destination (Join-Path $uploadRoot 'storage') -Recurse
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'templates\root.htaccess') -Destination (Join-Path $uploadRoot '.htaccess')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'templates\public.htaccess') -Destination (Join-Path $uploadRoot 'public\.htaccess') -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'templates\.env.infinityfree') -Destination (Join-Path $uploadRoot '.env')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'HOSTING-GUIDE.md') -Destination (Join-Path $packageRoot 'HOSTING-GUIDE.md')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'infinityfree_upgrade_reserved_column.sql') -Destination (Join-Path $setupRoot 'infinityfree_upgrade_reserved_column.sql')
Copy-Item -LiteralPath (Join-Path $projectRoot 'database\infinityfree_demo_data_seed.sql') -Destination (Join-Path $setupRoot 'infinityfree_demo_data_seed.sql')
Copy-Item -LiteralPath (Join-Path $projectRoot 'database\infinityfree_room_seed.sql') -Destination (Join-Path $setupRoot 'infinityfree_room_seed.sql')

$schema = Get-Content -LiteralPath (Join-Path $projectRoot 'database\schema.sql')
if ($schema[0] -notmatch '^CREATE DATABASE') {
    throw 'database/schema.sql no longer starts with the expected CREATE DATABASE block; review the packaging script.'
}
$portableSchema = $schema | Select-Object -Skip 3
$seed = Get-Content -LiteralPath (Join-Path $projectRoot 'database\seed.sql')
$tableNames = foreach ($line in $portableSchema) {
    if ($line -match '^CREATE TABLE\s+`?([A-Za-z0-9_]+)`?') {
        $Matches[1]
    }
}
$dropStatements = ($tableNames | ForEach-Object { "DROP TABLE IF EXISTS ``$_``;" }) -join "`r`n"
$adminSql = @'

-- Initial hosted administrator. Change this password immediately after first login.
INSERT INTO users (role_id, username, name, email, password_hash, status)
SELECT id, 'admin', 'Examination Cell Administrator', NULL,
       '$2y$10$oxS1CkSCUQDzreemdTsYPerph4BrBNZ7Icp6ogQkBUU1U.a8DIVCa', 'active'
FROM roles WHERE code = 'admin'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  password_hash = VALUES(password_hash),
  status = 'active';
'@

$sqlHeader = @'
-- GBU Examination Operations: InfinityFree clean-install database
-- Select the provider-assigned database in phpMyAdmin before importing.
-- Generated from database/schema.sql and database/seed.sql.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

'@
$sqlFooter = "`r`nSET FOREIGN_KEY_CHECKS = 1;`r`n"
$sqlContent = $sqlHeader + $dropStatements + "`r`n`r`n" + ($portableSchema -join "`r`n") + "`r`n`r`n" + ($seed -join "`r`n") + $adminSql + $sqlFooter
Set-Content -LiteralPath (Join-Path $setupRoot 'infinityfree_database_import.sql') -Value $sqlContent -Encoding utf8

$credentials = @'
GBU Examination Operations — temporary administrator

Login URL: https://YOUR-DOMAIN/login
Username: admin
Temporary password: oqiqoz#L2Qo3NbUbgA

Change this password immediately after the first login, then delete this file.
DO NOT UPLOAD THIS FILE OR THE SETUP FOLDER TO HTDOCS.
'@
Set-Content -LiteralPath (Join-Path $setupRoot 'ADMIN-CREDENTIALS.txt') -Value $credentials -Encoding utf8

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}
Compress-Archive -Path (Join-Path $packageRoot '*') -DestinationPath $zipPath -CompressionLevel Optimal

$hash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
Write-Output "Package folder: $packageRoot"
Write-Output "ZIP file: $zipPath"
Write-Output "SHA256: $hash"
