# ACA Coop theme for Thinfinity Workspace — manual install

No installer. Everything lives under **ProgramData**; nothing is copied to
`Program Files`. The `/__themes__/` URL is a virtual alias the server
creates pointing at the folder that contains `customthemes.css`, and the
config JSON is read only from the DB folder.

## Install

1. Copy the **`AcaCoop`** folder (CSS + PNG/ICO assets) to:

   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\AcaCoop\
   ```

2. Copy **`custom-themes.json`** to the DB folder (one level above):

   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json
   ```

   If a `custom-themes.json` already exists there, back it up first.
   The `filename` field already points to
   `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\AcaCoop\customthemes.css` —
   if you copy the files exactly as above, no editing is needed.

3. Restart the service:

   ```powershell
   Restart-Service ThinfinitySvcMgr
   ```

4. Open the Workspace URL and hard-refresh (**Ctrl+Shift+R**), or use an
   incognito window. Check `/signin`: color ACA mark on the light brand
   panel with the orange/blue arcs orbiting the letters once, indigo
   Sign in button, ACA favicon, tab title "ACA Coop Workspace". After
   login the header bar is brand indigo with the white logo, like the
   site.

## Uninstall

1. Delete `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json`
   (or restore your backup).
2. Delete the folder `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\AcaCoop\`.
3. `Restart-Service ThinfinitySvcMgr` and hard-refresh the browser.

Nothing else is touched: no files in `Program Files`, no registry changes.

## Contents

| File | Purpose |
|---|---|
| `customthemes.css` | Theme classes `AcaCoopLight` / `AcaCoopDark` (all v8+ variables incl. undocumented `--login-brand-bg*`) |
| `custom-themes.json` | Theme config (goes in the DB folder, not inside `AcaCoop\`) |
| `AcaCoopFavicon.ico` | Real favicon from acacoop.com.ar (16/32px multi-icon) |
| `AcaCoopLogoWhite.png` | Original white wordmark from the site — on the indigo header, like the site |
| `AcaCoopLogoMobileWhite.png` | Same mark for the mobile header |
| `AcaCoopLoginLogo.svg` | Vector recreation of the official color mark (blue `#2b3b89` / orange `#f5951d`); the arcs orbit the letters once on load, `prefers-reduced-motion` aware |

Style-only theme: no background images are shipped. The header bar is
brand indigo with the white logo (matching acacoop.com.ar); the login
brand panel is a light indigo-tinted gradient so the color mark reads;
the dashboard background is a flat brand surface.

Brand sources: acacoop.com.ar inline styles + `hello.css` overrides
(`#282c87` indigo, `#ff9100` orange — the teal in `style.css` is the stock
template default, not brand), white wordmark PNG and favicon from the
site, color-mark palette sampled from the official logo. Contrast
validated against WCAG 2.1 AA (ratios documented in `customthemes.css`);
dark surfaces follow Material Design dark-theme guidance (near-black,
desaturated primaries).
