#!/usr/bin/env bash
# ssh-reload / sshr - SSH-Agent neu starten und Schlüssel interaktiv laden
# Wird von bash UND zsh gesourct. Muss gesourct werden (nicht ausführen),
# damit SSH_AUTH_SOCK / SSH_AGENT_PID in der aktuellen Shell landen.
#
#   ssh-reload            -> Agent leeren/neu starten + Keys auswählen (fzf, multi)
#   ssh-reload -a         -> alle privaten Keys aus ~/.ssh laden
#   ssh-reload ~/.ssh/id_x [...] -> nur diese Keys laden
#
# Falsches Passwort: bis zu 3 Versuche pro Key, leere Eingabe = überspringen.

SSH_RELOAD_DIR="${SSH_RELOAD_DIR:-$HOME/.ssh}"
SSH_RELOAD_RETRIES="${SSH_RELOAD_RETRIES:-3}"

# --- Socketpfad (identisch zum Startup-Loader) ---
_ssh_reload_socket() {
  printf '%s\n' "${XDG_RUNTIME_DIR:-/tmp}/ssh-agent.${USER}.sock"
}

# --- alle privaten Keys in ~/.ssh finden (newline-separiert) ---
_ssh_reload_list_keys() {
  [ -n "$ZSH_VERSION" ] && setopt local_options null_glob
  local f base
  for f in "$SSH_RELOAD_DIR"/*; do
    [ -f "$f" ] || continue
    base=${f##*/}
    case "$base" in
    *.pub | *.old | config | known_hosts* | authorized_keys | environment | rc | *.cer | *.crt) continue ;;
    esac
    head -n 1 "$f" 2>/dev/null | grep -q 'PRIVATE KEY' || continue
    printf '%s\n' "$f"
  done
}

# --- Key ohne Passphrase? ---
_ssh_reload_is_plain() {
  ssh-keygen -y -P "" -f "$1" >/dev/null 2>&1
}

# --- ssh-add mit Passphrase aus der Umgebung (nie via Datei/Argument) ---
# Wichtig: erst mit ssh-keygen prüfen. ssh-add würde bei falscher Passphrase
# den Askpass-Helfer endlos erneut aufrufen und damit hängen bleiben.
_ssh_reload_try_add() { # $1 = keyfile, $2 = passphrase
  ssh-keygen -y -P "$2" -f "$1" >/dev/null 2>&1 || return 1
  SSH_ASKPASS="$_SSH_RELOAD_ASKPASS" SSH_ASKPASS_REQUIRE=force DISPLAY="${DISPLAY:-:0}" \
    SSH_PASSPHRASE="$2" ssh-add "$1" >/dev/null 2>&1
}

_ssh_reload_mk_askpass() {
  _SSH_RELOAD_ASKPASS=$(mktemp "${TMPDIR:-/tmp}/ssh-reload-askpass.XXXXXX") || return 1
  cat >"$_SSH_RELOAD_ASKPASS" <<'ASKPASS'
#!/usr/bin/env bash
printf '%s\n' "$SSH_PASSPHRASE"
ASKPASS
  chmod 700 "$_SSH_RELOAD_ASKPASS"
}

_ssh_reload_cleanup() {
  [ -n "$_SSH_RELOAD_ASKPASS" ] && rm -f "$_SSH_RELOAD_ASKPASS"
  unset _SSH_RELOAD_ASKPASS
}

# --- alten Agent leeren und beenden, neuen starten ---
_ssh_reload_restart_agent() {
  local sock
  sock=$(_ssh_reload_socket)

  ssh-add -D >/dev/null 2>&1

  if [ -n "$SSH_AGENT_PID" ]; then
    ssh-agent -k >/dev/null 2>&1
  fi
  # Fallback: nur Agents mit *unserem* Socketpfad, niemals pauschal alle
  pkill -u "$USER" -f "ssh-agent -a $sock" >/dev/null 2>&1
  rm -f "$sock"
  unset SSH_AGENT_PID

  export SSH_AUTH_SOCK="$sock"
  eval "$(ssh-agent -a "$sock" -s)" >/dev/null || {
    echo "ssh-reload: Agent konnte nicht gestartet werden." >&2
    return 1
  }
}

# --- Auswahl: fzf multi, sonst nummeriertes Menü ---
# Liste kommt als $1 (nicht über stdin), damit das Menü stdin zum Lesen behält.
_ssh_reload_pick() { # $1 = Keyliste (newline-separiert)
  local all="$1"
  [ -z "$all" ] && return 1

  if [ -z "$SSH_RELOAD_NO_FZF" ] && command -v fzf >/dev/null 2>&1 && [ -t 0 ]; then
    printf '%s\n' "$all" |
      fzf --multi --height=60% --reverse \
        --prompt="SSH-Keys laden (TAB = mehrere) > " \
        --header="Enter = laden, ESC = abbrechen"
    return
  fi

  local i=0 line choice tok for_tok_input
  while IFS= read -r line <&4; do
    i=$((i + 1))
    printf '%2d) %s\n' "$i" "$line" >&2
  done 4<<EOF
$all
EOF
  printf 'Auswahl (z.B. "1 3", "a" = alle, leer = abbrechen): ' >&2
  IFS= read -r choice || return 1
  [ -z "$choice" ] && return 1
  case "$choice" in
  a | A | all)
    printf '%s\n' "$all"
    return 0
    ;;
  esac
  # zsh splittet unquoted Variablen nicht -> Tokens explizit über tr/fd 5 lesen
  for_tok_input=$(printf '%s' "$choice" | tr -s ' \t,' '\n')
  while IFS= read -r tok <&5; do
    case "$tok" in
    '') continue ;;
    *[!0-9]*)
      echo "ssh-reload: ungültige Eingabe '$tok', ignoriert." >&2
      continue
      ;;
    esac
    if [ "$tok" -lt 1 ] || [ "$tok" -gt "$i" ]; then
      echo "ssh-reload: Nummer '$tok' außerhalb des Bereichs, ignoriert." >&2
      continue
    fi
    printf '%s\n' "$all" | sed -n "${tok}p"
  done 5<<EOF
$for_tok_input
EOF
}

# --- einen Key laden, mit Retrys ---
_ssh_reload_add_key() { # $1 = keyfile
  local key="$1" pass try known
  if _ssh_reload_is_plain "$key"; then
    if ssh-add "$key" >/dev/null 2>&1; then
      printf '  OK        %s\n' "$key"
      return 0
    fi
    printf '  FEHLER    %s\n' "$key"
    return 1
  fi

  # bereits erfolgreiche Passphrasen still durchprobieren (mehrere Keys, ein Passwort)
  # fd 4, damit das Passwort-Prompt weiter von stdin lesen kann
  while IFS= read -r known <&4; do
    [ -z "$known" ] && continue
    if _ssh_reload_try_add "$key" "$known"; then
      printf '  OK        %s (bekannte Passphrase)\n' "$key"
      return 0
    fi
  done 4<<EOF
$_SSH_RELOAD_KNOWN_PASS
EOF

  try=1
  while [ "$try" -le "$SSH_RELOAD_RETRIES" ]; do
    printf 'Passphrase für %s (Versuch %d/%d, leer = überspringen): ' \
      "$key" "$try" "$SSH_RELOAD_RETRIES"
    IFS= read -rs pass
    echo
    if [ -z "$pass" ]; then
      printf '  ÜBERSPR.  %s\n' "$key"
      unset pass
      return 2
    fi
    if _ssh_reload_try_add "$key" "$pass"; then
      _SSH_RELOAD_KNOWN_PASS="$_SSH_RELOAD_KNOWN_PASS
$pass"
      unset pass
      printf '  OK        %s\n' "$key"
      return 0
    fi
    echo "  Falsche Passphrase."
    try=$((try + 1))
  done
  unset pass
  printf '  FEHLER    %s (%d Fehlversuche)\n' "$key" "$SSH_RELOAD_RETRIES"
  return 1
}

ssh-reload() {
  local keys selected key rc=0 ok=0 skip=0 fail=0 all=false

  while [ $# -gt 0 ]; do
    case "$1" in
    -a | --all) all=true; shift ;;
    -h | --help)
      cat <<'USAGE'
ssh-reload [-a] [KEYFILE...]
  ohne Argumente  Agent neu starten, Keys interaktiv auswählen
  -a, --all       alle privaten Keys aus ~/.ssh laden
  KEYFILE...      genau diese Keys laden
USAGE
      return 0
      ;;
    *) break ;;
    esac
  done

  if [ $# -gt 0 ]; then
    selected=$(printf '%s\n' "$@")
  else
    keys=$(_ssh_reload_list_keys)
    if [ -z "$keys" ]; then
      echo "ssh-reload: keine privaten Schlüssel in $SSH_RELOAD_DIR gefunden." >&2
      return 1
    fi
    if [ "$all" = true ]; then
      selected="$keys"
    else
      selected=$(_ssh_reload_pick "$keys")
    fi
  fi

  if [ -z "$selected" ]; then
    echo "ssh-reload: nichts ausgewählt, Agent bleibt unverändert."
    return 1
  fi

  _ssh_reload_restart_agent || return 1
  echo "Neuer SSH-Agent: $SSH_AUTH_SOCK (PID ${SSH_AGENT_PID:-?})"

  trap '_ssh_reload_cleanup; trap - INT TERM' INT TERM
  _ssh_reload_mk_askpass || { trap - INT TERM; return 1; }
  _SSH_RELOAD_KNOWN_PASS=""

  while IFS= read -r key <&3; do
    [ -z "$key" ] && continue
    if [ ! -f "$key" ]; then
      printf '  FEHLT     %s\n' "$key"
      fail=$((fail + 1))
      continue
    fi
    _ssh_reload_add_key "$key"
    rc=$?
    case "$rc" in
    0) ok=$((ok + 1)) ;;
    2) skip=$((skip + 1)) ;;
    *) fail=$((fail + 1)) ;;
    esac
  done 3<<EOF
$selected
EOF

  unset _SSH_RELOAD_KNOWN_PASS
  _ssh_reload_cleanup
  trap - INT TERM

  printf 'Geladen: %d, übersprungen: %d, fehlgeschlagen: %d\n' "$ok" "$skip" "$fail"
  [ "$fail" -eq 0 ]
}

alias sshr='ssh-reload'
