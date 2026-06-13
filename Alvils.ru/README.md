# Alvils theme for Thinfinity Workspace — manual install

No installer. Everything lives under **ProgramData**; nothing is copied to
`Program Files`, no HTML files are modified.

> Rebuilt to the full perk standard (style-only). The old hero-image /
> installer-script version is superseded; ignore the legacy `apply-*.ps1`,
> `install*.bat`, `_dist\` files in this folder.

## Install

1. Copy the **`Alvils`** folder (CSS + logo SVGs + favicon) to:
   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\Alvils\
   ```
2. Copy **`custom-themes.json`** to the DB folder (back up any existing one):
   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json
   ```
3. `Restart-Service ThinfinitySvcMgr`
4. Hard-refresh / incognito. Check `/signin`: white Alvils logo popping in
   over the teal gradient panel, teal Sign in button, boxed inputs, favicon,
   tab title "Alvils Workspace". After login: pill buttons / nav / menus,
   teal toggles, circular close-X, footer "Alvils Workspace v<version>.
   Powered by Cybele Software".

## Uninstall

Delete `...\DB\custom-themes.json` (or restore your backup) and the
`...\DB\Alvils\` folder, then `Restart-Service ThinfinitySvcMgr`.

## Contents

| File | Purpose |
|---|---|
| `customthemes.css` | Theme classes `AlvilsLight` / `AlvilsDark` + the full perk set |
| `custom-themes.json` | Theme config (goes in the DB folder, not inside `Alvils\`) |
| `AlvilsFavicon.ico` | Favicon |
| `AlvilsLogo.svg` / `AlvilsLogoWhite.svg` | Logo, colored (light header) / white (dark) |
| `AlvilsLogoMobile.svg` / `AlvilsLogoMobileWhite.svg` | Mobile header marks |
| `AlvilsLoginLogo.svg` / `AlvilsLoginLogoWhite.svg` | Login logo, colored (narrow white form) / white (brand panel + dark form) |

Full perk set: pill buttons, pill nav/menu/dropdown items, brand-teal
toggles, circular close-X, graceful overlay+press motion, SSO hover/click,
refined login (boxed inputs, native font), "Powered by Cybele Software"
footer. Style-only: no background images (teal CSS gradient login panel).
Contrast validated against WCAG 2.1 AA; dark surfaces use the brand's deep-
teal ramp per Material dark-theme guidance.
