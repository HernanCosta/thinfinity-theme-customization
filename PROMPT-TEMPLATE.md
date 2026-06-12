# Prompt template — Thinfinity Workspace theme from a corporate site

Copy-paste this prompt to Claude replacing `<URL>` and the optional placeholders.

---

I need a theme customization for **Thinfinity Workspace** based on the branding of the corporate site `<URL>`.

**Context:**
- Target install: `C:\Program Files\Thinfinity\Workspace\` (v8+), service `ThinfinitySvcMgr`.
- Official KB (outdated in parts): https://kb.cybelesoft.com/portal/en/kb/articles/new-theme-customization-api-in-thinfinity-workspace
- **Verified server behavior** (source: `dev-main\Units\IISServer\IISServer.Themes.pas`):
  - `custom-themes.json` is read **only** from the DB folder: `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json`. Copies under Program Files are ignored.
  - `/__themes__/` is a **virtual web alias** to the folder containing the CSS referenced by `filename` — no physical folder under `web\` is needed and nothing is ever copied into Program Files.
  - `favicon` resolves relative to the CSS folder; `productName` is injected server-side into `<title><%=@PRODUCTNAME%></title>` — never edit HTML files.
- Only read/write inside the working folder; do not analyze other directories.

**What I want you to do (in this order):**

1. **Extract branding from the site**:
   - Download HTML + CSS with `curl` (real browser User-Agent).
   - Identify: real favicon (`<link rel="icon">`), real logo (`<img>` or `background-image` of `#logo`, `.logo`, `.navbar-brand`), primary palette (most frequent hex codes in CSS), font-family.
   - Download the real files (do not generate them) and rename with the brand prefix.
   - **Image policy: the theme is style-only.** No background images (hero/dashboard/login) unless explicitly requested. The only binaries in the pack are logos and the favicon. The login brand panel uses a CSS gradient built from the primary palette; `--bg-image: none`.
   - **Accessibility**: validate the palette against WCAG 2.1 AA (text ≥ 4.5:1, UI components ≥ 3:1) and document the ratios in the CSS header. For the dark theme follow Material Design dark-theme guidance: near-black surfaces (not #000) and desaturated/lightened primaries (saturated colors fail contrast and "vibrate" on dark surfaces).
   - If I give you a **brand manual / guidelines PDF**, it is authoritative over CSS-extracted colors: take the declared HEX/CMYK values from it.

2. **Create the deliverables (no installer — manual copy)**:
   - `<Brand>\customthemes.css` — classes `.<Brand>Light` and `.<Brand>Dark`
   - `custom-themes.json` — config (see step 4)
   - Favicon `.ico` (convert if the site's isn't ICO; **never SVG as favicon**, Thinfinity serves it with ICO MIME and it won't render)
   - Logos: real PNG/SVG from the site (no placeholders).
   - **Header mirrors the site**: if the site's header/top bar is brand-colored, set `--header-bgcolor` to that color with the white logo variant — don't default to a white header.
   - **`--login-logo` must be the brand's REAL color logo** — never a white/monochrome recolor. If the site only ships a white logo, ask for the color version or recreate the mark as SVG with colors sampled from the official logo. Pick the brand-panel background to complement it: light brand tint behind a color logo, brand gradient behind a white logo.
   - Login logo animation **inside the SVG** (CSS animations in an SVG run even as a `background-image`), matching the logo's geometry — e.g., arcs/orbital elements rotate once around the mark (~1.5s, ease-out). Reserve cartoonish scale-pop for marks with no animatable geometry. Always include `@media (prefers-reduced-motion: reduce)` inside the SVG.
   - Verify rendering with Chrome headless screenshots (`Start-Process chrome --headless --screenshot ... -Wait`; add `--force-prefers-reduced-motion` to capture the animation's resting state).
   - `README.md` with the manual install/uninstall steps (below). **No install.bat / apply-refresh.ps1 / service scripts.**

3. **CSS must cover all variables (including those NOT in the KB)**:
   - Core: `--primary-color`, `--dark-primary-color`, `--light-primary-color`, `--secondary-color`, `--tertiary-color`
   - Backgrounds: `--primary-bgcolor`, `--secondary-bgcolor`, `--tertiary-bgcolor`, `--hover-bgcolor`, `--header-bgcolor`, `--toolbar-bgcolor`, `--sidepanel-bgcolor`, `--sidepanel-header-bgcolor`, `--menu-bgcolor`, `--dialog-bgcolor`, `--submenu-bgcolor`, `--table-header-bgcolor`, `--table-body-bgcolor`, `--table-body-bgcolor-h`, `--<ClassName>-entity-bg`
   - Buttons: `--button-bgcolor`, `--button-txtcolor`, `--button-bgcolor-h`, `--button-txtcolor-h`, `--outline-button-color`, `--outline-button-bgcolor-h`, `--outline-button-color-h`, `--special-button`, `--switcher-button`
   - Links/menu: `--link-color`, `--link-color-h`, `--menu-selected-color`, `--menu-selected-bgcolor`
   - Text: `--primary-txtcolor`, `--secondary-txtcolor`, `--heading-color`
   - Borders: `--border-color`, `--light-border-color`, `--separator`
   - Status: `--disabled`, `--danger`, `--alert`, `--allowed`, `--shadow-color`
   - Background (dashboard): `--bg-image: none`, `--bg-size`, `--bg-blend-mode`
   - Logos: `--desktop-logo`, `--mobile-logo`, `--login-logo`, `--logo-bg-size`
   - **Login panel (not in the KB, applies to `/signin` v8+)**: `--login-brand-bg` (CSS gradient), `--login-brand-bg-size`, `--login-brand-bg-repeat`, `--login-brand-bg-position-x`, `--login-brand-bg-position-y`, `--login-brand-bg-blend-mode`, `--login-form-bg` (+ modifiers), `--login-box-width`
   - Asset URLs use the prefix `url("<%=@BASEURL%>__themes__/<file>")`.

4. **JSON config** must include:
   ```json
   {
     "filename": "C:\\ProgramData\\Cybele Software\\Thinfinity\\Workspace\\DB\\<Brand>\\customthemes.css",
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
   `productName` becomes the browser tab title (server-side token replacement — no HTML edits).

5. **No generic placeholders** (circle with a letter) if the site has real assets. Download the original PNG/SVG/ICO.

6. **Package as `.zip`** named `<Brand>-Thinfinity-Theme.zip`, mirroring the install destination:
   ```
   README.md               <- manual steps
   custom-themes.json      <- goes to ...\Workspace\DB\
   <Brand>\                <- goes to ...\Workspace\DB\<Brand>\  (css + svg + ico)
   ```
   Exclude `_scratch\`, `.git\`, temp files. Report final path and size.

7. **README.md install steps** (the only "installer"):
   1. Copy `<Brand>\` to `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\<Brand>\`
   2. Copy `custom-themes.json` to `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\` (back up any existing one)
   3. `Restart-Service ThinfinitySvcMgr`
   4. Hard-refresh (`Ctrl+Shift+R`) or incognito; verify `/signin`: logo pop animation over gradient panel, brand button color, favicon, tab title.

   Uninstall = delete the JSON + the `<Brand>\` folder, restart service. Nothing in Program Files, no registry.

**Optional context I can give you:**
- Company: `<name + industry>`
- Preferred login tagline: `<text>`
- Force a single theme (no switcher): `allowUsersToSwitchTheme: false`
- Keep built-in themes available too: `allowBuiltInThemes: true`
- Background images (hero/dashboard): only if I explicitly provide/request them here.

---
