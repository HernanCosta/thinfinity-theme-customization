# Entel theme for Thinfinity Workspace — manual install

No installer. Everything lives under **ProgramData**; nothing is copied to
`Program Files`. The `/__themes__/` URL is a virtual alias the server creates
pointing at the folder that contains `customthemes.css`, and the config JSON
is read only from the DB folder (source: `IISServer.Themes.pas` —
`GetSelectedTheme`).

## Install

1. Copy the **`entel`** folder (this whole folder: CSS + SVG/ICO/JPG assets) to:

   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\entel\
   ```

2. Copy **`custom-themes.json`** to the DB folder (one level above):

   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json
   ```

   If a `custom-themes.json` already exists there, back it up first.
   The `filename` field is relative (`entel\customthemes.css`) and resolves
   against the DB folder — no path editing needed.

3. Restart the service:

   ```powershell
   Restart-Service ThinfinitySvcMgr
   ```

4. Open the Workspace URL in the browser and hard-refresh (**Ctrl+Shift+R**),
   or use an incognito window. Check `/signin`: Entel logo, Torre Entel photo
   on the left panel, blue Sign in button, Entel favicon, tab title
   "Entel Workspace".

## Uninstall

1. Delete `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json`
   (or restore your backup).
2. Delete the folder `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\entel\`.
3. `Restart-Service ThinfinitySvcMgr` and hard-refresh the browser.

Nothing else is touched: no files in `Program Files`, no registry changes.

## Contents

| File | Purpose |
|---|---|
| `customthemes.css` | Theme classes `EntelLight` / `EntelDark` (all v8+ variables incl. undocumented `--login-brand-bg*`) |
| `custom-themes.json` | Theme config (goes in the DB folder, not inside `entel\`) |
| `EntelFavicon.ico` | Real favicon from entel.cl |
| `EntelLogo.svg` / `EntelLogoWhite.svg` | Official "e)" symbol, color / negative |
| `EntelLogoMobile*.svg` | Compact mark for mobile header |
| `EntelLoginLogo.svg` | Login box logo |
| `EntelHero.jpg` | Torre Entel photo (login left panel + dashboard background) |

Brand sources: entel.cl production CSS (`#002eff` primary, `#ff3d00` accent),
official symbol SVG from Entel's CDN icon library, favicon from site
`<link rel="icon">`.
