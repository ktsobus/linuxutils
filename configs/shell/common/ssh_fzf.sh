# Wrapper for SSH with fzf integration
ssh() {
  if [ $# -eq 0 ]; then
    # Extract all Host entries (excluding wildcards and patterns)
    local host=$(awk '/^Host / { for (i=2; i<=NF; i++) print $i }' ~/.ssh/config | grep -v '[*?]' | sort | fzf --prompt="SSH to > " --height=75% )
    if [ -n "$host" ]; then

      if [[ -n "$ZSH_VERSION" ]]; then
        print -s "ssh $host"
      else
        history -s "ssh $host"
      fi

      command ssh "$host"

    fi
  else
    # Call original ssh with arguments
    command ssh "$@"
  fi
}

