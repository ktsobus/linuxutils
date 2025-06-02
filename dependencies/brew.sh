#!/bin/bash

# Homebrew packages to install
BREW_PACKAGES=(
    "fzf"
    "bat"
    "jandedobbeleer/oh-my-posh/oh-my-posh"
    "jesseduffield/lazygit/lazygit"
)

# Homebrew casks to install (GUI applications)
BREW_CASKS=(
    # Add your desired casks here
)

# Function to install Homebrew packages
install_brew_packages() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        print_warning "No Homebrew packages specified to install."
        return 0
    fi
    
    print_status "Installing Homebrew packages: ${packages[*]}"
    
    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            print_status "$package is already installed."
        else
            print_status "Installing $package..."
            brew install "$package"
        fi
    done
    
    print_status "Homebrew package installation completed!"
}

# Function to install Homebrew casks
install_brew_casks() {
    local casks=("$@")
    
    if [ ${#casks[@]} -eq 0 ]; then
        print_warning "No Homebrew casks specified to install."
        return 0
    fi
    
    print_status "Installing Homebrew casks: ${casks[*]}"
    
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            print_status "$cask is already installed."
        else
            print_status "Installing $cask..."
            brew install --cask "$cask"
        fi
    done
    
    print_status "Homebrew cask installation completed!"
}

# Run the installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if command -v brew &> /dev/null; then
        install_brew_packages "${BREW_PACKAGES[@]}"
        install_brew_casks "${BREW_CASKS[@]}"
    else
        print_error "Homebrew is not installed!"
        exit 1
    fi
fi
