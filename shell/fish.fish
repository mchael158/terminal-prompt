# terminal-prompt
set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
if type -q starship
    starship init fish | source
end
