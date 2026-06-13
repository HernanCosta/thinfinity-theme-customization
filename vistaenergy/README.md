# Vista Energy theme for Thinfinity Workspace — manual install

No installer. Everything lives under **ProgramData**; nothing is copied to
`Program Files`, no HTML files are modified.

> Rebuilt to the full perk standard (style-only). The old hero-image /
> installer-script version is superseded; ignore the legacy `apply-*.ps1`,
> `install*.bat`, `_scratch\` files in this folder.

## Install

1. Copy the **`Vista`** folder (CSS + logo SVGs + favicon) to:
   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\Vista\
   ```
2. Copy **`custom-themes.json`** to the DB folder (back up any existing one):
   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json
   ```
3. `Restart-Service ThinfinitySvcMgr`
4. Hard-refresh / incognito. Check `/signin`: white Vista logo over the violet
   gradient panel, violet Sign in button, boxed inputs, favicon, tab title
   "Vista Energy Workspace". After login: pill buttons / nav / menus, violet
   toggles, circular close-X, footer "Vista Energy Workspace v<version>.
   Powered by Cybele Software".

## Uninstall

Delete `...\DB\custom-themes.json` (or restore your backup) and the
`...\DB\Vista\` folder, then `Restart-Service ThinfinitySvcMgr`.

## Contents

| File | Purpose |
|---|---|
| `customthemes.css` | Theme classes `VistaLight` / `VistaDark` + the full perk set |
| `custom-themes.json` | Theme config (goes in the DB folder, not inside `Vista\`) |
| `VistaFavicon.ico` | Favicon |
| `VistaLogo.svg` / `VistaLogoWhite.svg` | Logo, colored (light header) / white (dark + login panel) |
| `VistaLogoMobile.svg` / `VistaLogoMobileWhite.svg` | Mobile header marks |
| `VistaLoginLogo.svg` | Login lockup (kept for reference) |

Full perk set: pill buttons, pill nav/menu/dropdown items, brand-violet
toggles, circular close-X, smooth menu slide + SSO hover/click, header-icon
contrast fix, refined login (boxed inputs, native font), "Powered by Cybele
Software" footer. Style-only: no background images (violet CSS gradient login
panel). Contrast validated against WCAG 2.1 AA; dark surfaces use Vista's
deep-indigo ramp per Material dark-theme guidance.
