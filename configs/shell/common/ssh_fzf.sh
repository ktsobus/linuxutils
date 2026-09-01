# === Config ===
SSH_FZF_SHORTCUT_ACTIVE=true # enable/disable the shortcut
SSH_FZF_SHORTCUT='\es'       # Alt+S (Esc+s). Change if you like.

# --- helper: expand a glob pattern, printing one path per line (bash + zsh) ---
__ssh_fzf_glob() {
  local p
  if [[ -n "$ZSH_VERSION" ]]; then
    setopt localoptions nullglob
    for p in ${~1}; do printf '%s\n' "$p"; done
  else
    (
      shopt -s nullglob
      for p in $1; do printf '%s\n' "$p"; done
    )
  fi
}

# --- helper: ~/.ssh/config plus every file it pulls in via Include, recursively ---
__ssh_fzf_config_files() {
  local file="$1" depth="${2:-0}" pat sub
  [ "$depth" -gt 8 ] && return
  [ -r "$file" ] || return
  printf '%s\n' "$file"
  # Include paths are relative to ~/.ssh unless absolute or ~-prefixed
  sed -nE 's/^[[:space:]]*[Ii]nclude[[:space:]]+(.*[^[:space:]])[[:space:]]*$/\1/p' "$file" |
    while IFS= read -r pat; do
      case "$pat" in
        \~/*) pat="$HOME/${pat#\~/}" ;;
        /*) ;;
        *) pat="$HOME/.ssh/$pat" ;;
      esac
      __ssh_fzf_glob "$pat" | while IFS= read -r sub; do
        __ssh_fzf_config_files "$sub" "$((depth + 1))"
      done
    done
}

# --- helper: every concrete host alias, deduped ---
__ssh_fzf_hosts() {
  local f
  __ssh_fzf_config_files "$HOME/.ssh/config" |
    awk '!seen[$0]++' |
    while IFS= read -r f; do cat "$f"; done |
    awk 'tolower($1) == "host" { for (i = 2; i <= NF; i++) print $i }' |
    grep -v '[*?!]' |
    awk 'NF && !seen[$0]++' |
    sort
}

# --- helper: pick a host with fzf ---
__ssh_fzf_pick_host() {
  __ssh_fzf_hosts |
    fzf --prompt="SSH to > " --height=75% \
      --preview='ssh -G {} 2>/dev/null | grep -E "^(hostname|user|port|proxyjump|remotecommand) "' \
      --preview-window=down,6,wrap
}

# --- ssh wrapper ---
ssh() {
  if [ $# -eq 0 ]; then
    local host
    host=$(__ssh_fzf_pick_host) || return
    [ -z "$host" ] && return

    if [[ -n "$ZSH_VERSION" ]]; then
      print -s "ssh $host"
    else
      history -s "ssh $host"
    fi
    command ssh "$host"
  else
    command ssh "$@"
  fi
}

# --- Shortcut binding ---
if [ "$SSH_FZF_SHORTCUT_ACTIVE" = true ]; then
  if [[ -n "$ZSH_VERSION" ]]; then
    # zsh: turn it into a widget that submits a real command line
    _ssh_fzf_widget() {
      local host
      host=$(__ssh_fzf_pick_host) || return
      [ -z "$host" ] && return
      zle -I # flush pending input/output
      LBUFFER=""
      RBUFFER=""         # clear current line
      BUFFER="ssh $host" # place the command on the line
      zle accept-line    # run it as if you pressed Enter
    }
    zle -N _ssh_fzf_widget
    bindkey "$SSH_FZF_SHORTCUT" _ssh_fzf_widget
  else
    # bash: running directly is fine (TTY preserved)
    bind -x '"'"$SSH_FZF_SHORTCUT"'":"ssh"'
  fi
fi
