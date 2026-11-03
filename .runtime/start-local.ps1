. "$PSScriptRoot\local-common.ps1"
$lock = Enter-LocalLock
try {
    Set-Location -LiteralPath $projectRoot
    Mount-LocalDrive
    if (-not (Test-Path -LiteralPath 'apps\web\build\server\index.js')) {
        throw 'The web build is missing. Rebuild the site before starting.'
    }
    & $pgCtl -D 'P:/.runtime/pgdata-local' status *> $null
    if ($LASTEXITCODE -ne 0) {
        & $pgCtl -D 'P:/.runtime/pgdata-local' -l 'P:/.runtime/postgres.log' -o '-h 127.0.0.1 -p 55432' -w -t 30 start
        if ($LASTEXITCODE -ne 0) { throw 'Database did not start. See .runtime/postgres.log.' }
    }
    $env:NODE_ENV = 'production'
    foreach ($service in $localServices) {
        $owned = @(Get-LocalProcess $service)
        if ($owned.Count -gt 1) { throw "More than one $($service.Name) process exists. Stop the site first." }
        if ($owned.Count -eq 0) {
            if ($service.Url -and (Test-LocalUrl $service.Url)) { throw "The $($service.Name) port is occupied by another service." }
            $process = Start-Process -FilePath $nodePath -ArgumentList '--env-file=.env',$service.File -WorkingDirectory $projectRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $PSScriptRoot ($service.Name+'.log')) -RedirectStandardError (Join-Path $PSScriptRoot ($service.Name+'.err')) -PassThru
            $servicePid = $process.Id
        } else { $servicePid = $owned[0].ProcessId }
        Set-Content -LiteralPath (Join-Path $PSScriptRoot ($service.Name+'.pid')) -Value $servicePid -Encoding ascii
        $deadline = (Get-Date).AddSeconds(45)
        do {
            if (-not (Get-Process -Id $servicePid -ErrorAction SilentlyContinue)) { throw "$($service.Name) exited. See .runtime/$($service.Name).err." }
            if ($service.Url) { $ready = Test-LocalUrl $service.Url }
            else {
                $marker = '"msg":"worker started","pid":' + $servicePid + '}'
                $ready = [bool](Select-String -LiteralPath (Join-Path $PSScriptRoot 'worker.log') -SimpleMatch $marker -Quiet -ErrorAction SilentlyContinue)
            }
            if ($ready) { break }
            Start-Sleep -Seconds 1
        } while ((Get-Date) -lt $deadline)
        if (-not $ready) { throw "$($service.Name) did not become ready. Check its .runtime log." }
    }
    Write-Host 'PhytoPulse is ready: http://localhost:3000'
} finally { $lock.Dispose() }
