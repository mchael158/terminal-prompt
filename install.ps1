# Restaura o prompt neste Windows. Rode numa janela nova do PowerShell:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$configDir = Join-Path $env:USERPROFILE ".config"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null
Copy-Item (Join-Path $here "starship.toml") (Join-Path $configDir "starship.toml") -Force

$profileDir = Split-Path -Parent $PROFILE
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
Copy-Item (Join-Path $here "Microsoft.PowerShell_profile.ps1") $PROFILE -Force

function Merge-TerminalSettings([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) { return }
    $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) { $raw = "{}" }
    $json = $raw | ConvertFrom-Json
    $fragment = Get-Content (Join-Path $here "cursor-vscode-settings.json") -Raw -Encoding UTF8 | ConvertFrom-Json
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

Write-Output "Prompt copiado."
Write-Output "Abra um terminal novo. No Cursor ou no VS Code, recarregue a janela para a fonte aparecer."
Write-Output "O Starship precisa estar instalado: winget install --id Starship.Starship -e --scope user"
Write-Output "A fonte Cascadia Code NF precisa estar instalada para os icones."
