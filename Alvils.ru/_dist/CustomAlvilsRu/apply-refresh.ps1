$ErrorActionPreference = 'Stop'
$cid = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$cid).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath (Get-Process -Id $PID).Path -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    exit
}
$here    = 'C:\customization\Alvils.ru'
$webDst  = 'C:\Program Files\Thinfinity\Workspace\web\__themes__'
$pfJson  = 'C:\Program Files\Thinfinity\Workspace\custom-themes.json'
$pdJson  = 'C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json'

Stop-Service ThinfinitySvcMgr -Force -ErrorAction SilentlyContinue
Start-Sleep 2

# Sync assets
New-Item -ItemType Directory -Force -Path $webDst | Out-Null
Get-ChildItem $here -File | Where-Object { $_.Extension -in '.css','.svg','.ico','.png','.jpg' } |
    ForEach-Object { Copy-Item $_.FullName (Join-Path $webDst $_.Name) -Force }
Copy-Item (Join-Path $here 'customthemes.css') (Join-Path $webDst 'custom-theme.css') -Force

Copy-Item (Join-Path $here 'custom-themes.json') $pfJson -Force
Copy-Item (Join-Path $here 'custom-themes.json') $pdJson -Force

Start-Service ThinfinitySvcMgr
Start-Sleep 3
Write-Host "Listo. Abri Thinfinity y hace Ctrl+Shift+R." -ForegroundColor Green
Read-Host 'ENTER para cerrar'
