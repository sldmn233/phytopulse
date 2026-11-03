. "$PSScriptRoot\local-common.ps1"
$task = Get-ScheduledTask -TaskName $localTaskName -ErrorAction SilentlyContinue
if ($task -and $task.State -eq 'Running') { Stop-ScheduledTask -TaskName $localTaskName }
$lock = Enter-LocalLock
try {
    foreach ($name in @('worker','web','api')) {
        $service = $localServices | Where-Object Name -eq $name
        foreach ($owned in @(Get-LocalProcess $service)) {
            $process = Get-Process -Id $owned.ProcessId -ErrorAction SilentlyContinue
            if ($process -and $process.Path -eq $nodePath) { Stop-Process -InputObject $process; $process.WaitForExit(10000) | Out-Null }
        }
        Remove-Item -LiteralPath (Join-Path $PSScriptRoot ($name+'.pid')) -ErrorAction SilentlyContinue
    }
    Mount-LocalDrive
    & $pgCtl -D 'P:/.runtime/pgdata-local' status *> $null
    if ($LASTEXITCODE -eq 0) {
        & $pgCtl -D 'P:/.runtime/pgdata-local' -m fast -w -t 30 stop
        if ($LASTEXITCODE -ne 0) { throw 'Database shutdown did not finish. See .runtime/postgres.log.' }
    }
    Write-Host 'PhytoPulse stopped. Saved data is retained. It will start at the next Windows sign-in.'
} finally { $lock.Dispose() }
