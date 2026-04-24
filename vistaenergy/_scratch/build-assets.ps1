$ErrorActionPreference = 'Stop'
$src  = 'C:\customization\vistaenergy\_scratch'
$dest = 'C:\customization\vistaenergy'

# ---- Read raw logo SVGs extracted from vistaenergy.com ----
$logoRaw       = Get-Content "$src\logo-raw.svg"        -Raw
$logoMobileRaw = Get-Content "$src\logo-mobile-raw.svg" -Raw

function Clean-VistaSvg {
    param([string]$svg, [string]$fillHex)
    # Remove tailwind hover classes that do nothing in Thinfinity
    $out = [regex]::Replace($svg, '\s*class="group-hover:fill-violet[^"]*"', '')
    $out = [regex]::Replace($out, '\s*aria-hidden="[^"]*"', '')
    # Replace every fill="white" with the target hex
    $out = $out -replace 'fill="white"', "fill=`"$fillHex`""
    return $out
}

# Violet variant for Light theme
$violet = '#6748d8'
(Clean-VistaSvg -svg $logoRaw       -fillHex $violet) | Out-File "$dest\VistaLogo.svg"       -Encoding utf8 -NoNewline
(Clean-VistaSvg -svg $logoMobileRaw -fillHex $violet) | Out-File "$dest\VistaLogoMobile.svg" -Encoding utf8 -NoNewline

# White variant for Dark theme + login hero (matches the site)
$white = '#ffffff'
(Clean-VistaSvg -svg $logoRaw       -fillHex $white) | Out-File "$dest\VistaLogoWhite.svg"       -Encoding utf8 -NoNewline
(Clean-VistaSvg -svg $logoMobileRaw -fillHex $white) | Out-File "$dest\VistaLogoMobileWhite.svg" -Encoding utf8 -NoNewline

# Login page logo: use the white variant (placed over dark hero panel)
Copy-Item "$dest\VistaLogoWhite.svg" "$dest\VistaLoginLogo.svg" -Force

# Favicon: real .ico from the site
Copy-Item "$src\favicon.ico" "$dest\VistaFavicon.ico" -Force

# Hero image (og:image — the site's SEO share card, Vista brand imagery)
Copy-Item "$src\share.jpg"  "$dest\VistaHero.jpg"    -Force

Write-Host "Assets built in $dest"
Get-ChildItem $dest -File | Select-Object Name, Length | Format-Table -AutoSize
