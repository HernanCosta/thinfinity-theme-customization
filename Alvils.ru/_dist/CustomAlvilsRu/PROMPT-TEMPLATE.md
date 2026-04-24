# Prompt template — Thinfinity Workspace theme from a corporate site

Copy-paste this prompt into Claude, replacing `<URL>` and the optional placeholders.

---

I need to create a **Thinfinity Workspace** theme customization based on the branding of the corporate site `<URL>`.

**Context:**
- I have Thinfinity Workspace installed locally at `C:\Program Files\Thinfinity\Workspace\`.
- Official reference (partially outdated): https://kb.cybelesoft.com/portal/en/kb/articles/new-theme-customization-api-in-thinfinity-workspace
- Version: <run `(Get-Item "C:\Program Files\Thinfinity\Workspace\bin64\Thinfinity.VirtualUI.Server.exe").VersionInfo.ProductVersion` and paste here>
- Service: `ThinfinitySvcMgr` (v8+).

**What I need you to do (in this order):**

1. **Extract branding from the site**:
   - Download HTML + CSS from the site using `curl` (with a real browser User-Agent).
   - Identify: real favicon (`<link rel="icon">`), real logo (`<img>` or `background-image` on `#logo`, `.logo`, `.navbar-brand`), primary palette (most frequent hex codes in the CSS), font-family, and a representative hero/login background image.
   - Download the real files (do not generate them) and rename them with a brand prefix.

2. **Create the assets in `C:\customization\<BrandName>\`**:
   - `customthemes.css` — `.<Brand>Light` and `.<Brand>Dark` classes
   - `custom-themes.json` — config pointing to the CSS
   - Favicon `.ico` (if the site's favicon isn't ICO, convert it or generate one with PowerShell GDI+; **do not use SVG as favicon**, Thinfinity serves it with MIME ICO and it won't render)
   - Logos: real PNG files from the site (not placeholders)
   - Hero image for `--login-brand-bg`
   - `apply-refresh.ps1` with UAC self-elevation that: stops `ThinfinitySvcMgr`, syncs assets to `C:\Program Files\Thinfinity\Workspace\web\__themes__\` (copying every .css/.svg/.png/.jpg/.ico + `custom-theme.css` alias), copies the JSON to `C:\Program Files\Thinfinity\Workspace\custom-themes.json` and to `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json`, then starts the service.
   - `install.bat` and `uninstall.bat` launchers.

3. **CSS must cover every variable (including those NOT in the KB)**:
   - Core: `--primary-color`, `--dark-primary-color`, `--light-primary-color`, `--secondary-color`, `--tertiary-color`
   - Backgrounds: `--primary-bgcolor`, `--secondary-bgcolor`, `--tertiary-bgcolor`, `--hover-bgcolor`, `--header-bgcolor`, `--toolbar-bgcolor`, `--sidepanel-bgcolor`, `--sidepanel-header-bgcolor`, `--menu-bgcolor`, `--dialog-bgcolor`, `--submenu-bgcolor`, `--table-header-bgcolor`, `--table-body-bgcolor`, `--table-body-bgcolor-h`, `--<ClassName>-entity-bg`
   - Buttons: `--button-bgcolor`, `--button-txtcolor`, `--button-bgcolor-h`, `--button-txtcolor-h`, `--outline-button-color`, `--outline-button-bgcolor-h`, `--outline-button-color-h`, `--special-button`, `--switcher-button`
   - Links/menu: `--link-color`, `--link-color-h`, `--menu-selected-color`, `--menu-selected-bgcolor`
   - Text: `--primary-txtcolor`, `--secondary-txtcolor`, `--heading-color`
   - Borders: `--border-color`, `--light-border-color`, `--separator`
   - Status: `--disabled`, `--danger`, `--alert`, `--allowed`, `--shadow-color`
   - Background (dashboard): `--bg-image`, `--bg-size`, `--bg-blend-mode`
   - Logos: `--desktop-logo`, `--mobile-logo`, `--login-logo`, `--logo-bg-size`
   - **Login panel (not in the KB, applies to `/signin` in v8+)**: `--login-brand-bg`, `--login-brand-bg-size`, `--login-brand-bg-repeat`, `--login-brand-bg-position-x`, `--login-brand-bg-position-y`, `--login-brand-bg-blend-mode`, `--login-form-bg` (+ modifiers), `--login-box-width`
   - URLs with the prefix `url("<%=@BASEURL%>__themes__/<file>")`.

4. **JSON config** must include:
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

5. **Do not create generic placeholders** (circle-with-letter logos) if the site has real assets. Download the original PNG/SVG/ICO files.

6. **Do not assume** the KB paths are correct on v8: before writing the JSON, verify where the active file exists (`Test-Path "C:\Program Files\Thinfinity\Workspace\custom-themes.json"` and `...ProgramData\DB\...`).

7. **When done**, run `apply-refresh.ps1` and ask me for a hard refresh (Ctrl+Shift+R) to validate. If something is missing, ask for a screenshot of `/signin` and the headers/response of `custom-theme.css` in DevTools → Network.

**Optional context I can give you:**
- Company: `<name + industry>`
- Preferred login tagline/slogan: `<text>`
- If you want to force a single theme (no switcher): `allowUsersToSwitchTheme: false`
- If you want to keep the built-in themes available alongside the custom ones: `allowBuiltInThemes: true`

---
