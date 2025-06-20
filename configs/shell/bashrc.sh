#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#eval brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#eval oh my posh
eval "$(oh-my-posh init bash --config ~/linuxutils/configs/shell/ohmyposh/custom-zash.omp.json)"

# Case-insensitive tab completion
bind "set completion-ignore-case on"

# Show all completions after first tab press
bind "set show-all-if-ambiguous on"


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

# Source bash-specific scripts from common/ subdirectory
if [[ -d "$SCRIPT_DIR/common" ]]; then
    for script in "$SCRIPT_DIR/common"/bash_*.sh; do
        if [[ -f "$script" ]]; then
            source "$script"
        fi
    done
fi
