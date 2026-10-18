# Carrega o prompt Starship em todo terminal que abre o PowerShell,
# inclusive Cursor, VS Code e qualquer outra IDE.
$env:STARSHIP_CONFIG = Join-Path $env:USERPROFILE ".config\starship.toml"

$starship = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages\Starship.Starship_Microsoft.Winget.Source_8wekyb3d8bbwe\starship.exe"
if (-not (Test-Path -LiteralPath $starship)) {
    $found = Get-Command starship -ErrorAction SilentlyContinue
    if ($found) { $starship = $found.Source }
}

if ($starship -and (Test-Path -LiteralPath $starship)) {
    Invoke-Expression (& $starship init powershell)
}
