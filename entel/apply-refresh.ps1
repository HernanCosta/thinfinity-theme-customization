# apply-refresh.ps1 - Deploy Entel theme to Thinfinity Workspace (v8+)
# Portable: runs from wherever the zip was extracted ($PSScriptRoot).
# Self-elevates via UAC. Copies assets + JSON to installation and ProgramData,
# rewrites the JSON "filename" to this folder's CSS, restarts ThinfinitySvcMgr.

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

# --- Paths (portable: source = folder containing this script) ---
$brandRoot   = $PSScriptRoot
$tfInstall   = 'C:\Program Files\Thinfinity\Workspace'
$tfThemesWeb = Join-Path $tfInstall 'web\__themes__'
$tfJsonInst  = Join-Path $tfInstall 'custom-themes.json'
$tfJsonDb    = 'C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json'
$serviceName = 'ThinfinitySvcMgr'

Write-Host ""
Write-Host "==== Entel theme deploy ====" -ForegroundColor Cyan
Write-Host "Source: $brandRoot"
Write-Host "Target: $tfThemesWeb"
Write-Host ""

# --- Pre-flight ---
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

# --- Backup existing JSON (timestamped) ---
if (Test-Path $tfJsonInst) {
    Copy-Item $tfJsonInst "$tfJsonInst.bkp-$(Get-Date -Format 'yyyyMMddHHmmss')" -Force
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

# --- Alias: Thinfinity loads custom-theme.css (singular) ---
$cssSrc = Join-Path $brandRoot 'customthemes.css'
if (Test-Path $cssSrc) {
    Copy-Item $cssSrc (Join-Path $tfThemesWeb 'custom-theme.css')  -Force
    Copy-Item $cssSrc (Join-Path $tfThemesWeb 'customthemes.css')  -Force
}

# --- JSON config: rewrite "filename" to THIS folder's CSS, then copy ---
Write-Host "[3/5] Writing custom-themes.json ..."
$jsonSrc = Join-Path $brandRoot 'custom-themes.json'
if (-not (Test-Path $jsonSrc)) { throw "Missing $jsonSrc" }

$cfg = Get-Content $jsonSrc -Raw | ConvertFrom-Json
$cfg.filename = $cssSrc
$jsonOut = $cfg | ConvertTo-Json -Depth 5

Set-Content -Path $tfJsonInst -Value $jsonOut -Encoding UTF8
Write-Host "   -> $tfJsonInst (filename = $cssSrc)"

$dbDir = Split-Path $tfJsonDb -Parent
if (-not (Test-Path $dbDir)) { New-Item -ItemType Directory -Path $dbDir -Force | Out-Null }
Set-Content -Path $tfJsonDb -Value $jsonOut -Encoding UTF8
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
    'EntelFavicon.ico',
    'EntelLogo.svg','EntelLogoMobile.svg',
    'EntelLogoWhite.svg','EntelLogoMobileWhite.svg',
    'EntelLoginLogo.svg','EntelHero.jpg'
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
