# Wrapper for SSH with fzf integration
ssh() {
  if [ $# -eq 0 ]; then
    # Extract all Host entries (excluding wildcards and patterns)
    local host=$(awk '/^Host / { for (i=2; i<=NF; i++) print $i }' ~/.ssh/config | grep -v '[*?]' | fzf --prompt="SSH to > " --height=60% )
    if [ -n "$host" ]; then
      command ssh "$host"
    fi
  else
    # Call original ssh with arguments
    command ssh "$@"
  fi
}

