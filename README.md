# Prompt do terminal no Windows

Copia do prompt usado no PowerShell: sistema, pasta, branch do Git, versão do Rust, data e bateria. O PowerShell carrega isso sozinho, então o Cursor, o VS Code e qualquer outra IDE que abra o PowerShell ficam com o mesmo prompt.

O fundo azul-escuro e a fonte com ícones valem para o terminal integrado do Cursor e do VS Code. As cores do `cargo` (`Compiling`, `Finished`, `Running`) são do próprio Cargo.

## O que tem aqui

- `starship.toml` — o desenho do prompt
- `Microsoft.PowerShell_profile.ps1` — liga o Starship quando o PowerShell abre
- `cursor-vscode-settings.json` — fonte e cores do terminal no Cursor e no VS Code
- `windows-terminal-fragment.json` — o mesmo esquema, para o Windows Terminal
- `install.ps1` — copia tudo de volta para este usuário

## Instalar de novo

1. Instale o Starship:

```powershell
winget install --id Starship.Starship -e --scope user
```

2. Instale a fonte [Cascadia Code NF](https://github.com/microsoft/cascadia-code/releases). Sem ela, os ícones aparecem como quadrados.

3. Na pasta deste repositório:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

4. Abra um terminal novo. No Cursor ou no VS Code, use o comando "Reload Window".

A bateria só aparece em notebook. Num desktop essa parte fica de fora. A versão do Rust só aparece dentro de um projeto Rust.

No Windows Terminal, junte o conteúdo de `windows-terminal-fragment.json` nas configurações e escolha a fonte `Cascadia Code NF`.
