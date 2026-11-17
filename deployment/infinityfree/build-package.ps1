param(
    [string] $Php = 'php',
    [string] $OutputDirectory = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if ($Php -eq 'php' -and -not (Get-Command $Php -ErrorAction SilentlyContinue)) {
    $Php = 'C:\xampp\php\php.exe'
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$outputRoot = (Resolve-Path -LiteralPath $OutputDirectory).Path
$buildRoot = Join-Path $outputRoot ('infinityfree-build-' + [guid]::NewGuid().ToString('N'))
$uploadRoot = Join-Path $buildRoot 'htdocs'
$setupRoot = Join-Path $buildRoot 'setup'
$uploadName = 'Auto-Exam-InfinityFree-Upload.zip'
$setupName = 'Auto-Exam-InfinityFree-Setup.zip'
$utf8 = [System.Text.UTF8Encoding]::new($false)

Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -ItemType Directory -Path $uploadRoot, $setupRoot | Out-Null

try {
    foreach ($directory in @('app', 'bootstrap', 'config', 'public', 'resources')) {
        Copy-Item -LiteralPath (Join-Path $projectRoot $directory) -Destination $uploadRoot -Recurse
    }

    foreach ($directory in @('cache', 'exports', 'imports', 'logs', 'sessions')) {
        $target = Join-Path $uploadRoot "storage\$directory"
        New-Item -ItemType Directory -Path $target -Force | Out-Null
    }

    $migrationRoot = Join-Path $uploadRoot 'database'
    New-Item -ItemType Directory -Path $migrationRoot | Out-Null
    foreach ($migration in @('faculty-portal.sql', 'attendance-ufm.sql')) {
        Copy-Item -LiteralPath (Join-Path $projectRoot "database\$migration") -Destination $migrationRoot
    }

    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'templates\root.htaccess') -Destination (Join-Path $uploadRoot '.htaccess')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'templates\public.htaccess') -Destination (Join-Path $uploadRoot 'public\.htaccess') -Force
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'templates\.env.infinityfree') -Destination (Join-Path $uploadRoot '.env')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'README.md') -Destination (Join-Path $setupRoot 'HOSTING-GUIDE.md')

    $schema = [System.IO.File]::ReadAllText((Join-Path $projectRoot 'database\schema.sql'))
    $databaseHeader = '\ACREATE DATABASE\s+[^;]+;\s*USE\s+[^;]+;\s*'
    $portableSchema = $schema -replace $databaseHeader, ''
    if ($portableSchema -eq $schema) {
        throw 'The schema database-selection header has changed. Review it before packaging.'
    }
    $attendance = [System.IO.File]::ReadAllText((Join-Path $migrationRoot 'attendance-ufm.sql'))
    $seed = [System.IO.File]::ReadAllText((Join-Path $projectRoot 'database\seed.sql'))

    $credentialJson = & $Php -r '$password = bin2hex(random_bytes(16)); echo json_encode([$password, password_hash($password, PASSWORD_BCRYPT)], JSON_THROW_ON_ERROR);'
    if ($LASTEXITCODE -ne 0) {
        throw 'PHP could not generate the temporary administrator credentials.'
    }
    $password, $passwordHash = $credentialJson | ConvertFrom-Json

    $adminSql = @"
INSERT INTO users (role_id, username, name, password_hash, status)
SELECT id, 'admin', 'Examination Cell Administrator', '$passwordHash', 'active'
FROM roles WHERE code = 'admin';
"@
    $sql = @(
        '-- Auto-Exam fresh install. Select the empty InfinityFree database before importing.',
        'SET NAMES utf8mb4;',
        $portableSchema.Trim(),
        $attendance.Trim(),
        $seed.Trim(),
        $adminSql
    ) -join "`n`n"
    [System.IO.File]::WriteAllText((Join-Path $setupRoot 'infinityfree_database_import.sql'), $sql, $utf8)

    $credentials = @"
Auto-Exam temporary administrator

Login path: /login
Username: admin
Temporary password: $password

Keep this file local. Change the password after the first sign-in.
"@
    [System.IO.File]::WriteAllText((Join-Path $setupRoot 'ADMIN-CREDENTIALS.txt'), $credentials, $utf8)

    Get-ChildItem -LiteralPath $uploadRoot -Recurse -File -Force | ForEach-Object {
        $limit = switch -Regex ($_.Name) {
            '^\.htaccess$' { 10000; break }
            '\.(html?|php|js|css)$' { 1000000; break }
            default { 10000000 }
        }
        if ($_.Length -gt $limit) {
            throw "File exceeds its InfinityFree size limit: $($_.FullName)"
        }
    }

    # Include dotfiles and empty runtime directories, with the htdocs contents at ZIP root.
    $uploadZip = Join-Path $buildRoot $uploadName
    $setupZip = Join-Path $buildRoot $setupName
    [System.IO.Compression.ZipFile]::CreateFromDirectory($uploadRoot, $uploadZip)
    [System.IO.Compression.ZipFile]::CreateFromDirectory($setupRoot, $setupZip)
    if ((Get-Item -LiteralPath $uploadZip).Length -gt 10000000) {
        throw 'The website ZIP exceeds the InfinityFree archive size limit.'
    }

    foreach ($name in @($uploadName, $setupName)) {
        $destination = Join-Path $outputRoot $name
        Move-Item -LiteralPath (Join-Path $buildRoot $name) -Destination $destination -Force
        Get-Item -LiteralPath $destination | Select-Object FullName, Length
    }
} finally {
    $resolvedBuildRoot = (Resolve-Path -LiteralPath $buildRoot).Path
    if ([System.IO.Path]::GetDirectoryName($resolvedBuildRoot) -eq $outputRoot) {
        Remove-Item -LiteralPath $resolvedBuildRoot -Recurse -Force
    }
}
