# terminal-prompt
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
_vanta_dir=$(cd "$(dirname "${(%):-%x}")" && pwd)
. "$_vanta_dir/cargo.sh"
unset _vanta_dir
# terminal-prompt-end
