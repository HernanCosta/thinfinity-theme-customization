$ErrorActionPreference = 'Stop'
$root = 'C:\customization\vistaenergy'
$zip  = 'C:\customization\VistaEnergy-Thinfinity-Theme.zip'

if (Test-Path $zip) { Remove-Item $zip -Force }

# Stage everything except _scratch in a temp folder, then zip that.
$staging = Join-Path $env:TEMP ('vista-theme-' + [guid]::NewGuid().ToString('N'))
$vistaDir = Join-Path $staging 'vistaenergy'
New-Item -ItemType Directory -Path $vistaDir -Force | Out-Null

Get-ChildItem $root -File | Copy-Item -Destination $vistaDir -Force

# Brief README for the client inside the zip
$readme = @"
Vista Energy - Thinfinity Workspace theme pack
==============================================

Contents
--------
- customthemes.css          CSS with VistaLight / VistaDark classes
- custom-themes.json        Theme manifest (points at this folder)
- VistaFavicon.ico          Favicon (from vistaenergy.com)
- VistaLogo.svg             Desktop logo, violet fill (light theme)
- VistaLogoMobile.svg       Mobile logo, violet fill
- VistaLogoWhite.svg        Desktop logo, white fill (dark theme)
- VistaLogoMobileWhite.svg  Mobile logo, white fill
- VistaLoginLogo.svg        Logo for the /signin hero panel
- VistaHero.jpg             Hero image (og:image from vistaenergy.com)
- apply-refresh.ps1         Deploy script (self-elevates via UAC)
- install.bat               Launcher for apply-refresh.ps1
- uninstall.bat / .ps1      Reverts to built-in Thinfinity theme

Install
-------
1. Extract this zip to  C:\customization\vistaenergy\
   (The CSS manifest hard-codes this path, so keep it.)
2. Double-click install.bat and accept the UAC prompt.
3. The script stops ThinfinitySvcMgr, copies the assets to
   C:\Program Files\Thinfinity\Workspace\web\__themes__\,
   writes the JSON to both the install and ProgramData locations,
   and restarts the service.
4. Hard-refresh the browser (Ctrl+Shift+R) to load the new theme.

Themes included
---------------
- Vista (light) - default
- Vista (dark)  - matches vistaenergy.com's own dark indigo surface

The theme switcher is enabled (users can toggle). Built-in Thinfinity
themes are hidden. Edit custom-themes.json before install to change:
  "allowUsersToSwitchTheme": false  -> force a single theme
  "allowBuiltInThemes": true        -> keep Thinfinity's defaults visible

Uninstall
---------
Double-click uninstall.bat. Removes all Vista* assets and resets the
JSON so the server falls back to the built-in theme.
"@

Set-Content -Path (Join-Path $vistaDir 'README.txt') -Value $readme -Encoding UTF8

Compress-Archive -Path (Join-Path $staging 'vistaenergy') -DestinationPath $zip -CompressionLevel Optimal

Remove-Item $staging -Recurse -Force

$info = Get-Item $zip
Write-Host ""
Write-Host "Created: $($info.FullName)"
Write-Host ("Size:    {0:N0} bytes ({1:N1} KB)" -f $info.Length, ($info.Length/1KB))
Write-Host ""
Write-Host "Contents:"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
$archive.Entries | Sort-Object FullName | ForEach-Object {
    "{0,10:N0}  {1}" -f $_.Length, $_.FullName
}
$archive.Dispose()
