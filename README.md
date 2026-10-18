# Prompt do terminal no Linux e no Windows

O mesmo prompt nos dois sistemas: nome do sistema, pasta, branch do Git, versão do Rust, data e bateria. No Windows o nome sai como Windows. No Linux sai o da distribuição, por exemplo Arch ou Ubuntu.

Quem abre o PowerShell, o Bash, o Zsh ou o Fish carrega esse prompt. Isso inclui o Cursor, o VS Code e qualquer outra IDE que use um desses shells.

O fundo azul-escuro e a fonte com ícones valem para o terminal integrado do Cursor e do VS Code. As cores do `cargo` (`Compiling`, `Finished`, `Running`) são do próprio Cargo.

## O que tem aqui

- `starship.toml` — o desenho do prompt, igual no Linux e no Windows
- `Microsoft.PowerShell_profile.ps1` — liga o Starship no PowerShell
- `shell/bash.sh`, `shell/zsh.sh`, `shell/fish.fish` — ligam o Starship no Linux
- `cursor-vscode-settings.json` — fonte e cores do terminal no Cursor e no VS Code
- `windows-terminal-fragment.json` — o mesmo esquema, para o Windows Terminal
- `install.ps1` — instala no Windows
- `install.sh` — instala no Linux

## Windows

```powershell
winget install --id Starship.Starship -e --scope user
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

Instale a fonte [Cascadia Code NF](https://github.com/microsoft/cascadia-code/releases). Sem uma Nerd Font, os ícones aparecem como quadrados.

No Windows Terminal, junte o conteúdo de `windows-terminal-fragment.json` nas configurações e escolha a fonte `Cascadia Code NF`.

## Linux

```bash
curl -sS https://starship.rs/install.sh | sh
bash install.sh
```

Instale a mesma fonte. No Arch, um pacote comum é `ttf-cascadia-code-nerd`. Em outras distribuições, o nome da fonte instalada pelo pacote Nerd Fonts pode ser `CaskaydiaCove Nerd Font`. As duas estão na configuração do Cursor e do VS Code.

## Depois de instalar

Abra um terminal novo. No Cursor ou no VS Code, use o comando "Reload Window".

A bateria só aparece em notebook. A versão do Rust só aparece dentro de um projeto Rust.
