@echo off
REM Vista Energy theme installer for Thinfinity Workspace
REM Launches the PowerShell apply script (which self-elevates via UAC).
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply-refresh.ps1"
