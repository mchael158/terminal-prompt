# Liga o Starship no PowerShell, no Windows e no Linux.
$env:STARSHIP_CONFIG = Join-Path (Join-Path $env:USERPROFILE ".config") "starship.toml"

$starship = $null
$found = Get-Command starship -ErrorAction SilentlyContinue
if ($found) { $starship = $found.Source }
if (-not $starship -and $env:LOCALAPPDATA) {
    $winget = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages\Starship.Starship_Microsoft.Winget.Source_8wekyb3d8bbwe\starship.exe"
    if (Test-Path -LiteralPath $winget) { $starship = $winget }
}

if ($starship -and (Test-Path -LiteralPath $starship)) {
    Invoke-Expression (& $starship init powershell)
}
