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

function cargo {
    $vanta = Join-Path (Join-Path (Join-Path $env:USERPROFILE ".local") "bin") "vanta.exe"
    if (-not (Test-Path -LiteralPath $vanta)) {
        $found = Get-Command vanta -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $vanta = $found.Source }
    }
    if ($vanta -and (Test-Path -LiteralPath $vanta)) {
        & $vanta cargo @args
        if ($LASTEXITCODE -ne 0) {
            if (Get-Command cmd.exe -ErrorAction SilentlyContinue) {
                & cmd.exe /c "exit $LASTEXITCODE" | Out-Null
            } elseif (Get-Command sh -ErrorAction SilentlyContinue) {
                & sh -c "exit $LASTEXITCODE"
            }
        }
        return
    }

    $exe = $null
    foreach ($app in @(Get-Command cargo -CommandType Application -ErrorAction SilentlyContinue)) {
        if ($app.Source) { $exe = $app.Source; break }
    }
    if (-not $exe) {
        Write-Error "cargo not found on PATH"
        return
    }
    & $exe @args
}
