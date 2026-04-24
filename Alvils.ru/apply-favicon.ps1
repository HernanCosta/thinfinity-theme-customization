$ErrorActionPreference = 'Stop'
$cid = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$cid).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath (Get-Process -Id $PID).Path -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    exit
}
$here = 'C:\customization\Alvils.ru'
Copy-Item (Join-Path $here 'AlvilsFavicon.ico') 'C:\Program Files\Thinfinity\Workspace\web\__themes__\AlvilsFavicon.ico' -Force
Copy-Item (Join-Path $here 'custom-themes.json') 'C:\Program Files\Thinfinity\Workspace\custom-themes.json' -Force
Copy-Item (Join-Path $here 'custom-themes.json') 'C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json' -Force
Restart-Service ThinfinitySvcMgr -Force
Start-Sleep 3
Write-Host "Listo. Ctrl+Shift+R en el browser." -ForegroundColor Green
Read-Host 'ENTER para cerrar'
