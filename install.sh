#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

mkdir -p "$HOME/.config"
cp "$here/starship.toml" "$HOME/.config/starship.toml"

mkdir -p "$HOME/.config/vanta"
cp "$here/shell/bash.sh" "$here/shell/zsh.sh" "$here/shell/fish.fish" "$HOME/.config/vanta/"

if command -v cargo >/dev/null 2>&1; then
  (cd "$here" && cargo build --release)
  mkdir -p "$HOME/.local/bin"
  cp "$here/target/release/vanta" "$HOME/.local/bin/vanta"
  chmod +x "$HOME/.local/bin/vanta"
  "$HOME/.local/bin/vanta" sync "$here"
fi

install_hook() {
  if ! command -v python3 >/dev/null 2>&1; then
    mkdir -p "$(dirname "$1")"
    touch "$1"
    if ! grep -q "# terminal-prompt" "$1"; then
      printf '\n%s\n' "$2" >> "$1"
    fi
    return
  fi
  python3 - "$1" "$2" << 'PY'
import pathlib, sys
path, hook = sys.argv[1], sys.argv[2]
file = pathlib.Path(path)
file.parent.mkdir(parents=True, exist_ok=True)
text = file.read_text(encoding="utf-8") if file.exists() else ""
start = "# terminal-prompt"
end = "# terminal-prompt-end"
block = hook.strip() + "\n"
if start in text and end in text:
    pre, rest = text.split(start, 1)
    _, post = rest.split(end, 1)
    post = post.lstrip("\n")
    text = pre.rstrip() + "\n\n" + block + (("\n" + post) if post else "")
elif start in text:
    pre, _ = text.split(start, 1)
    text = pre.rstrip() + "\n\n" + block
else:
    if text and not text.endswith("\n"):
        text += "\n"
    text = text.rstrip() + "\n\n" + block
file.write_text(text, encoding="utf-8")
PY
}

install_hook "$HOME/.bashrc" '# terminal-prompt
. "$HOME/.config/vanta/bash.sh"
# terminal-prompt-end'
if command -v zsh >/dev/null 2>&1 || [[ -f "$HOME/.zshrc" ]]; then
  install_hook "$HOME/.zshrc" '# terminal-prompt
. "$HOME/.config/vanta/zsh.sh"
# terminal-prompt-end'
fi
if command -v fish >/dev/null 2>&1 || [[ -d "$HOME/.config/fish" ]]; then
  install_hook "$HOME/.config/fish/config.fish" '# terminal-prompt
source "$HOME/.config/vanta/fish.fish"
# terminal-prompt-end'
fi

if command -v pwsh >/dev/null 2>&1; then
  profile=$(pwsh -NoProfile -Command 'Write-Output $PROFILE')
  dir=$(dirname "$profile")
  mkdir -p "$dir"
  cp "$here/Microsoft.PowerShell_profile.ps1" "$dir/profile.ps1"
  : > "$dir/Microsoft.PowerShell_profile.ps1"
  cp "$dir/Microsoft.PowerShell_profile.ps1" "$dir/Microsoft.VSCode_profile.ps1"
fi

python3 - << 'PY' || true
import io, os, urllib.request, zipfile
packs = [
    ("PKief.material-icon-theme-5.39.0", "https://github.com/material-extensions/vscode-material-icon-theme/releases/download/v5.39.0/material-icon-theme-5.39.0.vsix"),
    ("PKief.material-product-icons-1.7.1", "https://github.com/material-extensions/vscode-material-product-icons/releases/download/v1.7.1/material-product-icons-1.7.1.vsix"),
]
homes = [os.path.expanduser(p) for p in ("~/.cursor", "~/.vscode", "~/.vscode-oss")]
for home in homes:
    if not os.path.isdir(home):
        continue
    extensions = os.path.join(home, "extensions")
    os.makedirs(extensions, exist_ok=True)
    for folder, url in packs:
        dest = os.path.join(extensions, folder)
        if os.path.isfile(os.path.join(dest, "package.json")):
            continue
        request = urllib.request.Request(url, headers={"User-Agent": "vanta"})
        with urllib.request.urlopen(request) as response:
            data = response.read()
        with zipfile.ZipFile(io.BytesIO(data)) as archive:
            for name in archive.namelist():
                if not name.startswith("extension/"):
                    continue
                rel = name[len("extension/"):]
                if not rel:
                    continue
                out = os.path.join(dest, rel)
                if name.endswith("/"):
                    os.makedirs(out, exist_ok=True)
                    continue
                os.makedirs(os.path.dirname(out), exist_ok=True)
                with archive.open(name) as src, open(out, "wb") as dst:
                    dst.write(src.read())
PY

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
            print("settings contain comments, left unchanged:", path)
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
    dconf write "$base/foreground-color" "'#FFC2C6'" || true
    dconf write "$base/background-color" "'#0A0E14'" || true
    dconf write "$base/palette" "['#4A0610', '#E1062C', '#FF1F38', '#FF4D5A', '#C40024', '#FF2D4A', '#FF6B74', '#FF8A94', '#8E1020', '#FF0033', '#FF2A40', '#FF5C66', '#FF1744', '#FF4060', '#FF7A84', '#FFB4BA']" || true
  fi
fi

echo "Prompt installed."
echo "Open a new terminal and reload the editor window."
echo "Install Starship if it is missing: curl -sS https://starship.rs/install.sh | sh"
echo "Install the font: on Arch, sudo pacman -S ttf-jetbrains-mono-nerd"
