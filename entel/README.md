# Entel theme for Thinfinity Workspace — manual install

No installer. Everything lives under **ProgramData**; nothing is copied to
`Program Files`. The `/__themes__/` URL is a virtual alias the server creates
pointing at the folder that contains `customthemes.css`, and the config JSON
is read only from the DB folder (source: `IISServer.Themes.pas` —
`GetSelectedTheme`).

## Install

1. Copy the **`Entel`** folder (CSS + SVG/ICO/JPG assets) to:

   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\Entel\
   ```

2. Copy **`custom-themes.json`** to the DB folder (one level above):

   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json
   ```

   If a `custom-themes.json` already exists there, back it up first.
   The `filename` field already points to
   `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\Entel\customthemes.css` —
   if you copy the files exactly as above, no editing is needed.

3. Restart the service:

   ```powershell
   Restart-Service ThinfinitySvcMgr
   ```

4. Open the Workspace URL in the browser and hard-refresh (**Ctrl+Shift+R**),
   or use an incognito window. Check `/signin`: white Entel logo popping in
   over the blue gradient panel, blue Sign in button, Entel favicon, tab
   title "Entel Workspace", and the page footer reading
   "Entel Workspace v<version>" instead of "Thinfinity Workspace".
   The `productName` field in `custom-themes.json` drives the tab title
   AND both footers (sign-in page and post-login) — no file edits. If the
   footer still says "Thinfinity Workspace" after a hard refresh, the
   theme JSON is not being read: re-check step 2's path and restart the
   service again.

## Uninstall

1. Delete `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json`
   (or restore your backup).
2. Delete the folder `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\Entel\`.
3. `Restart-Service ThinfinitySvcMgr` and hard-refresh the browser.

Nothing else is touched: no files in `Program Files`, no registry changes.

## Contents

| File | Purpose |
|---|---|
| `customthemes.css` | Theme classes `EntelLight` / `EntelDark` (all v8+ variables incl. undocumented `--login-brand-bg*`), login logo entrance animation |
| `custom-themes.json` | Theme config (goes in the DB folder, not inside `Entel\`) |
| `EntelFavicon.ico` | Real favicon from entel.cl |
| `EntelLogo.svg` / `EntelLogoWhite.svg` | Official "e)" symbol, color / negative |
| `EntelLogoMobile*.svg` | Compact mark for mobile header |
| `EntelLoginLogo.svg` | Login brand-panel logo (white variant, sits on the blue gradient) |

Style-only theme: no background images are shipped. The login brand panel
uses a CSS gradient in Entel blues; the dashboard background is a flat
brand surface. The login logo animates in (scale-up pop) and respects
`prefers-reduced-motion`.

Brand sources: entel.cl production CSS (`#002eff` primary, `#ff3d00` accent),
official symbol SVG from Entel's CDN icon library, favicon from site
`<link rel="icon">`. Contrast validated against WCAG 2.1 AA (ratios
documented in `customthemes.css`); dark surfaces follow Material Design
dark-theme guidance (near-black, desaturated primaries).
