# Restaura o prompt no Windows. No Linux, use install.sh.
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$configDir = Join-Path $env:USERPROFILE ".config"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null
Copy-Item (Join-Path $here "starship.toml") (Join-Path $configDir "starship.toml") -Force

$source = Join-Path $here "Microsoft.PowerShell_profile.ps1"
$stub = @"
# terminal-prompt
# O prompt fica em profile.ps1 e vale para todo host do PowerShell.
"@
$profileDirs = @(Join-Path $env:USERPROFILE "Documents\WindowsPowerShell")
$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
if ($pwsh) {
    $pwshProfile = & $pwsh.Source -NoProfile -Command 'Write-Output $PROFILE'
    if ($pwshProfile) { $profileDirs += (Split-Path -Parent $pwshProfile) }
}
foreach ($dir in ($profileDirs | Select-Object -Unique)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Copy-Item $source (Join-Path $dir "profile.ps1") -Force
    foreach ($name in @("Microsoft.PowerShell_profile.ps1", "Microsoft.VSCode_profile.ps1")) {
        Set-Content -LiteralPath (Join-Path $dir $name) -Value $stub -Encoding UTF8
    }
}

function ConvertTo-ColorRef([string]$hex) {
    $hex = $hex.TrimStart("#")
    $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)
    return ($b -shl 16) -bor ($g -shl 8) -bor $r
}

$palette = @(
    "#0A0E14", "#E1062C", "#FF1F38", "#FF4D5A",
    "#C40024", "#FF2D4A", "#FF6B74", "#FF8A94",
    "#8E1020", "#FF0033", "#FF2A40", "#FF5C66",
    "#FF1744", "#FF4060", "#FF7A84", "#FFB4BA"
)
$consoleKeys = @(
    "HKCU:\Console",
    "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe",
    "HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe"
)
foreach ($key in $consoleKeys) {
    if (-not (Test-Path -LiteralPath $key)) {
        New-Item -Path $key -Force | Out-Null
    }
    for ($i = 0; $i -lt $palette.Count; $i++) {
        $name = "ColorTable{0:D2}" -f $i
        New-ItemProperty -LiteralPath $key -Name $name -PropertyType DWord -Value (ConvertTo-ColorRef $palette[$i]) -Force | Out-Null
    }
    New-ItemProperty -LiteralPath $key -Name "ScreenColors" -PropertyType DWord -Value 0x0F -Force | Out-Null
    New-ItemProperty -LiteralPath $key -Name "PopupColors" -PropertyType DWord -Value 0xF0 -Force | Out-Null
}
$font = "JetBrainsMono Nerd Font"
$fontInstalled = @(
    (Join-Path $env:WINDIR "Fonts"),
    (Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts")
) | Where-Object { Test-Path $_ } | ForEach-Object { Get-ChildItem $_ -Filter "*JetBrains*" -ErrorAction SilentlyContinue }
if ($fontInstalled) {
    foreach ($key in $consoleKeys) {
        New-ItemProperty -LiteralPath $key -Name "FaceName" -PropertyType String -Value $font -Force | Out-Null
    }
}

function Merge-TerminalSettings([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) { return }
    $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) { $raw = "{}" }
    $json = $raw | ConvertFrom-Json
    $fragment = Get-Content (Join-Path $here "IDE.json") -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($name in $fragment.PSObject.Properties.Name) {
        if ($name -eq "workbench.colorCustomizations") {
            if (-not $json.PSObject.Properties["workbench.colorCustomizations"]) {
                $json | Add-Member -NotePropertyName "workbench.colorCustomizations" -NotePropertyValue ([pscustomobject]@{})
            }
            foreach ($color in $fragment.$name.PSObject.Properties.Name) {
                $target = $json."workbench.colorCustomizations"
                if ($target.PSObject.Properties[$color]) {
                    $target.$color = $fragment.$name.$color
                } else {
                    $target | Add-Member -NotePropertyName $color -NotePropertyValue $fragment.$name.$color
                }
            }
        } elseif ($json.PSObject.Properties[$name]) {
            $json.$name = $fragment.$name
        } else {
            $json | Add-Member -NotePropertyName $name -NotePropertyValue $fragment.$name
        }
    }
    $json | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $path -Encoding UTF8
}

Merge-TerminalSettings (Join-Path $env:APPDATA "Cursor\User\settings.json")
Merge-TerminalSettings (Join-Path $env:APPDATA "Code\User\settings.json")

$wtCandidates = @(
    (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"),
    (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"),
    (Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json")
)
$wtFragment = Get-Content (Join-Path $here "windows-terminal-fragment.json") -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($wtPath in $wtCandidates) {
    if (-not (Test-Path -LiteralPath $wtPath)) { continue }
    $wtRaw = Get-Content -LiteralPath $wtPath -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($wtRaw)) { $wtRaw = "{}" }
    $wt = $wtRaw | ConvertFrom-Json
    if (-not $wt.PSObject.Properties["profiles"]) {
        $wt | Add-Member -NotePropertyName "profiles" -NotePropertyValue ([pscustomobject]@{})
    }
    if (-not $wt.profiles.PSObject.Properties["defaults"]) {
        $wt.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue ([pscustomobject]@{})
    }
    $wt.profiles.defaults | Add-Member -NotePropertyName "colorScheme" -NotePropertyValue "VANTA" -Force
    $wt.profiles.defaults | Add-Member -NotePropertyName "useAcrylic" -NotePropertyValue $true -Force
    $wt.profiles.defaults | Add-Member -NotePropertyName "acrylicOpacity" -NotePropertyValue 0 -Force
    if (-not $wt.profiles.defaults.PSObject.Properties["font"]) {
        $wt.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue ([pscustomobject]@{ face = "JetBrainsMono Nerd Font"; size = 13 })
    } else {
        $wt.profiles.defaults.font.face = "JetBrainsMono Nerd Font"
        $wt.profiles.defaults.font.size = 13
    }
    $schemes = @()
    if ($wt.PSObject.Properties["schemes"] -and $wt.schemes) { $schemes = @($wt.schemes) }
    $schemes = @($schemes | Where-Object { $_.name -ne "VANTA" }) + @($wtFragment.schemes)
    if ($wt.PSObject.Properties["schemes"]) { $wt.schemes = $schemes } else { $wt | Add-Member -NotePropertyName "schemes" -NotePropertyValue $schemes }
    $wt | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $wtPath -Encoding UTF8
}

$vantaDir = Join-Path $here "vanta"
if (Get-Command cargo -CommandType Application -ErrorAction SilentlyContinue) {
    Push-Location $vantaDir
    & cargo build --release
    if ($LASTEXITCODE -eq 0) {
        $built = Join-Path $vantaDir "target\release\vanta.exe"
        $destDir = Join-Path (Join-Path $env:USERPROFILE ".local") "bin"
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        Copy-Item $built (Join-Path $destDir "vanta.exe") -Force
        & $built sync $here
    }
    Pop-Location
}

Write-Output "Prompt copiado para todo host do PowerShell."
Write-Output "Abra um terminal novo e recarregue a janela da IDE para a fonte aparecer."
Write-Output "O Starship precisa estar instalado: winget install --id Starship.Starship -e --scope user"
Write-Output "A fonte JetBrainsMono Nerd Font precisa estar instalada para os icones."
