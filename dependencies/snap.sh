#!/bin/bash

# SNAP packages to install
SNAP_PACKAGES=(
    "docker"
    "bat"
)

# Function to print status messages
print_status() {
    echo -e "\033[1;34m[STATUS]\033[0m $1"
}

# Function to print warning messages
print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

# Function to install SNAP packages
install_snap_packages() {
    local packages=("$@")

    if [ ${#packages[@]} -eq 0 ]; then
        print_warning "No SNAP packages specified to install."
        return 0
    fi

    print_status "Installing SNAP packages: ${packages[*]}"

    for package in "${packages[@]}"; do
        if snap list | awk '{print $1}' | grep -qx "$package"; then
            print_status "$package is already installed."
        else
            print_status "Installing $package..."
            sudo snap install "$package"
        fi
    done

    print_status "SNAP package installation completed!"
}

# Run the installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_snap_packages "${SNAP_PACKAGES[@]}"
fi
