# Prompt do terminal no Linux e no Windows

Tema VANTA: três linhas, marca em Fraktur, vermelho profundo e os mesmos dados de antes. No Windows o nome sai como Windows. No Linux sai o da distribuição, por exemplo Arch ou Ubuntu. A hora fica na segunda linha. A versão do Rust, o Git e o tempo do último comando só entram quando existem. Um comando que falha mostra o código de saída; um comando que deu certo não acrescenta marca.

Quem abre o PowerShell, o Bash, o Zsh ou o Fish carrega esse prompt em qualquer IDE.

O fundo do terminal usa a mesma transparência do tema, `#0a0e1400`. As letras ficam numa escala de vermelho, do sangue ao escarlate. As cores do `cargo` (`Compiling`, `Finished`, `Running`) continuam sendo do próprio Cargo.

## O que tem aqui

- `starship.toml` — o desenho do prompt, igual no Linux e no Windows
- `Microsoft.PowerShell_profile.ps1` — liga o Starship no PowerShell
- `shell/bash.sh`, `shell/zsh.sh`, `shell/fish.fish` — ligam o Starship no Linux
- `IDE.json` — fonte e cores do terminal da IDE
- `windows-terminal-fragment.json` — o mesmo esquema, para o Windows Terminal
- `install.ps1` — instala no Windows
- `install.sh` — instala no Linux

## Windows

```powershell
winget install --id Starship.Starship -e --scope user
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

Instale a fonte [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases). Sem uma Nerd Font, alguns símbolos aparecem como quadrados. A marca 𝖁𝕬𝕹𝕿𝕬 é Unicode e não depende dessa fonte.

No Windows Terminal, junte o conteúdo de `windows-terminal-fragment.json` nas configurações e escolha a fonte `JetBrainsMono Nerd Font`.

## Linux

```bash
curl -sS https://starship.rs/install.sh | sh
bash install.sh
```

Instale a mesma fonte. No Arch, um pacote comum é `ttf-jetbrains-mono-nerd`. O nome da família pode ser `JetBrainsMono Nerd Font`. Se a Cascadia Code NF já estiver instalada, a IDE também aceita essa fonte.

## Depois de instalar

Abra um terminal novo e recarregue a janela da IDE.

A bateria só aparece em notebook. A versão do Rust só aparece dentro de um projeto Rust.
