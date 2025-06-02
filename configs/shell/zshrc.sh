#!/bin/bash
# Zsh configuration - loads all common shell configs

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

# Source zsh-specific scripts from common/ subdirectory
if [[ -d "$SCRIPT_DIR/common" ]]; then
    for script in "$SCRIPT_DIR/common"/zsh_*.sh; do
        if [[ -f "$script" ]]; then
            source "$script"
        fi
    done
fi



# Zsh-specific settings
# Enable auto-completion
autoload -U compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Better history search
bindkey '^R' history-incremental-search-backward
