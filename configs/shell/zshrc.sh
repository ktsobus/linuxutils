#!/bin/bash
# Zsh configuration - loads all common shell configs

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common configurations
source "$SCRIPT_DIR/aliases.sh"

# Zsh-specific settings
# Enable auto-completion
autoload -U compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Better history search
bindkey '^R' history-incremental-search-backward
