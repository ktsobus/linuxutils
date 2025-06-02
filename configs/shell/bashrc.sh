#!/bin/bash

#eval brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common configurations
source "$SCRIPT_DIR/aliases.sh"

# Bash completion (if available)
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Case-insensitive tab completion
bind "set completion-ignore-case on"

# Show all completions after first tab press
bind "set show-all-if-ambiguous on"
