#!/bin/bash
# Setup script for Vim

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup existing vimrc
if [[ -f "$HOME/.vimrc" ]]; then
    cp "$HOME/.vimrc" "$HOME/.vimrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Link configuration
ln -sf "$SCRIPT_DIR/vim/vimrc" "$HOME/.vimrc"

echo "Vim configuration setup complete!"
