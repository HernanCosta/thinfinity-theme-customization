# Customización de Thinfinity Workspace — pasos completos

> **⚠️ OUTDATED (2026-06-12).** The deployment model in this guide (assets
> synced to `Program Files\...\web\__themes__\`, JSON in Program Files,
> installer scripts) was disproven against server source
> (`dev-main\Units\IISServer\IISServer.Themes.pas`): the JSON is read only
> from the ProgramData DB folder and `/__themes__/` is a virtual alias to
> the CSS's own folder — nothing is copied to Program Files, no installer
> is needed. **Use the root `PROMPT-TEMPLATE.md` as the current process.**
> The CSS variable reference below (sections 3 and 7.3) is still valid.

Guía práctica para crear un tema basado en el branding de un site corporativo. Actualizada para v8.5 (marzo 2026). Complementa y corrige la KB oficial (https://kb.cybelesoft.com/portal/en/kb/articles/new-theme-customization-api-in-thinfinity-workspace).

---

## 0. Requisitos

- Thinfinity Workspace instalado (típicamente `C:\Program Files\Thinfinity\Workspace\`).
- Usuario con permisos de Administrador local.
- PowerShell 5.1+ (incluido en Windows).
- `curl.exe` (presente en Windows 10+ en `C:\Windows\System32\`).
- Browser para validar (Chrome/Edge/Firefox).

Verificá la versión instalada:

```powershell
(Get-Item "C:\Program Files\Thinfinity\Workspace\bin64\Thinfinity.VirtualUI.Server.exe").VersionInfo.ProductVersion
```

---

## 1. Estructura de carpetas

Convención propuesta:

```
C:\customization\<BrandName>\
├── customthemes.css        (fuente del tema)
├── custom-themes.json      (config)
├── <Brand>Favicon.ico
├── <Brand>Logo.png         (logo principal del site)
├── <Brand>LoginBg.jpg      (imagen hero para el panel de login)
├── apply-refresh.ps1       (instalador con UAC + restart servicio)
├── install.bat             (launcher)
└── uninstall.bat           (restaura backup previo)
```

Los assets del tema **NO** tienen que vivir dentro del install de Thinfinity. El `apply-refresh.ps1` los copia a `C:\Program Files\Thinfinity\Workspace\web\__themes__\` para que Thinfinity los sirva.

---

## 2. Extraer branding del site de referencia

```bash
# HTML + CSS principal
curl -s -A "Mozilla/5.0" https://www.<site>/ -o index.html
curl -s -A "Mozilla/5.0" https://www.<site>/path/to/style.css -o style.css

# Favicon (buscar en HTML: <link rel="icon" ...>)
curl -s -A "Mozilla/5.0" -o <Brand>Favicon.ico https://www.<site>/favicon.ico

# Logo (buscar en CSS: #logo { background: url(img/logo.png) } o <img src>)
curl -s -A "Mozilla/5.0" -o <Brand>Logo.png https://www.<site>/path/to/logo.png

# Imagen hero (CSS: #slider, .hero, .banner — suele tener un background-image)
curl -s -A "Mozilla/5.0" -o <Brand>LoginBg.jpg https://www.<site>/path/to/hero.jpg
```

Extraer paleta de colores hex del CSS:

```powershell
$css = Get-Content style.css -Raw
[regex]::Matches($css, "#[0-9a-fA-F]{6}") | ForEach-Object { $_.Value } |
  Group-Object | Sort-Object Count -Descending | Select-Object -First 15
```

Los 3-5 colores más frecuentes suelen ser la paleta oficial. Identificar:
- **Primary**: color de botones/CTA/nav activa.
- **Dark primary**: hover states, headings, hero bg.
- **Accent**: tertiary (warnings, highlights).

---

## 3. Crear `customthemes.css`

Usar dos clases: `.<Brand>Light` y `.<Brand>Dark`. Cada una debe definir el conjunto completo de variables.

### Variables core (de la KB)

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
--<ClassName>-entity-bg     /* dinámica, ej: --AlvilsLight-entity-bg */

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

### Variables adicionales **NO documentadas en la KB** (v8+)

Controlan la pantalla `/signin` (split login con panel de marca a la izquierda):

```css
--login-brand-bg                /* imagen/gradient del panel izquierdo */
--login-brand-bg-size           /* cover / contain / ... */
--login-brand-bg-repeat
--login-brand-bg-position-x
--login-brand-bg-position-y
--login-brand-bg-blend-mode

--login-form-bg                 /* fondo del panel derecho (form) */
--login-form-bg-size
--login-form-bg-repeat
--login-form-bg-position-x
--login-form-bg-position-y
--login-form-bg-blend-mode

--login-box-width               /* ancho del box del formulario */
```

### URLs dentro del CSS

Usar el prefix documentado:

```css
--login-logo: url("<%=@BASEURL%>__themes__/<Brand>Logo.png");
--login-brand-bg: url("<%=@BASEURL%>__themes__/<Brand>LoginBg.jpg");
```

Thinfinity expande `<%=@BASEURL%>` al servir el CSS. Paths relativos (sin prefix) **no** funcionan confiablemente en todos los contextos.

---

## 4. Crear `custom-themes.json`

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

Notas:
- `productName` aparece como `<title>` del browser.
- `allowBuiltInThemes: false` oculta Light/Dark/Blue built-in del switcher.
- `filename` debe ser path absoluto con backslashes escapados.
- **`favicon` debe ser `.ico`**. SVG no renderiza porque Thinfinity sirve el archivo con MIME `image/x-icon`.
- El campo `themeOverriden` que aparece en la KB es legacy — se puede omitir.

---

## 5. Script de deploy (`apply-refresh.ps1`)

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

# Backup JSON existente con timestamp
if (Test-Path $pfJson) {
    Copy-Item $pfJson "$pfJson.bkp-$(Get-Date -Format 'yyyyMMddHHmmss')" -Force
}

# Sync todos los assets (CSS + imágenes)
New-Item -ItemType Directory -Force -Path $webDst | Out-Null
Get-ChildItem $here -File |
    Where-Object { $_.Extension -in '.css','.svg','.ico','.png','.jpg' } |
    ForEach-Object { Copy-Item $_.FullName (Join-Path $webDst $_.Name) -Force }

# Alias requerido: Thinfinity espera custom-theme.css como endpoint fijo
Copy-Item (Join-Path $here 'customthemes.css') `
          (Join-Path $webDst 'custom-theme.css') -Force

# JSON en ambas ubicaciones (la activa en v8.5 es Program Files)
Copy-Item (Join-Path $here 'custom-themes.json') $pfJson -Force
if (Test-Path (Split-Path $pdJson -Parent)) {
    Copy-Item (Join-Path $here 'custom-themes.json') $pdJson -Force
}

Start-Service ThinfinitySvcMgr
Start-Sleep 3
Read-Host 'Listo. ENTER para cerrar'
```

Wrapper `install.bat`:

```bat
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply-refresh.ps1"
```

---

## 6. Verificar

### En el browser

1. Abrir Thinfinity en **incógnito** (evita caché vieja).
2. **F12 → Network** tab antes de recargar.
3. **Ctrl+Shift+R** para hard refresh.
4. Chequear:
   - Tab title = `<Brand> Workspace` ✓
   - Favicon en la pestaña ✓
   - `custom-theme.css` con status 200 y tamaño razonable.
   - Logo en el panel izquierdo del login.
   - Background image en el panel izquierdo (`--login-brand-bg`).
   - Botón Sign in con color primary.

### En DevTools → Elements

- Seleccionar `<body>` o `<html>`.
- El atributo `class` debe contener `<Brand>Light` o `<Brand>Dark` (no `light-mode`/`dark-mode`).

### Si algo no aparece

| Síntoma | Causa probable | Fix |
|---|---|---|
| Cambios no se ven | Browser cachea CSS | Incógnito o `Ctrl+Shift+R` |
| `custom-theme.css` → 404 | JSON no leído o servicio no reiniciado | Verificar JSON + `Restart-Service ThinfinitySvcMgr` |
| CSS carga pero sin cambios visuales | Clase `.<Brand>Light` no aplicada al body | Verificar `defaultTheme` y `lightMode` en JSON |
| Favicon no aparece | Archivo no es `.ico` real | Generar `.ico` real (no SVG) |
| Login logo OK pero panel izquierdo azul | Faltan vars `--login-brand-bg*` | Agregarlas a ambos temas |
| Dashboard (post-login) sin fondo | `--bg-image` no seteado | Agregarlo a ambos temas |

---

## 7. Correcciones a la KB oficial

Discrepancias encontradas vs. la KB (aplican a v8.5):

1. **Ubicación del JSON**: activa en `Program Files\Thinfinity\Workspace\`, no en `ProgramData\DB`.
2. **Servicio a reiniciar**: `ThinfinitySvcMgr`. No se menciona en la KB.
3. **Variables del login no documentadas**: `--login-brand-bg*`, `--login-form-bg*`, `--login-box-width`.
4. **Scope de `--bg-image`**: solo aplica a `.bg-primary` dentro de `#app` (dashboard), no a `/signin`.
5. **Favicon**: debe ser `.ico`, no SVG.
6. **Campo `themeOverriden`**: legacy, no referenciado por los binarios de v8.
7. **URL del CSS**: `/__themes__/custom-theme.css` (doble underscore al inicio), no `themes__/`.
8. **Mecanismo de carga**: en v8 el app nuevo (`/workspace/`) carga el custom CSS dinámicamente vía `/__base__/config/websettings`, no con `<link>`. El classic app (`/app.html`) sí usa `<link>`.

---

## 8. Rollback

```powershell
# Lista de backups
Get-ChildItem 'C:\Program Files\Thinfinity\Workspace\' -Filter 'custom-themes.json.bkp-*' |
    Sort-Object LastWriteTime -Descending

# Restaurar el último
$last = Get-ChildItem 'C:\Program Files\Thinfinity\Workspace\' -Filter 'custom-themes.json.bkp-*' |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
Copy-Item $last.FullName 'C:\Program Files\Thinfinity\Workspace\custom-themes.json' -Force
Restart-Service ThinfinitySvcMgr
```

O usar el launcher: `uninstall.bat`.
