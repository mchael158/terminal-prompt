# terminal-prompt
# Pinta o cargo na escala VANTA. Bash e Zsh usam o mesmo arquivo.
if [ -n "${ZSH_VERSION:-}" ]; then
  setopt BASH_REMATCH
fi

vanta_paint() {
  local text=$1 hex=$2 bold=${3:-0}
  [ -z "$text" ] && return 0
  local r=$((16#${hex:1:2})) g=$((16#${hex:3:2})) b=$((16#${hex:5:2}))
  if [ "$bold" = 1 ]; then
    printf '\033[1;38;2;%d;%d;%dm%s\033[0m' "$r" "$g" "$b" "$text"
  else
    printf '\033[38;2;%d;%d;%dm%s\033[0m' "$r" "$g" "$b" "$text"
  fi
}

vanta_cargo_line() {
  local line=$1
  local blush="#FFC2C6" flare="#FF8A94" hot="#FF4D5A" scarlet="#FF1F38"
  local crimson="#E1062C" blood="#8E1020" ember="#A04050" paper="#FFE4E6"
  local verbs='Compiling|Checking|Downloading|Downloaded|Finished|Running|Doc-tests|Fresh|Blocking|Updating|Building|Packaging|Archiving|Installing|Replacing|Removing|Generating|Generated|Dirty|Waiting|Locking|error|warning'
  if [[ ! $line =~ ^([[:space:]]*)($verbs)(.*)$ ]]; then
    vanta_paint "$line" "$blush" 0
    printf '\n'
    return 0
  fi
  local pad=${BASH_REMATCH[1]} verb=${BASH_REMATCH[2]} rest=${BASH_REMATCH[3]}
  local verb_hex=$hot
  case $verb in
    Compiling|Building) verb_hex=$scarlet ;;
    Checking|Doc-tests) verb_hex=$hot ;;
    Downloading|warning) verb_hex=$flare ;;
    Downloaded|Fresh) verb_hex=$blood ;;
    Finished) verb_hex=$paper ;;
    Running|error) verb_hex=$crimson ;;
    Blocking) verb_hex=$ember ;;
  esac
  vanta_paint "$pad" "$blood" 0
  vanta_paint "$verb" "$verb_hex" 1
  case $verb in
    Compiling|Checking|Building|Fresh|Downloading|Downloaded|Doc-tests)
      if [[ $rest =~ ^([[:space:]]+)([^[:space:]]+)([[:space:]]+)(v[^[:space:]]+)([[:space:]]+\(.*\))?[[:space:]]*$ ]]; then
        vanta_paint "${BASH_REMATCH[1]}" "$blush" 0
        vanta_paint "${BASH_REMATCH[2]}" "$paper" 1
        vanta_paint "${BASH_REMATCH[3]}" "$blush" 0
        vanta_paint "${BASH_REMATCH[4]}" "$flare" 0
        vanta_paint "${BASH_REMATCH[5]}" "$ember" 0
        printf '\n'
        return 0
      fi
      ;;
    Finished|Running)
      if [[ $rest =~ ^([[:space:]]+)\`([^\`]*)\`(.*)$ ]]; then
        local inner_hex=$scarlet
        [ "$verb" = Running ] && inner_hex=$paper
        vanta_paint "${BASH_REMATCH[1]}" "$blush" 0
        vanta_paint '`' "$blood" 0
        vanta_paint "${BASH_REMATCH[2]}" "$inner_hex" 1
        vanta_paint '`' "$blood" 0
        vanta_paint "${BASH_REMATCH[3]}" "$blush" 0
        printf '\n'
        return 0
      fi
      ;;
  esac
  vanta_paint "$rest" "$blush" 0
  printf '\n'
}

cargo() {
  if ! command -v cargo >/dev/null 2>&1; then
    printf 'cargo nao encontrado no PATH\n' >&2
    return 127
  fi
  if [ ! -t 1 ] || [ ! -t 2 ]; then
    command cargo "$@"
    return $?
  fi
  local fifo reader code
  fifo=$(mktemp -u)
  mkfifo "$fifo"
  while IFS= read -r line; do
    vanta_cargo_line "$line" >&2
  done < "$fifo" &
  reader=$!
  CARGO_TERM_COLOR=never CARGO_TERM_PROGRESS_WHEN=never command cargo "$@" 2>"$fifo"
  code=$?
  wait "$reader"
  rm -f "$fifo"
  return "$code"
}
