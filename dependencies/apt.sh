#!/bin/bash

# APT packages to install
APT_PACKAGES=(
    "git"
    "tree"
    "build-essential"
    "zsh"
    "neofetch"
    "cowsay"
    "ansiweather"
    "zip"
    "unzip"
    "htop"
    "tar"
    "gzip"
    "btop"
    "ripgrep"
    "traceroute"
)

# Function to install APT packages
install_apt_packages() {
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        print_warning "No APT packages specified to install."
        return 0
    fi
    
    print_status "Installing APT packages: ${packages[*]}"
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            print_status "$package is already installed."
        else
            print_status "Installing $package..."
            sudo apt install -y "$package"
        fi
    done
    
    print_status "APT package installation completed!"
}

# Run the installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_apt_packages "${APT_PACKAGES[@]}"
fi
