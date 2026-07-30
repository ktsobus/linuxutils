#!/bin/bash

# APT packages to install
APT_PACKAGES=(
    "git"
    "tree"
    "build-essential"
    "zsh"
    "fastfetch"
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
    "bat"
    "gdu"
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
_lu_sourced=0
if [ -n "${ZSH_VERSION:-}" ]; then
    case "${ZSH_EVAL_CONTEXT:-}" in *:file*) _lu_sourced=1;; esac
elif [ -n "${BASH_VERSION:-}" ]; then
    [[ "${BASH_SOURCE[0]}" != "${0}" ]] && _lu_sourced=1
fi

# Run the installation only if this script is executed directly
if [[ "$_lu_sourced" -eq 0 ]]; then
    install_apt_packages "${APT_PACKAGES[@]}"
fi
