#!/usr/bin/env bash
# Restaura o prompt no Linux. Rode com: bash install.sh
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

mkdir -p "$HOME/.config"
cp "$here/starship.toml" "$HOME/.config/starship.toml"

append_once() {
  local file=$1
  local snippet=$2
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if grep -q "# terminal-prompt" "$file"; then
    return
  fi
  printf '\n' >> "$file"
  cat "$snippet" >> "$file"
}

append_once "$HOME/.bashrc" "$here/shell/bash.sh"
if command -v zsh >/dev/null 2>&1 || [[ -f "$HOME/.zshrc" ]]; then
  append_once "$HOME/.zshrc" "$here/shell/zsh.sh"
fi
if command -v fish >/dev/null 2>&1 || [[ -d "$HOME/.config/fish" ]]; then
  append_once "$HOME/.config/fish/config.fish" "$here/shell/fish.fish"
fi

if command -v pwsh >/dev/null 2>&1; then
  profile=$(pwsh -NoProfile -Command 'Write-Output $PROFILE')
  mkdir -p "$(dirname "$profile")"
  cp "$here/Microsoft.PowerShell_profile.ps1" "$profile"
fi

python3 - "$here/IDE.json" << 'PY' || true
import json, os, sys
fragment_path = sys.argv[1]
with open(fragment_path, encoding="utf-8") as handle:
    fragment = json.load(handle)
fragment.pop("terminal.integrated.defaultProfile.windows", None)
home = os.path.expanduser("~")
editors = ["Cursor", "Code", "Code - OSS"]
for name in editors:
    root = os.path.join(home, ".config", name)
    if not os.path.isdir(root):
        continue
    path = os.path.join(root, "User", "settings.json")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    current = {}
    if os.path.isfile(path):
        try:
            with open(path, encoding="utf-8") as handle:
                current = json.load(handle)
        except json.JSONDecodeError:
            print("settings com comentario, nao alterado:", path)
            continue
    colors = current.setdefault("workbench.colorCustomizations", {})
    colors.update(fragment.get("workbench.colorCustomizations", {}))
    for key, value in fragment.items():
        if key != "workbench.colorCustomizations":
            current[key] = value
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(current, handle, indent=4)
        handle.write("\n")
PY

if command -v kitty >/dev/null 2>&1 || [[ -d "$HOME/.config/kitty" ]]; then
  mkdir -p "$HOME/.config/kitty"
  cp "$here/linux/kitty.conf" "$HOME/.config/kitty/vanta.conf"
  touch "$HOME/.config/kitty/kitty.conf"
  if ! grep -q "# terminal-prompt" "$HOME/.config/kitty/kitty.conf"; then
    printf '\n# terminal-prompt\ninclude vanta.conf\n' >> "$HOME/.config/kitty/kitty.conf"
  fi
fi

if command -v alacritty >/dev/null 2>&1 || [[ -d "$HOME/.config/alacritty" ]]; then
  mkdir -p "$HOME/.config/alacritty"
  cp "$here/linux/alacritty.toml" "$HOME/.config/alacritty/vanta.toml"
  conf="$HOME/.config/alacritty/alacritty.toml"
  if [[ ! -f "$conf" ]]; then
    printf '# terminal-prompt\n[general]\nimport = ["~/.config/alacritty/vanta.toml"]\n' > "$conf"
  elif ! grep -q "# terminal-prompt" "$conf"; then
    printf '\n# terminal-prompt\n[general]\nimport = ["~/.config/alacritty/vanta.toml"]\n' >> "$conf"
  fi
fi

if command -v foot >/dev/null 2>&1 || [[ -d "$HOME/.config/foot" ]]; then
  mkdir -p "$HOME/.config/foot"
  cp "$here/linux/foot.ini" "$HOME/.config/foot/vanta.ini"
  conf="$HOME/.config/foot/foot.ini"
  touch "$conf"
  if ! grep -q "# terminal-prompt" "$conf"; then
    printf '\n# terminal-prompt\ninclude=~/.config/foot/vanta.ini\n' >> "$conf"
  fi
fi

if command -v dconf >/dev/null 2>&1 && dconf list /org/gnome/terminal/legacy/profiles:/ >/dev/null 2>&1; then
  uuid=$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'\" \n" || true)
  if [[ -n "$uuid" ]]; then
    base="/org/gnome/terminal/legacy/profiles:/:$uuid"
    dconf write "$base/use-theme-colors" false || true
    dconf write "$base/use-transparent-background" true || true
    dconf write "$base/background-transparency-percent" 100 || true
    dconf write "$base/foreground-color" "'#FF334A'" || true
    dconf write "$base/background-color" "'#0A0E14'" || true
    dconf write "$base/palette" "['#4A0610', '#E1062C', '#FF1F38', '#FF4D5A', '#C40024', '#FF2D4A', '#FF6B74', '#FF8A94', '#8E1020', '#FF0033', '#FF2A40', '#FF5C66', '#FF1744', '#FF4060', '#FF7A84', '#FFB4BA']" || true
  fi
fi

echo "Prompt copiado."
echo "Abra um terminal novo e recarregue a janela da IDE."
echo "Instale o Starship se ainda nao tiver: curl -sS https://starship.rs/install.sh | sh"
echo "Instale a fonte: no Arch, sudo pacman -S ttf-jetbrains-mono-nerd"
