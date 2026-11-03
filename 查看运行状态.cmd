@echo off
chcp 65001 >nul
powershell.exe -NoLogo -NoProfile -File "%~dp0.runtime\show-local.ps1"
pause
