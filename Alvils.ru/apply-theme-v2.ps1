# Install Alvils theme trying every known Thinfinity v7/v8 location.
# Self-eleva, copia el JSON a Program Files y ProgramData\DB,
# y tambien deja una copia de los assets dentro del web folder
# para descartar problemas de path absoluto.

$ErrorActionPreference = 'Stop'

# ---- Self elevate ----
$cid = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$cid).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando UAC..." -ForegroundColor Yellow
    Start-Process -FilePath (Get-Process -Id $PID).Path -Verb RunAs `
        -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    exit
}

$here     = Split-Path -Parent $PSCommandPath
$pfRoot   = 'C:\Program Files\Thinfinity\Workspace'
$pdRoot   = 'C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB'
$webRoot  = Join-Path $pfRoot 'web'
$assetDst = Join-Path $webRoot '__themes__'

$service  = 'ThinfinitySvcMgr'

# ---- 1. Stop service ----
Write-Host "=== 1. Detengo servicio $service ==="
Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
Start-Sleep 2

# ---- 2. Copy JSON to both locations ----
$srcJson = Join-Path $here 'custom-themes.json'
foreach ($dst in @((Join-Path $pfRoot 'custom-themes.json'), (Join-Path $pdRoot 'custom-themes.json'))) {
    $dir = Split-Path $dst -Parent
    if (-not (Test-Path $dir)) { Write-Host "  skip (dir no existe): $dir" -ForegroundColor Yellow; continue }
    if (Test-Path $dst) { Copy-Item $dst "$dst.bkp-$(Get-Date -Format 'yyyyMMddHHmmss')" -Force }
    Copy-Item $srcJson $dst -Force
    Write-Host "  JSON -> $dst" -ForegroundColor Green
}

# ---- 3. Drop CSS + assets into web/__themes__/ (fallback relative path) ----
Write-Host "=== 2. Copio assets a $assetDst ==="
New-Item -ItemType Directory -Force -Path $assetDst | Out-Null
Get-ChildItem $here -File | Where-Object { $_.Extension -in '.css','.svg','.ico','.png','.jpg' } |
    ForEach-Object { Copy-Item $_.FullName (Join-Path $assetDst $_.Name) -Force; Write-Host "  $($_.Name)" }

# Tambien dejamos custom-theme.css como copia directa del customthemes.css
Copy-Item (Join-Path $here 'customthemes.css') (Join-Path $assetDst 'custom-theme.css') -Force
Write-Host "  custom-theme.css (alias)" -ForegroundColor Green

# ---- 4. Start service ----
Write-Host "=== 3. Inicio servicio $service ==="
Start-Service -Name $service
Start-Sleep 3
Get-Service $service | Format-List Status,Name,DisplayName

Write-Host ""
Write-Host "LISTO. Abri Thinfinity en incognito y revisa DevTools -> Network." -ForegroundColor Cyan
Read-Host 'Presione ENTER para cerrar'
