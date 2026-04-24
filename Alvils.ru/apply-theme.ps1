# =============================================================
#  Alvils theme installer for Thinfinity Workspace
#  - Self-eleva a Administrador (UAC)
#  - Valida que Thinfinity este instalado
#  - Hace backup con timestamp del custom-themes.json actual
#  - Copia la nueva config
#  - Ofrece reiniciar el servicio Thinfinity Workspace Server
#
#  Uso:  click derecho -> Run with PowerShell
#    o:  powershell -ExecutionPolicy Bypass -File apply-theme.ps1
#    o:  doble click en install.bat
# =============================================================

[CmdletBinding()]
param(
    [switch]$NoRestart,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

# ---- 1. Self-elevate a Administrador ----
$currentId = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin   = ([Security.Principal.WindowsPrincipal]$currentId).IsInRole(
                [Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Se requieren privilegios de Administrador. Solicitando UAC..." -ForegroundColor Yellow
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName  = (Get-Process -Id $PID).Path
    $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    if ($NoRestart) { $argList += '-NoRestart' }
    if ($Uninstall) { $argList += '-Uninstall' }
    $psi.Arguments = $argList -join ' '
    $psi.Verb      = 'runas'
    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        Write-Host "UAC cancelado. Abortando." -ForegroundColor Red
        Start-Sleep 3
    }
    exit
}

# ---- 2. Definiciones de rutas ----
$here    = Split-Path -Parent $PSCommandPath
$srcJson = Join-Path $here 'custom-themes.json'
$srcCss  = Join-Path $here 'customthemes.css'
$tfRoot  = 'C:\Program Files\Thinfinity\Workspace'
$dstJson = Join-Path $tfRoot 'custom-themes.json'
$service = 'ThinfinitySvcMgr'   # display name: "Thinfinity Service Manager"

Write-Host ''
Write-Host '=============================================' -ForegroundColor Cyan
Write-Host '  Alvils theme for Thinfinity Workspace'       -ForegroundColor Cyan
Write-Host '=============================================' -ForegroundColor Cyan
Write-Host ''

# ---- 3. Validaciones ----
if (-not (Test-Path $tfRoot)) {
    Write-Host "[ERROR] No se encontro Thinfinity Workspace en:" -ForegroundColor Red
    Write-Host "        $tfRoot"
    Write-Host "Editar la variable `$tfRoot en el script si la ruta es distinta."
    Read-Host 'Presione ENTER para salir'; exit 1
}
if (-not $Uninstall -and -not (Test-Path $srcJson)) {
    Write-Host "[ERROR] No se encuentra $srcJson" -ForegroundColor Red
    Read-Host 'Presione ENTER para salir'; exit 1
}
if (-not $Uninstall -and -not (Test-Path $srcCss)) {
    Write-Host "[ERROR] No se encuentra $srcCss" -ForegroundColor Red
    Read-Host 'Presione ENTER para salir'; exit 1
}

# ---- 4. Modo desinstalar: restaurar el ultimo backup ----
if ($Uninstall) {
    $lastBkp = Get-ChildItem $tfRoot -Filter 'custom-themes.json.bkp-*' -ErrorAction SilentlyContinue |
               Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($null -eq $lastBkp) {
        Write-Host "[INFO] No hay backup previo para restaurar." -ForegroundColor Yellow
    } else {
        Copy-Item $lastBkp.FullName $dstJson -Force
        Write-Host "Restaurado:  $dstJson" -ForegroundColor Green
        Write-Host "Desde:       $($lastBkp.Name)"
    }
} else {
    # ---- 5. Backup con timestamp del JSON actual ----
    if (Test-Path $dstJson) {
        $bkp = "$dstJson.bkp-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $dstJson $bkp -Force
        Write-Host "Backup creado:  $bkp" -ForegroundColor Green
    } else {
        Write-Host "[INFO] No existe un custom-themes.json previo (primera instalacion)." -ForegroundColor Yellow
    }

    # ---- 6. Copia de la nueva config ----
    Copy-Item $srcJson $dstJson -Force
    Write-Host "Instalado:      $dstJson" -ForegroundColor Green
    Write-Host "CSS apuntado a: $srcCss"
}

# ---- 7. Reinicio del servicio (opcional) ----
$svc = Get-Service -Name $service -ErrorAction SilentlyContinue
if ($null -eq $svc) {
    Write-Host ''
    Write-Host "[INFO] No se encontro el servicio '$service'. Omitiendo reinicio." -ForegroundColor Yellow
} elseif ($NoRestart) {
    Write-Host ''
    Write-Host "[INFO] -NoRestart especificado. Reinicia manualmente el servicio para aplicar los cambios." -ForegroundColor Yellow
} else {
    Write-Host ''
    $ans = Read-Host "Reiniciar el servicio '$service' ahora? [S/n]"
    if ($ans -eq '' -or $ans -match '^[sSyY]') {
        Write-Host "Reiniciando $service..." -ForegroundColor Cyan
        Restart-Service -Name $service -Force
        Start-Sleep 2
        $svc = Get-Service -Name $service
        Write-Host "Estado actual:  $($svc.Status)" -ForegroundColor Green
    } else {
        Write-Host "Omitido. Reinicia el servicio manualmente cuando estes listo." -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host '=============================================' -ForegroundColor Cyan
Write-Host '  Listo. Abri Thinfinity y haci Ctrl+F5.'       -ForegroundColor Cyan
Write-Host '=============================================' -ForegroundColor Cyan
Write-Host ''
Read-Host 'Presione ENTER para cerrar'
