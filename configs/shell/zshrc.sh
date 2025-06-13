# Zsh configuration - loads all common shell configs

# eval brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

#eval nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"


# Get the directory where this script is located (zsh-safe!)
SCRIPT_DIR="${0:A:h}"

# Zsh-specific settings
autoload -U compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Where the history file is stored
HISTFILE=~/.zsh_history

# How many lines to keep in memory
HISTSIZE=5000

# How many lines to keep on disk
SAVEHIST=10000

# Some recommended history options:
setopt HIST_IGNORE_DUPS       # No duplicate entries in history
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt HIST_VERIFY            # Don't run line from history immediately
setopt SHARE_HISTORY          # Share history across all zsh sessions (optional)
setopt INC_APPEND_HISTORY     # Write history immediately, not just on shell exit

bindkey '^R' history-incremental-search-backward

# Source all scripts from common/ subdirectory (except shell-specific ones)
if [[ -d "$SCRIPT_DIR/common" ]]; then
    for script in "$SCRIPT_DIR/common"/*.sh; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            # Skip bash_ and zsh_ prefixed files (handled separately)
            if [[ "$script_name" != (bash_|zsh_)* ]]; then
                source "$script"
            fi
        fi
    done
fi

# Source zsh-specific scripts from common/ subdirectory
if [[ -d "$SCRIPT_DIR/common" ]]; then
    setopt null_glob
    for script in "$SCRIPT_DIR/common"/zsh_*.sh; do
        if [[ -f "$script" ]]; then
            source "$script"
        fi
    done
    unsetopt null_glob
fi

