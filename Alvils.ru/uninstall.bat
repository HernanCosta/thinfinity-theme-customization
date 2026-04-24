@echo off
REM Restaura el custom-themes.json previo desde el ultimo backup con timestamp.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply-theme.ps1" -Uninstall
