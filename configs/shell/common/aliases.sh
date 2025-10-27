#!/bin/bash
# Common aliases for all shells - essentials only


#Basics
alias cls='clear'
alias lu-dependencies='source ~/linuxutils/dependencies/init.sh'
alias lu-configs='source ~/linuxutils/configs/init.sh'
alias lu-functions='source ~/linuxutils/functions/init.sh'
# Use nvim if available, otherwise fallback to vim
if command -v nvim &> /dev/null; then
    alias v='nvim'
else
    alias v='vim'
fi
alias sau='sudo apt update && sudo apt upgrade -y && sudo snap refresh && brew upgrade'

# Navigation
alias ..='cd ..'
alias ll='g --icon --long --sort=name --sh'
alias la='ls -A'
alias ls='g --icon --sort=name'
#alias f='fzf'

alias f="fuzzygrep"

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias lg='lazygit'

# network
alias unset-proxys='unset HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy ALL_PROXY all_proxy'
