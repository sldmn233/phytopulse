@echo off
chcp 65001 >nul
powershell.exe -NoLogo -NoProfile -File "%~dp0.runtime\open-local.ps1"
if errorlevel 1 pause
