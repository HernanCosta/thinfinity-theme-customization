# Cybele Software theme for Thinfinity Workspace — manual install

No installer. Everything lives under **ProgramData**; nothing is copied to
`Program Files`, no HTML files are modified. The `/__themes__/` URL is a
virtual alias the server creates pointing at the folder that contains
`customthemes.css`, and the config JSON is read only from the DB folder.

## Install

1. Copy the **`Cybele`** folder (CSS + SVG/ICO assets) to:

   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\Cybele\
   ```

2. Copy **`custom-themes.json`** to the DB folder (one level above):

   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json
   ```

   If a `custom-themes.json` already exists there, back it up first.
   The `filename` field already points to
   `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\Cybele\customthemes.css` —
   if you copy the files exactly as above, no editing is needed.

3. Restart the service:

   ```powershell
   Restart-Service ThinfinitySvcMgr
   ```

4. Open the Workspace URL and hard-refresh (**Ctrl+Shift+R**), or use an
   incognito window. Check `/signin`: Cybele logo (white + multicolor
   mark) popping in over the navy gradient panel, blue Sign in button,
   Cybele favicon, tab title "Cybele Software Workspace", footer reading
   "Cybele Software Workspace v<version>". Narrow the window until the
   brand panel collapses: the top logo should show the full dark
   wordmark on white (not just the butterfly). After login: dark navy
   solid header with the negative logo; settings menu, side nav and
   avatar dropdown items are pill buttons (idle transparent, filled on
   hover/active); close "X" buttons are circular on hover.

## Uninstall

1. Delete `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json`
   (or restore your backup).
2. Delete the folder `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\Cybele\`.
3. `Restart-Service ThinfinitySvcMgr` and hard-refresh the browser.

Nothing else is touched: no files in `Program Files`, no registry changes.

## Contents

| File | Purpose |
|---|---|
| `customthemes.css` | Theme classes `CybeleLight` / `CybeleDark` (all v8+ variables incl. undocumented `--login-brand-bg*`), pill header/buttons, logo pop animation |
| `custom-themes.json` | Theme config (goes in the DB folder, not inside `Cybele\`) |
| `CybeleFavicon.ico` | Real favicon from cybelesoft.com |
| `CybeleLogoWhite.svg` | Official negative logo (white wordmark + multicolor butterfly mark) — header / dark surfaces |
| `CybeleLogoPositive.svg` | Official positive logo (dark wordmark) — used by the narrow/mobile login header on the white form so the wordmark stays visible |
| `CybeleLogoMobileWhite.svg` | Same mark for the mobile header |
| `CybeleLoginLogo.svg` | Login brand-panel logo (official negative SVG) |

Style-only theme: no background images, no HTML edits. The header is the
site's dark navy as a **floating pill** (rounded bar with margins, like
cybelesoft.com's nav), buttons are pill-shaped, the login brand panel is
a navy gradient, and the login logo pops in (`prefers-reduced-motion`
aware).

Brand sources: cybelesoft.com design tokens (`--blue-cybele-*`,
`--water-green-*` in the site's entry.css), official logo SVGs
(`/img/logos/cybele-negative-logo.svg`), favicon from the site root.
Contrast validated against WCAG 2.1 AA (ratios documented in
`customthemes.css`) — note the site's own CTA blue `#0b84f4` fails AA on
white (3.7:1), so AA-safe `#085dac` carries text/buttons on light
surfaces; dark surfaces use the brand's navy ramp per Material dark-theme
guidance.
