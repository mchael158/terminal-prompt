# Terminal prompt for Linux and Windows

VANTA theme: three lines, a Fraktur mark, deep red, and the same details as before. On Windows the name is Windows. On Linux it is the distribution name, for example Arch or Ubuntu. The time sits on the second line. The Rust version, Git, and the last command duration appear only when they exist. A failed command shows its exit code. A successful command adds no mark.

PowerShell, Bash, Zsh, and Fish load this prompt in any editor.

The terminal background uses the same transparency as the theme, `#0a0e1400`. The letters use a red scale, from blood to scarlet. `cargo run` keeps that scale, but the words are not one flat red: `Compiling` is scarlet, the crate name is paper, the version is flare, `Finished` is light, and `Running` is crimson.

## What is here

- `starship.toml` — the prompt layout, the same on Linux and Windows
- `Microsoft.PowerShell_profile.ps1` — enables Starship in PowerShell
- `src/` — the Rust program that owns the palette and paints `cargo`
- `shell/bash.sh`, `shell/zsh.sh`, `shell/fish.fish` — enable Starship and call `vanta`
- `IDE.json` — editor terminal font and colors
- `windows-terminal-fragment.json` — the same scheme, for Windows Terminal
- `linux/` — the same colors for Kitty, Alacritty, Foot, and GNOME Terminal
- `install.ps1` — installs on Windows
- `install.sh` — installs on Linux

## Windows

```powershell
winget install --id Starship.Starship -e --scope user
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

Install the [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases). Without a Nerd Font, some symbols show up as squares. The 𝖁𝕬𝕹𝕿𝕬 mark is Unicode and does not depend on that font.

In Windows Terminal, merge `windows-terminal-fragment.json` into the settings and select the `JetBrainsMono Nerd Font` font.

## Linux

```bash
curl -sS https://starship.rs/install.sh | sh
bash install.sh
```

On Arch, the font package is `sudo pacman -S ttf-jetbrains-mono-nerd`. On other distributions, install the JetBrains Mono Nerd Font package. `install.sh` builds the Rust program, enables Bash, Zsh, and Fish, and copies the same colors into Kitty, Alacritty, Foot, GNOME Terminal, and the editor terminal. PowerShell on Linux uses `profile.ps1`, so every host gets the prompt. The background stays transparent, and the system name is the distribution name.

## After installing

Open a new terminal and reload the editor window.

The battery appears only on a laptop. The Rust version appears only inside a Rust project.
