#!/bin/bash

#eval brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"




# Bash configuration - loads all common shell configs

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all scripts from common/ subdirectory
if [[ -d "$SCRIPT_DIR/common" ]]; then
    for script in "$SCRIPT_DIR/common"/*.sh; do
        if [[ -f "$script" ]]; then
            source "$script"
        fi
    done
fi

# Source bash-specific scripts from common/ subdirectory
if [[ -d "$SCRIPT_DIR/common" ]]; then
    for script in "$SCRIPT_DIR/common"/bash_*.sh; do
        if [[ -f "$script" ]]; then
            source "$script"
        fi
    done
fi






# Bash completion (if available)
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Case-insensitive tab completion
bind "set completion-ignore-case on"

# Show all completions after first tab press
bind "set show-all-if-ambiguous on"
