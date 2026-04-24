# readme-steps — Customización Thinfinity Workspace para Alvils

Tema personalizado para Thinfinity Workspace 8.5 con el branding de **alvils.ru** (farmacéutica, Moscú).

## Resultado

- Tab title: `Alvils Workspace`
- Favicon y logo reales de alvils.ru
- Panel izquierdo del login con imagen hero de pastillas teal
- Panel derecho teal oscuro con botón turquesa (`#4fcbdf`)
- Switcher con dos modos: `Alvils (light)` y `Alvils (dark)`

## Archivos del proyecto

| Archivo | Propósito |
|---|---|
| `customthemes.css` | Definición de los temas `.AlvilsLight` y `.AlvilsDark` |
| `custom-themes.json` | Config de Thinfinity (productName, favicon, themes) |
| `AlvilsFavicon.ico` | Favicon real descargado de alvils.ru |
| `AlvilsLogo.png` | Logo "ALVILS / BRAND MANAGEMENT" real |
| `AlvilsLoginBg.jpg` | Imagen hero (cápsulas en teal oscuro) |
| `apply-refresh.ps1` | Script de deploy con self-elevation UAC |
| `install.bat` / `install-v2.bat` | Launchers |
| `uninstall.bat` | Restaura el backup previo |
| `custom-themes.json.original-bkp` | JSON stub que venía con Thinfinity |
| `PROMPT-TEMPLATE.md` | Prompt para replicar en otra marca |
| `HOW-TO-CUSTOMIZE.md` | Guía operativa completa |

## Pasos de instalación

### 1. Instalar

Doble-click en `install.bat` → aceptar UAC.

El script hace:
1. Detiene el servicio `ThinfinitySvcMgr`.
2. Backup con timestamp del `custom-themes.json` actual.
3. Copia `customthemes.css` + todos los assets (`.png`, `.jpg`, `.ico`, `.svg`) a `C:\Program Files\Thinfinity\Workspace\web\__themes__\`.
4. Crea alias `custom-theme.css` (nombre fijo que espera Thinfinity).
5. Copia `custom-themes.json` a `C:\Program Files\Thinfinity\Workspace\` y a `C:\ProgramData\Cybele Software\Thinfinity\Workspace\DB\`.
6. Arranca el servicio.

### 2. Verificar

1. Abrir Thinfinity en una ventana **incógnito**.
2. **Ctrl+Shift+R** para hard refresh (evita caché).
3. Chequear en la pantalla `/signin`:
   - Tab title "Alvils Workspace"
   - Favicon de la pastilla
   - Logo real en el panel izquierdo
   - Fondo de pastillas teal en el panel izquierdo
   - Panel derecho en verde-teal oscuro
   - Botón "Sign In" turquesa

### 3. Desinstalar / rollback

Doble-click en `uninstall.bat` → restaura el último backup del JSON.

## Paleta Alvils

| Uso | Hex |
|---|---|
| Primary (turquesa) | `#4fcbdf` |
| Dark primary / hero bg | `#005a49` |
| Secondary (teal) | `#00b7a8` |
| Text dark | `#003a30` |

## Editar el tema

1. Modificar `C:\customization\Alvils.ru\customthemes.css`.
2. Correr `install.bat` otra vez.
3. Hard refresh en el browser.

No hace falta editar nada dentro de `C:\Program Files\Thinfinity\` manualmente — el script sincroniza.

## Notas importantes (no documentadas en la KB v7)

- El servicio a reiniciar es `ThinfinitySvcMgr`, no "Thinfinity Workspace Server".
- El JSON activo vive en `C:\Program Files\Thinfinity\Workspace\custom-themes.json`.
- El panel izquierdo del login (v8+) usa `--login-brand-bg`, no `--bg-image`.
- `--bg-image` solo aplica al dashboard post-login (`.bg-primary` dentro de `#app`), no a `/signin`.
- El favicon debe ser `.ico` real. SVG no renderiza (MIME forzado a `image/x-icon`).
- URLs en CSS deben usar prefix `<%=@BASEURL%>__themes__/<archivo>`.

Ver `HOW-TO-CUSTOMIZE.md` para la guía completa, y la lista completa de correcciones a la KB oficial.

## Sitio de referencia

https://www.alvils.ru/ — WordPress, tema propio. Assets descargados de:
- `wp-content/themes/alvils/favicon.ico`
- `wp-content/themes/alvils/img/logo.png`
- `wp-content/themes/alvils/img/backg_business_resize.jpg`
