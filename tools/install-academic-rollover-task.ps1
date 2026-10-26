$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
$phpExecutable='C:\xampp\php\php.exe'
if(-not (Test-Path -LiteralPath $phpExecutable)){throw 'Set the PHP executable path before installing the task.'}
$scriptPath=Join-Path $projectRoot 'tools\academic-rollover.php'
$action=New-ScheduledTaskAction -Execute $phpExecutable -Argument ('"'+$scriptPath+'"') -WorkingDirectory $projectRoot
$trigger=New-ScheduledTaskTrigger -Daily -At '00:15'
$settings=New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
$principal=New-ScheduledTaskPrincipal -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
$taskName='AutoExamAcademicRollover'
$existing=Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if($existing -and (($existing.Actions.Execute -ne $phpExecutable) -or ($existing.Actions.Arguments -ne ('"'+$scriptPath+'"')))){throw 'A different task uses this name. It was left unchanged.'}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Advance Auto Exam academic placements and record history daily. Also catches up on the first authenticated app request.' -Force | Select-Object TaskName,State
