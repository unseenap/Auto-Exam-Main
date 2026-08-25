param([string]$OutputDirectory = "$PSScriptRoot\..\storage\backups")
$resolved = [System.IO.Path]::GetFullPath($OutputDirectory)
$workspace = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not $resolved.StartsWith($workspace, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Backup target must remain inside the project workspace.' }
New-Item -ItemType Directory -Force -Path $resolved | Out-Null
$file = Join-Path $resolved ("gbu_exam_operations_{0}.sql" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
& 'C:\xampp\mysql\bin\mysqldump.exe' -u root --single-transaction --routines gbu_exam_operations --result-file=$file
if ($LASTEXITCODE -ne 0) { throw 'Database backup failed.' }
Write-Output $file

