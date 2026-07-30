#!/usr/bin/env bash
# wird von bash UND zsh gesourct -> alles in einer Funktion, damit nichts leakt

_ssh_agent_loader() {
  [ -n "$ZSH_VERSION" ] && setopt local_options null_glob

  # 1) Agent mit festem Socket-Pfad -> kein Raten in /tmp
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/tmp}/ssh-agent.${USER}.sock"
  ssh-add -l >/dev/null 2>&1
  if [ $? -eq 2 ]; then # 2 = kein Agent erreichbar
    rm -f "$SSH_AUTH_SOCK"
    eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)" >/dev/null
  fi

  # 2) Askpass-Helfer: Passwort kommt aus der Umgebung, nicht aus der Datei
  local askpass_helper
  askpass_helper=$(mktemp) || return 1
  cat >"$askpass_helper" <<'ASKPASS'
#!/usr/bin/env bash
printf '%s\n' "$SSH_PASSPHRASE"
ASKPASS
  chmod 700 "$askpass_helper"

  _try_add() { # $1 = keyfile, $2 = passphrase
    SSH_ASKPASS="$askpass_helper" SSH_ASKPASS_REQUIRE=force DISPLAY=:0 \
      SSH_PASSPHRASE="$2" ssh-add "$1" >/dev/null 2>&1
  }

  # 3) Keys einsammeln
  local key fp loaded_list
  local -a unencrypted encrypted failed
  loaded_list=$(ssh-add -l 2>/dev/null)

  for key in "$HOME"/.ssh/id_*; do
    [ -f "$key" ] || continue
    case "$key" in *.pub) continue ;; esac
    fp=$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
    if [ -n "$fp" ] && printf '%s\n' "$loaded_list" | grep -qF "$fp"; then
      continue # schon im Agent
    fi
    if ssh-keygen -y -P "" -f "$key" >/dev/null 2>&1; then
      unencrypted+=("$key")
    else
      encrypted+=("$key")
    fi
  done

  [ ${#unencrypted[@]} -gt 0 ] && ssh-add "${unencrypted[@]}" >/dev/null 2>&1

  if [ ${#encrypted[@]} -gt 0 ]; then
    local common_pass single_pass
    printf 'Passwort für %d Schlüssel: ' "${#encrypted[@]}"
    read -rs common_pass
    echo

    for key in "${encrypted[@]}"; do
      _try_add "$key" "$common_pass" || failed+=("$key")
    done

    for key in "${failed[@]}"; do
      while true; do
        printf 'Passwort für %s (leer = überspringen): ' "$key"
        read -rs single_pass
        echo
        [ -z "$single_pass" ] && break
        if _try_add "$key" "$single_pass"; then
          echo "Schlüssel $key geladen."
          break
        fi
        echo "Falsches Passwort für $key, bitte erneut."
      done
    done
  fi

  rm -f "$askpass_helper"
  unset -f _try_add
}

_ssh_agent_loader
unset -f _ssh_agent_loader
