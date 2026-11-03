$ErrorActionPreference = 'Stop'
& "$PSScriptRoot\start-local.ps1"
$task = Get-ScheduledTask -TaskName 'PhytoPulse-Local' -ErrorAction SilentlyContinue
if ($task) { Start-ScheduledTask -TaskName $task.TaskName }
Start-Process 'http://localhost:3000'
