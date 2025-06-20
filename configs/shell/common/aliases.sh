#!/bin/bash
# Common aliases for all shells - essentials only


#Basics
alias cls='clear'
alias lu-dependencies='source ~/linuxutils/dependencies/init.sh'
alias lu-configs='source ~/linuxutils/configs/init.sh'
alias lu-functions='source ~/linuxutils/functions/init.sh'
alias v='vim'

# Navigation
alias ..='cd ..'
alias ll='g --icon --long --sort=name --sh'
alias la='ls -A'
alias ls='g --icon --sort=name'
#alias f='fzf'
alias f='fuzzygrep'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias lg='lazygit'

