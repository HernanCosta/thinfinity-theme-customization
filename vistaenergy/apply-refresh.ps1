# apply-refresh.ps1 - Deploy Vista Energy theme to Thinfinity Workspace (v8+)
# Self-elevates via UAC. Copies assets + JSON to installation and ProgramData,
# restarts ThinfinitySvcMgr, verifies endpoints.

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# --- Self-elevate ---
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator..." -ForegroundColor Yellow
    $args = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    Start-Process -FilePath 'powershell.exe' -ArgumentList $args -Verb RunAs
    exit
}

# --- Paths ---
$brandRoot   = 'C:\customization\vistaenergy'
$tfInstall   = 'C:\Program Files\Thinfinity\Workspace'
$tfThemesWeb = Join-Path $tfInstall 'web\__themes__'
$tfJsonInst  = Join-Path $tfInstall 'custom-themes.json'
$tfJsonDb    = 'C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json'
$serviceName = 'ThinfinitySvcMgr'

Write-Host ""
Write-Host "==== Vista Energy theme deploy ====" -ForegroundColor Cyan
Write-Host "Source: $brandRoot"
Write-Host "Target: $tfThemesWeb"
Write-Host ""

# --- Pre-flight ---
if (-not (Test-Path $brandRoot))   { throw "Source not found: $brandRoot" }
if (-not (Test-Path $tfInstall))   { throw "Thinfinity not installed at: $tfInstall" }
if (-not (Test-Path $tfThemesWeb)) { throw "Themes dir missing: $tfThemesWeb" }

# --- Stop service ---
$svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($svc) {
    if ($svc.Status -ne 'Stopped') {
        Write-Host "[1/5] Stopping $serviceName ..."
        Stop-Service -Name $serviceName -Force
        $svc.WaitForStatus('Stopped', '00:00:30')
    } else {
        Write-Host "[1/5] $serviceName already stopped."
    }
} else {
    Write-Warning "Service $serviceName not found - continuing without restart."
}

# --- Sync assets to web\__themes__\ ---
Write-Host "[2/5] Syncing assets to $tfThemesWeb ..."
$assetExts = '*.css','*.svg','*.png','*.jpg','*.jpeg','*.ico','*.webp','*.gif'
$copied = 0
foreach ($pat in $assetExts) {
    Get-ChildItem -Path $brandRoot -Filter $pat -File -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination (Join-Path $tfThemesWeb $_.Name) -Force
        Write-Host "   copied $($_.Name)"
        $copied++
    }
}
Write-Host "   total files copied: $copied"

# --- Alias: Thinfinity sometimes loads custom-theme.css (singular) ---
# Both names copied so either bundler path resolves.
$cssSrc = Join-Path $brandRoot 'customthemes.css'
if (Test-Path $cssSrc) {
    Copy-Item $cssSrc (Join-Path $tfThemesWeb 'custom-theme.css')  -Force
    Copy-Item $cssSrc (Join-Path $tfThemesWeb 'customthemes.css')  -Force
}

# --- JSON config to both locations ---
Write-Host "[3/5] Copying custom-themes.json ..."
$jsonSrc = Join-Path $brandRoot 'custom-themes.json'
if (-not (Test-Path $jsonSrc)) { throw "Missing $jsonSrc" }

Copy-Item $jsonSrc $tfJsonInst -Force
Write-Host "   -> $tfJsonInst"

$dbDir = Split-Path $tfJsonDb -Parent
if (-not (Test-Path $dbDir)) { New-Item -ItemType Directory -Path $dbDir -Force | Out-Null }
Copy-Item $jsonSrc $tfJsonDb -Force
Write-Host "   -> $tfJsonDb"

# --- Start service ---
if ($svc) {
    Write-Host "[4/5] Starting $serviceName ..."
    Start-Service -Name $serviceName
    (Get-Service -Name $serviceName).WaitForStatus('Running', '00:00:30')
    Write-Host "   status: $((Get-Service -Name $serviceName).Status)"
}

# --- Sanity check ---
Write-Host "[5/5] Verifying files in place ..."
$expected = @(
    'customthemes.css','custom-theme.css',
    'VistaFavicon.ico',
    'VistaLogo.svg','VistaLogoMobile.svg',
    'VistaLogoWhite.svg','VistaLogoMobileWhite.svg',
    'VistaLoginLogo.svg','VistaHero.jpg'
)
foreach ($f in $expected) {
    $p = Join-Path $tfThemesWeb $f
    if (Test-Path $p) { Write-Host "   OK  $f" -ForegroundColor Green }
    else              { Write-Host "   MISS $f" -ForegroundColor Red }
}

Write-Host ""
Write-Host "Done. Hard-refresh the browser (Ctrl+Shift+R) and check /signin." -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to close"
