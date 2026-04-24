$ErrorActionPreference = 'Stop'
$h = Get-Content 'C:\customization\vistaenergy\_scratch\index.html' -Raw

# Get the first SVG with viewBox 104x29 (the main Vista logo)
$m = [regex]::Match($h, '(?is)<svg[^>]*viewBox="0 0 104 29"[^>]*>.*?</svg>')
if (-not $m.Success) {
    $m = [regex]::Match($h, '(?is)<svg[^>]*width="104"[^>]*height="29"[^>]*>.*?</svg>')
}
Write-Host "Found logo length: $($m.Value.Length)"
$m.Value | Out-File 'C:\customization\vistaenergy\_scratch\logo-raw.svg' -Encoding utf8

# Also try viewBox 103x28 (mobile variant)
$m2 = [regex]::Match($h, '(?is)<svg[^>]*viewBox="0 0 103 28"[^>]*>.*?</svg>')
Write-Host "Found mobile logo length: $($m2.Value.Length)"
$m2.Value | Out-File 'C:\customization\vistaenergy\_scratch\logo-mobile-raw.svg' -Encoding utf8

Write-Host "`nLogo SVG preview (first 400 chars):"
Write-Host $m.Value.Substring(0, [Math]::Min(400, $m.Value.Length))
