# Thinfinity Workspace — Theme Customization

Branded theme packs for **Thinfinity Workspace (v8+)**. Each pack takes a
company's public branding and turns it into a drop-in customization that
rebrands the Workspace *and* applies a consistent set of modern UI
enhancements over the stock look.

The work is driven by the **`thinfinity-theme-customization`** skill, which is
the authoritative playbook (process, exact selectors, validation method) and
ships a ready-to-fill template. This repo holds the produced packs.

## What a pack does

A pack is **style-only and installer-free**: a CSS file + logo/favicon assets +
a config JSON, copied into one folder under `ProgramData`. It touches nothing in
`Program Files`, edits no HTML, and is removed by deleting two items. Light and
dark themes are switchable from the Workspace UI.

### Rebranding
- Brand **palette** in light and dark themes (WCAG 2.1 AA validated).
- The company's **real logos** (header, side menu, login, mobile) and **favicon**.
- **Product name** in the browser tab title and the footer.
- A **branded login screen**: a CSS-gradient brand panel in the company colors.

### UI enhancements (applied to every pack)
1. **Pill buttons** — all buttons fully rounded.
2. **Pill nav & menu items** — settings menu, left side nav, and avatar/top
   dropdown render as rounded pills (idle transparent, filled on hover/active).
3. **Circular close "X"** — side-menu and dialog/panel close icons become
   circular hover chips; the stock navy close bar is removed.
4. **Brand-colored toggles** — the on/off switch uses the brand color, not the
   built-in green.
5. **Smooth menu motion** — menus open with a clean slide-and-fade; the settings
   accordion expands the same way; buttons give a small press response.
6. **SSO micro-interactions** — provider buttons grow on hover/focus and give a
   gentle bounce on click.
7. **Animated, responsive login logo** — the logo animates in and stays a full
   wordmark when the window is narrow.
8. **Refined login form** — cleaner heading, boxed inputs, native font.
9. **Header-icon contrast** — header icons pinned to read on the branded header.
10. **"Powered by Cybele Software" footer.**

All motion respects `prefers-reduced-motion`.

## Install a pack

Each pack folder ships a `<Brand>-Thinfinity-Theme.zip` and a `README.md` with
the exact steps. In short:

1. Copy the `<Brand>\` folder to
   `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\<Brand>\`.
2. Copy `custom-themes.json` to
   `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\` (back up any
   existing one first).
3. `Restart-Service ThinfinitySvcMgr`, then hard-refresh the browser
   (Ctrl+Shift+R) or use an incognito window.

Uninstall = delete that JSON and the `<Brand>\` folder, then restart the
service.

## Packs in this repo

| Folder | Brand | Notes |
|---|---|---|
| `cybele` | Cybele Software | Reference build (dark-navy header) |
| `cybele-demo` | Cybele Software | Switchable demo variant — leaves the tab icon/title stock so sales can toggle the theme on/off live |
| `entel` | Entel | White header |
| `acacoop` | ACA Coop | Indigo header, color-lockup login |
| `Alvils.ru` | Alvils | Teal |
| `vistaenergy` | Vista Energy | Violet |

`PROMPT-TEMPLATE.md` is a short copy-paste brief for generating a new pack; the
skill is the full playbook.

## Creating a new pack

Give the skill a company's site URL (and any brand assets). It extracts the
palette + logos, fills the template, validates the result against the real
Workspace UI, and produces the installable zip. See `PROMPT-TEMPLATE.md`.
