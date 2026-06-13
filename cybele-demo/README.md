# Cybele Software — DEMO theme (switchable, no favicon/title change)

A sales-demo variant of the Cybele theme. It opens as **stock Thinfinity
Workspace** and lets you switch **to** "Cybele Software" and back, from the web
interface — to showcase customization possibilities live.

**Difference from the full `cybele` pack:** this one intentionally **does NOT
set the favicon or the browser tab title** (those fields are omitted from the
JSON), so the tab icon and title stay "Thinfinity Workspace" the whole time.
The full `cybele` pack rebrands those too.

## What switches live (UI Settings → Theme), and what doesn't

| Element | On switch to "Cybele Software" | Back to built-in |
|---|---|---|
| Colors / pills / rounded UI | ✅ Cybele | ✅ stock |
| Logos in header / side menu / login | ✅ Cybele | ✅ stock |
| Footer "Powered by Cybele Software" | ✅ shows | ✅ reverts |
| **Favicon (tab icon)** | ❌ stays Thinfinity | — (never changes) |
| **Tab title** | ❌ stays Thinfinity | — (never changes) |

The favicon and title are resolved by the server **once at page load** and are
not reactive to the in-app switcher — that's why a demo pack simply leaves them
as stock Thinfinity. Switching colors/logos/footer is instant (CSS class swap).

## Install

1. Copy the **`CybeleDemo`** folder (CSS + logo SVGs) to:
   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\CybeleDemo\
   ```
2. Copy **`custom-themes.json`** to the DB folder (back up any existing one):
   ```
   C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\custom-themes.json
   ```
3. `Restart-Service ThinfinitySvcMgr`
4. Open the Workspace, hard-refresh / incognito. It loads as **stock
   Thinfinity**. Go to **Settings → UI Settings → Theme** and pick **"Cybele
   Software (light)"** to show the customization; pick a built-in option (Light/
   Dark) to go back. The tab icon + title stay "Thinfinity Workspace" throughout.

## Uninstall

Delete `...\DB\custom-themes.json` (or restore your backup) and the
`...\DB\CybeleDemo\` folder, then `Restart-Service ThinfinitySvcMgr`.

## Notes

- `allowBuiltInThemes: true` + default `light-mode` is what makes it start on
  stock Thinfinity and offer both Cybele and built-in themes in the switcher.
- The theme CSS is identical to the full `cybele` pack (same `CybeleLight` /
  `CybeleDark` classes and perks); only the JSON differs.
- Powered by Cybele Software.
