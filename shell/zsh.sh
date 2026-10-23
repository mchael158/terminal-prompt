export STARSHIP_CONFIG="$HOME/.config/starship.toml"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

cargo() {
  if command -v vanta >/dev/null 2>&1; then
    vanta cargo "$@"
    return $?
  fi
  command cargo "$@"
}
