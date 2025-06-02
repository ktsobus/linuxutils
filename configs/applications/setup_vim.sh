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

# Backup existing vimrc
if [[ -f "$HOME/.vimrc" ]]; then
    if [ ! -d "$HOME/.vimrc-backup" ]; then
            mkdir "$HOME/.vimrc-backup"
    fi
    cp "$HOME/.vimrc" "$HOME/.vimrc-backup/$(date +%Y%m%d_%H%M%S)"
    print_warning "Backed up existing .vimrc"
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

# Create combined vimrc with plugins
if [[ -f "$SCRIPT_DIR/vim/plugins.vim" ]]; then
    # Append plugins configuration to vimrc
    cat "$SCRIPT_DIR/vim/plugins.vim" >> "$HOME/.vimrc"
    print_status "Added plugins configuration to vimrc"
else
    print_warning "plugins.vim not found, skipping plugin setup"
fi

# Install plugins automatically
print_status "Installing vim plugins..."
vim +PlugInstall +qall

print_status "Vim configuration setup complete!"
print_status "You can run ':PlugInstall' in vim to install/update plugins anytime"
