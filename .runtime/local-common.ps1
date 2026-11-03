$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$nodePath = Join-Path $PSScriptRoot 'node-v24.22.1-win-x64\node.exe'
$pgCtl = Join-Path $PSScriptRoot 'pgsql\bin\pg_ctl.exe'
$localTaskName = 'PhytoPulse-Local'
$localServices = @(
    @{Name='api'; File='apps/api/src/main.ts'; Url='http://127.0.0.1:3001/api/health'},
    @{Name='web'; File='apps/web/server.ts'; Url='http://localhost:3000/'},
    @{Name='worker'; File='apps/worker/src/main.ts'; Url=$null}
)
function Get-LocalProcess($service) {
    @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" | Where-Object {
        $_.ExecutablePath -eq $nodePath -and $_.CommandLine -match [regex]::Escape($service.File)
    })
}
function Test-LocalUrl([string]$url) {
    try { (Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 3).StatusCode -eq 200 }
    catch { $false }
}
function Enter-LocalLock {
    $deadline = (Get-Date).AddSeconds(60)
    do {
        try { return [IO.File]::Open((Join-Path $PSScriptRoot 'local-control.lock'), 'OpenOrCreate', 'ReadWrite', 'None') }
        catch [IO.IOException] { Start-Sleep -Seconds 1 }
    } while ((Get-Date) -lt $deadline)
    throw 'Another local start/stop is still running.'
}
function Mount-LocalDrive {
    $mapping = & subst.exe
    if ($mapping -match '^P:') {
        if (-not (Test-Path -LiteralPath 'P:\.runtime\instance-id') -or
            (Get-Content -LiteralPath 'P:\.runtime\instance-id' -Raw) -ne
            (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'instance-id') -Raw)) {
            throw 'P: is already in use by another folder.'
        }
    } else {
        & subst.exe P: $projectRoot
        if ($LASTEXITCODE -ne 0) { throw 'Could not map the local database path.' }
    }
}
