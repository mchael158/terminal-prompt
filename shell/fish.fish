# terminal-prompt
set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
if type -q starship
    starship init fish | source
end

function vanta_paint --argument-names text hex bold
    if test -z "$text"
        return
    end
    set r (math 0x(string sub --start 2 --length 2 $hex))
    set g (math 0x(string sub --start 4 --length 2 $hex))
    set b (math 0x(string sub --start 6 --length 2 $hex))
    if test "$bold" = 1
        printf '\033[1;38;2;%d;%d;%dm%s\033[0m' $r $g $b $text
    else
        printf '\033[38;2;%d;%d;%dm%s\033[0m' $r $g $b $text
    end
end

function vanta_cargo_line
    set line $argv[1]
    set blush "#FFC2C6"
    set flare "#FF8A94"
    set hot "#FF4D5A"
    set scarlet "#FF1F38"
    set crimson "#E1062C"
    set blood "#8E1020"
    set ember "#A04050"
    set paper "#FFE4E6"
    set verbs 'Compiling|Checking|Downloading|Downloaded|Finished|Running|Doc-tests|Fresh|Blocking|Updating|Building|Packaging|Archiving|Installing|Replacing|Removing|Generating|Generated|Dirty|Waiting|Locking|error|warning'
    if not string match --quiet --regex -- "^\\s*($verbs).*" "$line"
        vanta_paint "$line" $blush 0
        printf '\n'
        return
    end
    set parts (string match --regex -- "^(\\s*)($verbs)(.*)" "$line")
    set pad $parts[2]
    set verb $parts[3]
    set rest $parts[4]
    set verb_hex $hot
    switch $verb
        case Compiling Building
            set verb_hex $scarlet
        case Checking Doc-tests
            set verb_hex $hot
        case Downloading warning
            set verb_hex $flare
        case Downloaded Fresh
            set verb_hex $blood
        case Finished
            set verb_hex $paper
        case Running error
            set verb_hex $crimson
        case Blocking
            set verb_hex $ember
    end
    vanta_paint "$pad" $blood 0
    vanta_paint "$verb" $verb_hex 1
    switch $verb
        case Compiling Checking Building Fresh Downloading Downloaded Doc-tests
            set crate (string match --regex -- '^(\s+)(\S+)(\s+)(v\S+)(\s+\(.*\))?$' "$rest")
            if test (count $crate) -ge 5
                vanta_paint $crate[2] $blush 0
                vanta_paint $crate[3] $paper 1
                vanta_paint $crate[4] $blush 0
                vanta_paint $crate[5] $flare 0
                if test (count $crate) -ge 6
                    vanta_paint $crate[6] $ember 0
                end
                printf '\n'
                return
            end
        case Finished Running
            set tick (string match --regex -- '^(\s+)`([^`]*)`(.*)$' "$rest")
            if test (count $tick) -ge 4
                set inner_hex $scarlet
                if test "$verb" = Running
                    set inner_hex $paper
                end
                vanta_paint $tick[2] $blush 0
                vanta_paint '`' $blood 0
                vanta_paint $tick[3] $inner_hex 1
                vanta_paint '`' $blood 0
                vanta_paint $tick[4] $blush 0
                printf '\n'
                return
            end
    end
    vanta_paint "$rest" $blush 0
    printf '\n'
end

function cargo --wraps cargo
    if not type -q cargo
        printf 'cargo nao encontrado no PATH\n' >&2
        return 127
    end
    if not isatty stdout; or not isatty stderr
        command cargo $argv
        return $status
    end
    set fifo (mktemp -u)
    mkfifo $fifo
    begin
        while read -l line
            vanta_cargo_line "$line" >&2
        end < $fifo
    end &
    set reader $last_pid
    env CARGO_TERM_COLOR=never CARGO_TERM_PROGRESS_WHEN=never command cargo $argv 2> $fifo
    set code $status
    wait $reader
    rm -f $fifo
    return $code
end
# terminal-prompt-end
