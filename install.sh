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

python3 - "$here/cursor-vscode-settings.json" << 'PY' || true
import json, os, sys
fragment_path = sys.argv[1]
with open(fragment_path, encoding="utf-8") as handle:
    fragment = json.load(handle)
home = os.path.expanduser("~")
paths = [
    os.path.join(home, ".config", "Cursor", "User", "settings.json"),
    os.path.join(home, ".config", "Code", "User", "settings.json"),
]
for path in paths:
    if not os.path.isfile(path):
        continue
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

echo "Prompt copiado."
echo "Abra um terminal novo. No Cursor ou no VS Code, recarregue a janela."
echo "Instale o Starship se ainda nao tiver: curl -sS https://starship.rs/install.sh | sh"
echo "Instale uma Nerd Font, por exemplo Cascadia Code NF, para os icones."
