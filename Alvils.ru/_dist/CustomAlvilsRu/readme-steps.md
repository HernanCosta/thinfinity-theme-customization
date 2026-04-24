# readme-steps — Thinfinity Workspace customization for Alvils

Custom theme for Thinfinity Workspace 8.5 using the branding of **alvils.ru** (pharmaceutical, Moscow).

## Result

- Tab title: `Alvils Workspace`
- Real favicon and logo from alvils.ru
- Login left panel: hero image (blurred teal capsules)
- Login right panel: dark teal with turquoise Sign In button (`#4fcbdf`)
- Theme switcher with two modes: `Alvils (light)` and `Alvils (dark)`

## Project files

| File | Purpose |
|---|---|
| `customthemes.css` | Theme definitions: `.AlvilsLight` and `.AlvilsDark` classes |
| `custom-themes.json` | Thinfinity config (productName, favicon, themes list) |
| `AlvilsFavicon.ico` | Real favicon downloaded from alvils.ru |
| `AlvilsLogo.png` | Real "ALVILS / BRAND MANAGEMENT" wordmark |
| `AlvilsLoginBg.jpg` | Hero image (capsules in dark teal) |
| `apply-refresh.ps1` | Deploy script with UAC self-elevation |
| `install.bat` | Installer launcher |
| `uninstall.bat` | Restores the previous backup |
| `PROMPT-TEMPLATE.md` | Reusable prompt to replicate this for another brand |
| `HOW-TO-CUSTOMIZE.md` | Complete operational guide |

## Installation steps

### 1. Install

Double-click `install.bat` → accept the UAC prompt.

The script will:
1. Stop the `ThinfinitySvcMgr` service.
2. Create a timestamped backup of the current `custom-themes.json`.
3. Copy `customthemes.css` and all assets (`.png`, `.jpg`, `.ico`, `.svg`) into `C:\Program Files\Thinfinity\Workspace\web\__themes__\`.
4. Create an alias `custom-theme.css` (fixed endpoint name expected by Thinfinity).
5. Copy `custom-themes.json` to `C:\Program Files\Thinfinity\Workspace\` and to `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\`.
6. Start the service.

### 2. Verify

1. Open Thinfinity in an **incognito** window (prevents stale cache).
2. Hard refresh with **Ctrl+Shift+R**.
3. Check the `/signin` screen:
   - Tab title reads "Alvils Workspace"
   - Capsule favicon
   - Real logo on the left panel
   - Teal capsules background on the left panel
   - Right panel in dark teal/green
   - Turquoise "Sign In" button

### 3. Uninstall / rollback

Double-click `uninstall.bat` → restores the most recent JSON backup.

## Alvils palette

| Use | Hex |
|---|---|
| Primary (turquoise) | `#4fcbdf` |
| Dark primary / hero bg | `#005a49` |
| Secondary (teal) | `#00b7a8` |
| Dark text | `#003a30` |

## Editing the theme

1. Edit `customthemes.css` in this folder.
2. Run `install.bat` again.
3. Hard refresh the browser.

You never need to edit anything inside `C:\Program Files\Thinfinity\` by hand — the install script syncs everything.

## Important notes (not in the v7 KB)

- The service you must restart is `ThinfinitySvcMgr`, not "Thinfinity Workspace Server".
- The active JSON config lives at `C:\Program Files\Thinfinity\Workspace\custom-themes.json`.
- The login **left panel** (v8+) is controlled by `--login-brand-bg`, not `--bg-image`.
- `--bg-image` only applies to the post-login dashboard (`.bg-primary` inside `#app`), not to `/signin`.
- The favicon must be a real `.ico` file. SVG will not render (Thinfinity forces MIME `image/x-icon`).
- CSS `url()` paths must use the prefix `<%=@BASEURL%>__themes__/<filename>`.

See `HOW-TO-CUSTOMIZE.md` for the complete guide and the full list of corrections to the official KB.

## Reference site

https://www.alvils.ru/ — WordPress, custom theme. Assets downloaded from:
- `wp-content/themes/alvils/favicon.ico`
- `wp-content/themes/alvils/img/logo.png`
- `wp-content/themes/alvils/img/backg_business_resize.jpg`
