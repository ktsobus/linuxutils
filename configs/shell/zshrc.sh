# Zsh configuration - loads Oh My Zsh first, then all common shell configs

# Get the directory where this script is located (zsh-safe!)
SCRIPT_DIR="${0:A:h}"

# Load Oh My Zsh if available (before other configurations)
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    # Set Oh My Zsh path
    export ZSH="$HOME/.oh-my-zsh"
    
    # Set theme to a minimal one that won't conflict with oh-my-posh
    ZSH_THEME=""
    
    # Disable Oh My Zsh's prompt override to let oh-my-posh handle it
    DISABLE_AUTO_TITLE="true"
    
    # Build plugins array with only available plugins
    plugins=(git colorize colored-man-pages compleat emoji ssh you-should-use zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting)
    
    # Source Oh My Zsh
    if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
        source "$ZSH/oh-my-zsh.sh"
    fi
fi

# eval brew (after Oh My Zsh to ensure proper PATH)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

#eval oh my posh (after Oh My Zsh to override prompt)
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config ~/linuxutils/configs/shell/ohmyposh/custom-zash.omp.json)"
fi

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

# unload g alias bc of g-ls
unalias g


#eval nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
