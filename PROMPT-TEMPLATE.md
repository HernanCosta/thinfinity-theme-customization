# Prompt template — Thinfinity Workspace theme from a corporate site

Copy-paste este prompt a Claude reemplazando `<URL>` y los placeholders opcionales.

---

Necesito crear una customización de tema para **Thinfinity Workspace** basada en el branding del site corporativo `<URL>`.

**Contexto:**
- Tengo Thinfinity Workspace instalado localmente en `C:\Program Files\Thinfinity\Workspace\`.
- Referencia oficial (obsoleta en partes): https://kb.cybelesoft.com/portal/en/kb/articles/new-theme-customization-api-in-thinfinity-workspace
- Versión: <correr `(Get-Item "C:\Program Files\Thinfinity\Workspace\bin64\Thinfinity.VirtualUI.Server.exe").VersionInfo.ProductVersion` y pegar aquí>
- Servicio: `ThinfinitySvcMgr` (v8+).

**Lo que quiero que hagas (en este orden):**

1. **Extraer branding del site**:
   - Descargar HTML + CSS del site usando `curl` (User-Agent de browser real).
   - Identificar: favicon real (`<link rel="icon">`), logo real (`<img>` o `background-image` del `#logo`, `.logo`, `.navbar-brand`), paleta primaria (hex codes más frecuentes en CSS), font-family.
   - Descargar los archivos reales (no generarlos) y renombrarlos con prefix de marca.
   - **Política de imágenes: el tema es solo estilo.** No incluir imágenes de fondo (hero/dashboard/login) salvo que se pida explícitamente. Los únicos binarios del pack son logos y favicon. El panel de marca del login usa un gradiente CSS con los colores primarios; `--bg-image: none`.
   - **Accesibilidad**: validar la paleta contra WCAG 2.1 AA (texto ≥ 4.5:1, componentes UI ≥ 3:1) y documentar los ratios en el CSS. Para el tema dark seguir Material Design dark theme: superficies near-black (no #000) y primarios desaturados/aclarados (los saturados fallan contraste y "vibran" sobre fondos oscuros).

2. **Crear los assets en `C:\customization\<BrandName>\`**:
   - `customthemes.css` — clases `.<Brand>Light` y `.<Brand>Dark`
   - `custom-themes.json` — config apuntando al CSS
   - Favicon `.ico` (si el del site no es ICO, convertirlo o generar uno con PowerShell GDI+; **no usar SVG como favicon**, Thinfinity lo sirve con MIME ICO y no renderiza)
   - Logos: PNG/SVG reales del site (no placeholders). El `--login-logo` va sobre el panel de marca (gradiente de color primario): usar la **versión negativa/blanca** del logo ahí.
   - `--login-brand-bg`: gradiente CSS con la paleta de la marca (NO imagen, salvo pedido explícito)
   - Animación de entrada del logo del login (`#customized-logo .logo-img`): scale-up con overshoot, scoped a las clases del tema, con `@media (prefers-reduced-motion: reduce)` para deshabilitarla
   - `apply-refresh.ps1` con self-elevation UAC que: detiene `ThinfinitySvcMgr`, sincroniza assets a `C:\Program Files\Thinfinity\Workspace\web\__themes__\` (copia todos los .css/.svg/.png/.jpg/.ico + alias `custom-theme.css`), copia el JSON a `C:\Program Files\Thinfinity\Workspace\custom-themes.json` y a `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json`, arranca el servicio.
   - `install.bat` y `uninstall.bat` launchers.

3. **CSS debe cubrir todas las variables (incluyendo las que NO están en la KB)**:
   - Core: `--primary-color`, `--dark-primary-color`, `--light-primary-color`, `--secondary-color`, `--tertiary-color`
   - Backgrounds: `--primary-bgcolor`, `--secondary-bgcolor`, `--tertiary-bgcolor`, `--hover-bgcolor`, `--header-bgcolor`, `--toolbar-bgcolor`, `--sidepanel-bgcolor`, `--sidepanel-header-bgcolor`, `--menu-bgcolor`, `--dialog-bgcolor`, `--submenu-bgcolor`, `--table-header-bgcolor`, `--table-body-bgcolor`, `--table-body-bgcolor-h`, `--<ClassName>-entity-bg`
   - Buttons: `--button-bgcolor`, `--button-txtcolor`, `--button-bgcolor-h`, `--button-txtcolor-h`, `--outline-button-color`, `--outline-button-bgcolor-h`, `--outline-button-color-h`, `--special-button`, `--switcher-button`
   - Links/menu: `--link-color`, `--link-color-h`, `--menu-selected-color`, `--menu-selected-bgcolor`
   - Text: `--primary-txtcolor`, `--secondary-txtcolor`, `--heading-color`
   - Borders: `--border-color`, `--light-border-color`, `--separator`
   - Status: `--disabled`, `--danger`, `--alert`, `--allowed`, `--shadow-color`
   - Background (dashboard): `--bg-image`, `--bg-size`, `--bg-blend-mode`
   - Logos: `--desktop-logo`, `--mobile-logo`, `--login-logo`, `--logo-bg-size`
   - **Login panel (no documentado en KB, aplica al `/signin` de v8+)**: `--login-brand-bg`, `--login-brand-bg-size`, `--login-brand-bg-repeat`, `--login-brand-bg-position-x`, `--login-brand-bg-position-y`, `--login-brand-bg-blend-mode`, `--login-form-bg` (+ modificadores), `--login-box-width`
   - URLs con el prefix `url("<%=@BASEURL%>__themes__/<archivo>")`.

4. **JSON config** debe incluir:
   ```json
   {
     "filename": "C:\\customization\\<BrandName>\\customthemes.css",
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

5. **No creés placeholders genéricos** (círculo con letra) si el site tiene los assets reales. Bajá los PNG/SVG/ICO originales.

6. **No asumas** que las rutas de la KB son correctas en v8: antes de escribir el JSON, verificá dónde existe el archivo activo (`Test-Path "C:\Program Files\Thinfinity\Workspace\custom-themes.json"` y `...ProgramData\DB\...`).

7. **Al terminar**, corré el `apply-refresh.ps1` y pedime un hard-refresh (Ctrl+Shift+R) para validar. Si algo no aparece, pedí captura de `/signin` y los headers/response de `custom-theme.css` en DevTools → Network.

8. **Empaquetar el theme pack como `.zip`** en `C:\customization\<BrandName>-Thinfinity-Theme.zip`:
   - Incluir todo el contenido de `C:\customization\<BrandName>\` **excepto** carpetas auxiliares tipo `_scratch\`, `.git\`, `node_modules\` o archivos temporales.
   - Debe incluir: `customthemes.css`, `custom-themes.json`, todos los assets (`.ico`, `.svg`, `.png`, `.jpg`), `apply-refresh.ps1`, `install.bat`, `uninstall.bat`, `uninstall.ps1`.
   - Usar `Compress-Archive -Path ... -DestinationPath ... -Force` desde PowerShell. Si ya existe un `.zip` previo con ese nombre, sobrescribirlo.
   - Reportar el path final y el tamaño del `.zip` generado para confirmar.

**Contexto opcional que puedo darte:**
- Empresa: `<nombre + industria>`
- Tagline/slogan preferido para el login: `<texto>`
- Si querés forzar solo un tema (no dejar switcher): `allowUsersToSwitchTheme: false`
- Si querés mantener los built-in disponibles además del custom: `allowBuiltInThemes: true`

---
