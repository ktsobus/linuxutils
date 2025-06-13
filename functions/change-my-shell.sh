#!/usr/bin/env bash

# Get the current shell name (without path)
current_shell=$(ps -p $$ -ocomm= | awk -F/ '{print $NF}')

if [[ "$current_shell" == "bash" ]]; then
    shell_path=$(command -v zsh)
    echo "Switching default shell to: $shell_path"
    chsh -s "$shell_path"
elif [[ "$current_shell" == "zsh" ]]; then
    shell_path=$(command -v bash)
    echo "Switching default shell to: $shell_path"
    chsh -s "$shell_path"
else
    echo "Current shell ($current_shell) is neither bash nor zsh. Not changing shell."
    exit 1
fi

