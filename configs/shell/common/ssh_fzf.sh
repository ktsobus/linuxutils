# === Config ===
SSH_FZF_SHORTCUT_ACTIVE=true     # enable/disable the shortcut
SSH_FZF_SHORTCUT='\es'           # Alt+S (Esc+s). Change if you like.

# --- helper: pick a host with fzf ---
__ssh_fzf_pick_host() {
  awk '/^Host / { for (i=2; i<=NF; i++) print $i }' ~/.ssh/config \
    | grep -v '[*?]' \
    | sort \
    | fzf --prompt="SSH to > " --height=75%
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
      zle -I                 # flush pending input/output
      LBUFFER=""; RBUFFER="" # clear current line
      BUFFER="ssh $host"     # place the command on the line
      zle accept-line        # run it as if you pressed Enter
    }
    zle -N _ssh_fzf_widget
    bindkey "$SSH_FZF_SHORTCUT" _ssh_fzf_widget
  else
    # bash: running directly is fine (TTY preserved)
    bind -x '"'"$SSH_FZF_SHORTCUT"'":"ssh"'
  fi
fi

