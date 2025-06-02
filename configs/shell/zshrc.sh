#!/bin/bash
# Zsh configuration - loads all common shell configs

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Zsh-specific settings
# Enable auto-completion
autoload -U compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Better history search
bindkey '^R' history-incremental-search-backward


# Source all scripts from common/ subdirectory (except shell-specific ones)
if [[ -d "$SCRIPT_DIR/common" ]]; then
    for script in "$SCRIPT_DIR/common"/*.sh; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            # Skip bash_ and zsh_ prefixed files (handled separately)
            if [[ ! "$script_name" =~ ^(bash_|zsh_) ]]; then
                source "$script"
            fi
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
