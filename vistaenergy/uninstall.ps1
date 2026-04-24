# uninstall.ps1 - Revert Thinfinity Workspace to built-in theme.
# Deletes Vista* assets from web\__themes__\, restores empty custom-themes.json,
# restarts the service.

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $args = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    Start-Process -FilePath 'powershell.exe' -ArgumentList $args -Verb RunAs
    exit
}

$tfInstall   = 'C:\Program Files\Thinfinity\Workspace'
$tfThemesWeb = Join-Path $tfInstall 'web\__themes__'
$tfJsonInst  = Join-Path $tfInstall 'custom-themes.json'
$tfJsonDb    = 'C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json'
$serviceName = 'ThinfinitySvcMgr'

Write-Host "Stopping $serviceName ..."
Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue

Write-Host "Removing Vista* assets ..."
Get-ChildItem $tfThemesWeb -Filter 'Vista*' -File -ErrorAction SilentlyContinue |
    ForEach-Object { Remove-Item $_.FullName -Force; Write-Host "   removed $($_.Name)" }

# Remove the custom CSS alias files we wrote
foreach ($f in @('customthemes.css','custom-theme.css')) {
    $p = Join-Path $tfThemesWeb $f
    if (Test-Path $p) { Remove-Item $p -Force; Write-Host "   removed $f" }
}

# Blank out JSON so Thinfinity falls back to built-in
$empty = '{}'
Set-Content -Path $tfJsonInst -Value $empty -Encoding UTF8
Set-Content -Path $tfJsonDb   -Value $empty -Encoding UTF8
Write-Host "custom-themes.json reset to {} in both locations."

Write-Host "Starting $serviceName ..."
Start-Service -Name $serviceName -ErrorAction SilentlyContinue

Write-Host "Done. Hard-refresh the browser (Ctrl+Shift+R)."
Read-Host "Press Enter to close"
