# Thinfinity Workspace customization — full steps

Practical guide for creating a theme from a corporate site branding. Updated for v8.5 (March 2026). Complements and corrects the official KB (https://kb.cybelesoft.com/portal/en/kb/articles/new-theme-customization-api-in-thinfinity-workspace).

---

## 0. Prerequisites

- Thinfinity Workspace installed (typically `C:\Program Files\Thinfinity\Workspace\`).
- Local Administrator account.
- PowerShell 5.1+ (included in Windows).
- `curl.exe` (present in Windows 10+ at `C:\Windows\System32\`).
- Any modern browser to validate (Chrome/Edge/Firefox).

Verify the installed version:

```powershell
(Get-Item "C:\Program Files\Thinfinity\Workspace\bin64\Thinfinity.VirtualUI.Server.exe").VersionInfo.ProductVersion
```

---

## 1. Folder layout

Recommended convention:

```
C:\customization\<BrandName>\
├── customthemes.css        (theme source)
├── custom-themes.json      (config)
├── <Brand>Favicon.ico
├── <Brand>Logo.png         (main site logo)
├── <Brand>LoginBg.jpg      (hero image for the login brand panel)
├── apply-refresh.ps1       (installer: UAC + service restart)
├── install.bat             (launcher)
└── uninstall.bat           (restores previous backup)
```

The theme assets **do not** have to live inside the Thinfinity install. `apply-refresh.ps1` copies them to `C:\Program Files\Thinfinity\Workspace\web\__themes__\` so Thinfinity can serve them.

---

## 2. Extract branding from the reference site

```bash
# Main HTML + CSS
curl -s -A "Mozilla/5.0" https://www.<site>/ -o index.html
curl -s -A "Mozilla/5.0" https://www.<site>/path/to/style.css -o style.css

# Favicon (look in the HTML: <link rel="icon" ...>)
curl -s -A "Mozilla/5.0" -o <Brand>Favicon.ico https://www.<site>/favicon.ico

# Logo (look in the CSS: #logo { background: url(img/logo.png) } or <img src>)
curl -s -A "Mozilla/5.0" -o <Brand>Logo.png https://www.<site>/path/to/logo.png

# Hero image (CSS: #slider, .hero, .banner — typically has a background-image)
curl -s -A "Mozilla/5.0" -o <Brand>LoginBg.jpg https://www.<site>/path/to/hero.jpg
```

Extract the hex color palette from the CSS:

```powershell
$css = Get-Content style.css -Raw
[regex]::Matches($css, "#[0-9a-fA-F]{6}") | ForEach-Object { $_.Value } |
  Group-Object | Sort-Object Count -Descending | Select-Object -First 15
```

The 3–5 most frequent hex values are usually the official palette. Identify:
- **Primary**: buttons/CTA/active nav color.
- **Dark primary**: hover states, headings, hero background.
- **Accent**: tertiary (warnings, highlights).

---

## 3. Build `customthemes.css`

Use two classes: `.<Brand>Light` and `.<Brand>Dark`. Each must define the full set of variables.

### Core variables (from the KB)

```css
/* Brand palette */
--primary-color --dark-primary-color --light-primary-color
--secondary-color --tertiary-color

/* Surfaces */
--primary-bgcolor --secondary-bgcolor --tertiary-bgcolor --hover-bgcolor
--header-bgcolor --toolbar-bgcolor
--sidepanel-bgcolor --sidepanel-header-bgcolor
--menu-bgcolor --dialog-bgcolor --submenu-bgcolor
--table-header-bgcolor --table-body-bgcolor --table-body-bgcolor-h
--<ClassName>-entity-bg     /* dynamic, e.g. --AlvilsLight-entity-bg */

/* Buttons */
--button-bgcolor --button-txtcolor --button-bgcolor-h --button-txtcolor-h
--outline-button-color --outline-button-bgcolor-h --outline-button-color-h
--special-button --switcher-button

/* Links & menus */
--link-color --link-color-h --menu-selected-color --menu-selected-bgcolor

/* Text */
--primary-txtcolor --secondary-txtcolor --heading-color

/* Borders */
--border-color --light-border-color --separator

/* Status */
--disabled --danger --alert --allowed --shadow-color

/* Dashboard background (post-login .bg-primary) */
--bg-image --bg-size --bg-blend-mode

/* Logos */
--desktop-logo --mobile-logo --login-logo --logo-bg-size
```

### Additional variables **NOT documented in the KB** (v8+)

They control the `/signin` screen (split login with brand panel on the left):

```css
--login-brand-bg                /* left panel image/gradient */
--login-brand-bg-size           /* cover / contain / ... */
--login-brand-bg-repeat
--login-brand-bg-position-x
--login-brand-bg-position-y
--login-brand-bg-blend-mode

--login-form-bg                 /* right panel background (form) */
--login-form-bg-size
--login-form-bg-repeat
--login-form-bg-position-x
--login-form-bg-position-y
--login-form-bg-blend-mode

--login-box-width               /* form box width */
```

### URLs inside the CSS

Use the documented prefix:

```css
--login-logo: url("<%=@BASEURL%>__themes__/<Brand>Logo.png");
--login-brand-bg: url("<%=@BASEURL%>__themes__/<Brand>LoginBg.jpg");
```

Thinfinity expands `<%=@BASEURL%>` when serving the CSS. Plain relative paths (no prefix) do **not** resolve reliably in all contexts.

---

## 4. Build `custom-themes.json`

```json
{
  "filename": "C:\\customization\\<Brand>\\customthemes.css",
  "favicon": "<Brand>Favicon.ico",
  "allowUsersToSwitchTheme": true,
  "allowBuiltInThemes": false,
  "defaultTheme": "<Brand>Light",
  "lightMode": "<Brand>Light",
  "darkMode": "<Brand>Dark",
  "productName": "<Brand> Workspace",
  "themes": [
    { "class": "<Brand>Light", "name": "<Brand> (light)" },
    { "class": "<Brand>Dark",  "name": "<Brand> (dark)" }
  ]
}
```

Notes:
- `productName` appears as the browser `<title>`.
- `allowBuiltInThemes: false` hides the built-in Light/Dark/Blue from the switcher.
- `filename` must be an absolute path with escaped backslashes.
- **`favicon` must be `.ico`**. SVG does not render because Thinfinity serves the file with MIME `image/x-icon`.
- The `themeOverriden` field shown in the KB example is legacy — you can omit it.

---

## 5. Deploy script (`apply-refresh.ps1`)

```powershell
$ErrorActionPreference = 'Stop'

# Self-elevate
$cid = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$cid).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath (Get-Process -Id $PID).Path -Verb RunAs `
        -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    exit
}

$here    = 'C:\customization\<Brand>'
$webDst  = 'C:\Program Files\Thinfinity\Workspace\web\__themes__'
$pfJson  = 'C:\Program Files\Thinfinity\Workspace\custom-themes.json'
$pdJson  = 'C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json'

Stop-Service ThinfinitySvcMgr -Force -ErrorAction SilentlyContinue
Start-Sleep 2

# Timestamped backup of existing JSON
if (Test-Path $pfJson) {
    Copy-Item $pfJson "$pfJson.bkp-$(Get-Date -Format 'yyyyMMddHHmmss')" -Force
}

# Sync all assets (CSS + images)
New-Item -ItemType Directory -Force -Path $webDst | Out-Null
Get-ChildItem $here -File |
    Where-Object { $_.Extension -in '.css','.svg','.ico','.png','.jpg' } |
    ForEach-Object { Copy-Item $_.FullName (Join-Path $webDst $_.Name) -Force }

# Required alias: Thinfinity expects a fixed custom-theme.css endpoint
Copy-Item (Join-Path $here 'customthemes.css') `
          (Join-Path $webDst 'custom-theme.css') -Force

# JSON to both locations (active one on v8.5 is Program Files)
Copy-Item (Join-Path $here 'custom-themes.json') $pfJson -Force
if (Test-Path (Split-Path $pdJson -Parent)) {
    Copy-Item (Join-Path $here 'custom-themes.json') $pdJson -Force
}

Start-Service ThinfinitySvcMgr
Start-Sleep 3
Read-Host 'Done. Press ENTER to close'
```

`install.bat` wrapper:

```bat
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply-refresh.ps1"
```

---

## 6. Verify

### In the browser

1. Open Thinfinity in **incognito** (avoids stale cache).
2. **F12 → Network** tab before reloading.
3. **Ctrl+Shift+R** for a hard refresh.
4. Check:
   - Tab title = `<Brand> Workspace` ✓
   - Favicon in the browser tab ✓
   - `custom-theme.css` returns 200 with reasonable size.
   - Logo on the login left panel.
   - Background image on the login left panel (`--login-brand-bg`).
   - Sign-in button with the primary color.

### In DevTools → Elements

- Select `<body>` or `<html>`.
- The `class` attribute should contain `<Brand>Light` or `<Brand>Dark` (not `light-mode`/`dark-mode`).

### If something doesn't appear

| Symptom | Likely cause | Fix |
|---|---|---|
| Changes not visible | Browser cached CSS | Incognito or `Ctrl+Shift+R` |
| `custom-theme.css` → 404 | JSON not loaded or service not restarted | Verify JSON + `Restart-Service ThinfinitySvcMgr` |
| CSS loads but no visual change | `.<Brand>Light` class not applied to body | Check `defaultTheme` and `lightMode` in JSON |
| Favicon doesn't appear | File is not a real `.ico` | Generate a real `.ico` (not SVG) |
| Login logo OK but left panel still blue | Missing `--login-brand-bg*` vars | Add them to both themes |
| Dashboard (post-login) has no background | `--bg-image` not set | Add it to both themes |

---

## 7. Corrections to the official KB

Discrepancies found vs. the KB (apply to v8.5):

1. **JSON location**: active at `Program Files\Thinfinity\Workspace\`, not `ProgramData\DB`.
2. **Service to restart**: `ThinfinitySvcMgr`. Not mentioned in the KB.
3. **Undocumented login variables**: `--login-brand-bg*`, `--login-form-bg*`, `--login-box-width`.
4. **Scope of `--bg-image`**: only applies to `.bg-primary` inside `#app` (dashboard), not `/signin`.
5. **Favicon**: must be `.ico`, not SVG.
6. **`themeOverriden` field**: legacy, not referenced by v8 binaries.
7. **CSS URL**: `/__themes__/custom-theme.css` (double underscore prefix), not `themes__/`.
8. **Load mechanism**: in v8 the new app (`/workspace/`) loads the custom CSS dynamically via `/__base__/config/websettings`, not via a static `<link>`. The classic app (`/app.html`) still uses `<link>`.

---

## 8. Rollback

```powershell
# List backups
Get-ChildItem 'C:\Program Files\Thinfinity\Workspace\' -Filter 'custom-themes.json.bkp-*' |
    Sort-Object LastWriteTime -Descending

# Restore the most recent
$last = Get-ChildItem 'C:\Program Files\Thinfinity\Workspace\' -Filter 'custom-themes.json.bkp-*' |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
Copy-Item $last.FullName 'C:\Program Files\Thinfinity\Workspace\custom-themes.json' -Force
Restart-Service ThinfinitySvcMgr
```

Or use the launcher: `uninstall.bat`.

---

## 9. Impact of Thinfinity upgrades

A Thinfinity upgrade **may overwrite** parts of the custom theme. Not critical because the install script is idempotent, but you need to re-run it after the upgrade.

**What gets overwritten**:
- `C:\Program Files\Thinfinity\Workspace\custom-themes.json` → MSIs replace files in the install dir. Reverts to the default stub.
- `C:\Program Files\Thinfinity\Workspace\web\__themes__\` → may be deleted or overwritten.

**What survives**:
- `C:\customization\<Brand>\` → outside the install. Source of truth lives here.

**Post-upgrade workflow**:
1. Upgrade Thinfinity.
2. Double-click `install.bat` in the brand folder.
3. `Ctrl+Shift+R` in the browser.

**Risks on major upgrades (v8.x → v9)**:
- The service name (currently `ThinfinitySvcMgr`) may change → the script will silently fail at restart.
- The active JSON location may move.
- The undocumented CSS variables we discovered (`--login-brand-bg*`, `--login-form-bg*`, `--login-box-width`) may be renamed or removed if the new app bundle is refactored.

If something breaks after an upgrade: re-inspect `C:\Program Files\Thinfinity\Workspace\web\workspace\assets\style.css` to confirm the variable names are still in effect, and update the CSS accordingly.
