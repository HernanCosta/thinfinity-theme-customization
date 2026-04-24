$ErrorActionPreference = 'Stop'
$h = Get-Content 'C:\customization\vistaenergy\_scratch\index.html' -Raw

Write-Host "===== ICONS ====="
[regex]::Matches($h, '(?i)<link[^>]*rel="(?:shortcut icon|icon|apple-touch-icon)[^"]*"[^>]*>') | ForEach-Object { $_.Value }

Write-Host "`n===== META/OG ====="
[regex]::Matches($h, '(?i)<meta[^>]*(og:image|twitter:image|theme-color)[^>]*>') | ForEach-Object { $_.Value }

Write-Host "`n===== STYLESHEETS ====="
[regex]::Matches($h, '(?i)<link[^>]*rel="stylesheet"[^>]*>') | ForEach-Object { $_.Value } | Select-Object -First 20

Write-Host "`n===== LOGO TAGS ====="
[regex]::Matches($h, '(?i)<img[^>]*(logo|brand)[^>]*>') | ForEach-Object { $_.Value } | Select-Object -First 15

Write-Host "`n===== SVG INLINE (first 5) ====="
[regex]::Matches($h, '(?i)<svg[^>]*>.{0,500}') | ForEach-Object { $_.Value.Substring(0, [Math]::Min(200, $_.Value.Length)) } | Select-Object -First 5
