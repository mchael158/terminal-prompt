# terminal-prompt
set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
if type -q starship
    starship init fish | source
end

function cargo --wraps cargo
    if type -q vanta
        vanta cargo $argv
        return $status
    end
    command cargo $argv
end
# terminal-prompt-end
