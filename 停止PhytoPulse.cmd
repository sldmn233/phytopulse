@echo off
chcp 65001 >nul
powershell.exe -NoLogo -NoProfile -File "%~dp0.runtime\stop-local.ps1"
pause
