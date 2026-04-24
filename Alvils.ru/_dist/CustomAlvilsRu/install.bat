@echo off
REM Launcher de un clic para el instalador del tema Alvils.
REM Doble-click y aceptar el prompt UAC.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply-theme.ps1"
