$ErrorActionPreference = 'Stop'
while ($true) {
    try { & "$PSScriptRoot\start-local.ps1" *> (Join-Path $PSScriptRoot 'last-start.log') }
    catch { Add-Content -LiteralPath (Join-Path $PSScriptRoot 'watch-errors.log') -Value ((Get-Date -Format o) + ' ' + $_.Exception.Message) }
    Start-Sleep -Seconds 60
}
