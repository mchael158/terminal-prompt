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

# Cargo fala com uma cor só. Aqui cada palavra ganha um tom da escala VANTA.
function ConvertTo-VantaArg([string]$Value) {
    if ([string]::IsNullOrEmpty($Value)) { return '""' }
    if ($Value -notmatch '[\s"]') { return $Value }
    $out = New-Object System.Text.StringBuilder
    [void]$out.Append('"')
    $slashes = 0
    foreach ($ch in $Value.ToCharArray()) {
        if ($ch -eq '\') { $slashes++; continue }
        if ($ch -eq '"') {
            [void]$out.Append('\', ($slashes * 2 + 1))
            [void]$out.Append('"')
            $slashes = 0
            continue
        }
        if ($slashes -gt 0) { [void]$out.Append('\', $slashes); $slashes = 0 }
        [void]$out.Append($ch)
    }
    if ($slashes -gt 0) { [void]$out.Append('\', ($slashes * 2)) }
    [void]$out.Append('"')
    return $out.ToString()
}

function Format-VantaPaint([string]$Text, [string]$Hex, [bool]$Bold) {
    if ([string]::IsNullOrEmpty($Text)) { return '' }
    $r = [Convert]::ToInt32($Hex.Substring(1, 2), 16)
    $g = [Convert]::ToInt32($Hex.Substring(3, 2), 16)
    $b = [Convert]::ToInt32($Hex.Substring(5, 2), 16)
    $esc = [char]27
    $style = if ($Bold) { "1;38;2;${r};${g};${b}" } else { "38;2;${r};${g};${b}" }
    return "$esc[${style}m$Text$esc[0m"
}

function Format-VantaCargoLine([string]$Line) {
    $blush = '#FFC2C6'
    $flare = '#FF8A94'
    $hot = '#FF4D5A'
    $scarlet = '#FF1F38'
    $crimson = '#E1062C'
    $blood = '#8E1020'
    $ember = '#A04050'
    $paper = '#FFE4E6'

    $verbs = 'Compiling|Checking|Downloading|Downloaded|Finished|Running|Doc-tests|Fresh|Blocking|Updating|Building|Packaging|Archiving|Installing|Replacing|Removing|Generating|Generated|Dirty|Waiting|Locking|error|warning'
    if ($Line -notmatch "^(?<pad>\s*)(?<verb>$verbs)(?<rest>.*)$") {
        return (Format-VantaPaint $Line $blush $false)
    }

    $verb = $Matches['verb']
    $rest = $Matches['rest']
    $verbHex = switch ($verb) {
        'Compiling' { $scarlet }
        'Checking' { $hot }
        'Building' { $scarlet }
        'Downloading' { $flare }
        'Downloaded' { $blood }
        'Finished' { $paper }
        'Running' { $crimson }
        'Doc-tests' { $hot }
        'Fresh' { $blood }
        'Blocking' { $ember }
        'error' { $crimson }
        'warning' { $flare }
        default { $hot }
    }

    $painted = Format-VantaPaint $Matches['pad'] $blood $false
    $painted += Format-VantaPaint $verb $verbHex $true

    if ($verb -in @('Compiling', 'Checking', 'Building', 'Fresh', 'Downloading', 'Downloaded', 'Doc-tests') -and $rest -match '^(?<gap>\s+)(?<name>\S+)(?<mid>\s+)(?<ver>v\S+)(?<tail>\s+\(.*\))?\s*$') {
        $painted += Format-VantaPaint $Matches['gap'] $blush $false
        $painted += Format-VantaPaint $Matches['name'] $paper $true
        $painted += Format-VantaPaint $Matches['mid'] $blush $false
        $painted += Format-VantaPaint $Matches['ver'] $flare $false
        $painted += Format-VantaPaint $Matches['tail'] $ember $false
        return $painted
    }

    if ($verb -in @('Finished', 'Running') -and $rest -match '^(?<gap>\s+)`(?<inner>[^`]*)`(?<tail>.*)$') {
        $innerHex = if ($verb -eq 'Running') { $paper } else { $scarlet }
        $painted += Format-VantaPaint $Matches['gap'] $blush $false
        $painted += Format-VantaPaint '`' $blood $false
        $painted += Format-VantaPaint $Matches['inner'] $innerHex $true
        $painted += Format-VantaPaint '`' $blood $false
        $painted += Format-VantaPaint $Matches['tail'] $blush $false
        return $painted
    }

    $painted += Format-VantaPaint $rest $blush $false
    return $painted
}

function cargo {
    $exe = $null
    $apps = @(Get-Command -Name cargo -CommandType Application -ErrorAction SilentlyContinue)
    foreach ($app in $apps) {
        if ($app.Source -and $app.Source -like '*.exe') { $exe = $app.Source; break }
        if (-not $exe -and $app.Source) { $exe = $app.Source }
    }
    if (-not $exe) {
        Write-Error 'cargo nao encontrado no PATH'
        return
    }

    if ([Console]::IsOutputRedirected -or [Console]::IsErrorRedirected) {
        & $exe @args
        return
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exe
    $psi.Arguments = (($args | ForEach-Object { ConvertTo-VantaArg ([string]$_) }) -join ' ')
    $psi.UseShellExecute = $false
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardOutput = $false
    $psi.CreateNoWindow = $false
    $psi.WorkingDirectory = (Get-Location).ProviderPath
    $psi.StandardErrorEncoding = New-Object System.Text.UTF8Encoding $false
    $psi.EnvironmentVariables['CARGO_TERM_COLOR'] = 'never'
    $psi.EnvironmentVariables['CARGO_TERM_PROGRESS_WHEN'] = 'never'

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()
    try {
        while (-not $proc.StandardError.EndOfStream) {
            $line = $proc.StandardError.ReadLine()
            [Console]::Error.WriteLine((Format-VantaCargoLine $line))
        }
    } finally {
        $proc.WaitForExit()
        $code = $proc.ExitCode
        $proc.Dispose()
    }

    $global:LASTEXITCODE = $code
    if ($code -ne 0) {
        if (Get-Command cmd.exe -ErrorAction SilentlyContinue) {
            & cmd.exe /c "exit $code" | Out-Null
        } else {
            & sh -c "exit $code"
        }
    }
}
