. "$PSScriptRoot\local-common.ps1"
$user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument ('-NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -File "' + (Join-Path $PSScriptRoot 'watch-local.ps1') + '"') -WorkingDirectory $projectRoot
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit ([TimeSpan]::Zero) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName $localTaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Start local PhytoPulse after sign-in; check database, web, API and worker every minute. Uses existing collection and model limits.' -Force | Out-Null
Start-ScheduledTask -TaskName $localTaskName
Write-Host 'PhytoPulse automatic start installed for the current Windows user.'
