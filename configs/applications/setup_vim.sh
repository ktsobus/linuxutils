#!/bin/bash
# Setup script for Vim with vim-plug

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

print_status "Setting up Vim configuration..."

# Create backup directory
BACKUP_DIR="$HOME/.vim/backups"
mkdir -p "$BACKUP_DIR"

# Backup existing vimrc
if [[ -f "$HOME/.vimrc" ]]; then
    backup_file="$BACKUP_DIR/vimrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.vimrc" "$backup_file"
    print_warning "Backed up existing .vimrc to $backup_file"
fi

# Install vim-plug if not already installed
if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
    print_status "Installing vim-plug..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if [[ $? -eq 0 ]]; then
        print_status "vim-plug installed successfully"
    else
        print_error "Failed to install vim-plug"
        return 1
    fi
else
    print_status "vim-plug already installed"
fi

# Link vimrc configuration
if [[ -f "$SCRIPT_DIR/vim/vimrc" ]]; then
    ln -sf "$SCRIPT_DIR/vim/vimrc" "$HOME/.vimrc"
    print_status "Linked vim configuration"
else
    print_error "vimrc not found at $SCRIPT_DIR/vim/vimrc"
    return 1
fi

# Link plugins configuration (so it's always up to date)
if [[ -f "$SCRIPT_DIR/vim/plugins.vim" ]]; then
    mkdir -p "$HOME/.vim"
    ln -sf "$SCRIPT_DIR/vim/plugins.vim" "$HOME/.vim/plugins.vim"
    print_status "Linked vim plugins configuration"
else
    print_warning "plugins.vim not found, skipping plugin setup"
fi

# Install plugins automatically
print_status "Installing vim plugins..."
vim +PlugInstall +qall

print_status "Vim configuration setup complete!"
print_status "You can run ':PlugInstall' in vim to install/update plugins anytime"
