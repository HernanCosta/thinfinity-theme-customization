$ErrorActionPreference = 'Stop'
$files = @('css1.css','css2.css','css3.css','css4.css')
$allText = ''
foreach ($f in $files) {
    $allText += (Get-Content "C:\customization\vistaenergy\_scratch\$f" -Raw)
}

# Also include HTML for color refs
$allText += (Get-Content 'C:\customization\vistaenergy\_scratch\index.html' -Raw)

Write-Host "===== HEX COLORS (top 40 by frequency) ====="
$hex = [regex]::Matches($allText, '#[0-9A-Fa-f]{6}\b|#[0-9A-Fa-f]{3}\b') |
    ForEach-Object { $_.Value.ToLower() }
$hex | Group-Object | Sort-Object Count -Descending | Select-Object -First 40 | Format-Table Count, Name -AutoSize

Write-Host "===== CSS VARS (custom props) ====="
[regex]::Matches($allText, '--[a-zA-Z0-9_-]+\s*:\s*[^;}]+') |
    ForEach-Object { $_.Value } |
    Select-Object -Unique |
    Select-Object -First 50

Write-Host "`n===== FONT-FAMILY refs ====="
[regex]::Matches($allText, 'font-family\s*:\s*[^;}]+') |
    ForEach-Object { $_.Value } |
    Select-Object -Unique |
    Select-Object -First 15

Write-Host "`n===== TAILWIND CUSTOM COLORS (violet/lilac keywords in CSS) ====="
[regex]::Matches($allText, '\.(violet|lilac|indigo|purple)[a-zA-Z0-9_-]*\s*\{[^}]*\}') |
    ForEach-Object { $_.Value } |
    Select-Object -First 8
