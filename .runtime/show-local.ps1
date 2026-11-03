. "$PSScriptRoot\local-common.ps1"
Set-Location -LiteralPath $projectRoot
foreach ($service in $localServices) {
    $owned = @(Get-LocalProcess $service)
    $state = if ($owned.Count -eq 1) { 'running' } else { 'stopped or duplicated' }
    if ($service.Url) { $state += '; HTTP ready: ' + (Test-LocalUrl $service.Url) }
    Write-Host ($service.Name + ': ' + $state)
}
$task = Get-ScheduledTask -TaskName $localTaskName -ErrorAction SilentlyContinue
Write-Host ('Automatic start: ' + $(if ($task) { $task.State } else { 'not installed' }))
& $nodePath --env-file=.env .runtime/local-status.mjs --human
if ($LASTEXITCODE -ne 0) { throw 'The local database is unavailable.' }
