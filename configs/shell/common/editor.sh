#!/bin/bash
# Editor configuration - prefer nvim over vim

# Detect and set preferred editor
if command -v nvim &> /dev/null; then
    export EDITOR="nvim"
    export VISUAL="nvim"
    # Set convenience variable for scripts to use
    export PREFERRED_EDITOR="nvim"
elif command -v vim &> /dev/null; then
    export EDITOR="vim"
    export VISUAL="vim"
    export PREFERRED_EDITOR="vim"
else
    export EDITOR="vi"
    export VISUAL="vi"
    export PREFERRED_EDITOR="vi"
fi
