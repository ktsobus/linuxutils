#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Starting system setup and dependency installation..."

# Update and upgrade apt packages
print_status "Updating apt package lists..."
sudo apt update

print_status "Upgrading apt packages..."
sudo apt upgrade -y

print_status "Cleaning up apt packages..."
sudo apt autoremove -y
sudo apt autoclean

# Source and run apt dependencies
if [[ -f "$SCRIPT_DIR/apt.sh" ]]; then
    print_status "Loading APT dependencies..."
    source "$SCRIPT_DIR/apt.sh"
    install_apt_packages "${APT_PACKAGES[@]}"
else
    print_warning "apt.sh not found in $SCRIPT_DIR"
fi

# Check if Node.js is installed
if command -v node &> /dev/null; then
    print_status "Node.js found: $(node --version)"
else
    print_warning "Node.js not found. Installing via NVM..."
    
    # Check if NVM is already installed
    if [[ ! -f "$HOME/.nvm/nvm.sh" ]]; then
        print_status "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        
        # Source NVM for current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        
        if command -v nvm &> /dev/null; then
            print_status "NVM installed successfully"
        else
            print_error "NVM installation failed"
        fi
    else
        print_status "NVM already installed, loading..."
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Install Node.js 22 with NVM
    if command -v nvm &> /dev/null; then
        print_status "Installing Node.js 22..."
        nvm install 22
        nvm use 22
        nvm alias default 22
        print_status "Node.js installed: $(node --version)"
        print_warning "Note: You may need to restart your terminal or source your shell config"
        print_warning "NVM commands will be available after restarting your shell"
    else
        print_error "NVM not available, cannot install Node.js"
    fi
fi

# Check if brew is installed
if command -v brew &> /dev/null; then
    print_status "Homebrew found. Updating and upgrading brew packages..."
    brew update
    brew upgrade
    brew cleanup
    
    # Source and run brew dependencies
    if [[ -f "$SCRIPT_DIR/brew.sh" ]]; then
        print_status "Loading Homebrew dependencies..."
        source "$SCRIPT_DIR/brew.sh"
        install_brew_packages "${BREW_PACKAGES[@]}"
        install_brew_casks "${BREW_CASKS[@]}"
    else
        print_warning "brew.sh not found in $SCRIPT_DIR"
    fi
    
    print_status "Homebrew packages updated successfully!"
else
    print_warning "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add brew to PATH for current session
    if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        print_status "Homebrew installed successfully!"
        
        # Now install brew dependencies
        if [[ -f "$SCRIPT_DIR/brew.sh" ]]; then
            print_status "Loading Homebrew dependencies..."
            source "$SCRIPT_DIR/brew.sh"
            install_brew_packages "${BREW_PACKAGES[@]}"
            install_brew_casks "${BREW_CASKS[@]}"
        else
            print_warning "brew.sh not found in $SCRIPT_DIR"
        fi
        
        print_warning "Note: You may need to add Homebrew to your PATH permanently."
        print_warning "Add this line to your ~/.bashrc or ~/.zshrc:"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    else
        print_error "Homebrew installation may have failed. Please check the output above."
    fi
fi

print_status "All operations completed!"
print_status "Summary:"
print_status "- System packages updated via APT"
print_status "- Custom APT packages installed from apt.sh"
if command -v node &> /dev/null; then
    print_status "- Node.js available: $(node --version)"
fi
print_status "- Homebrew updated/installed"
print_status "- Custom Homebrew packages installed from brew.sh"
