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


print_status "Refreshing snap packages..."
sudo snap refresh

print_status "Removing unused snap revisions..."
sudo snap set system refresh.retain=2

# Find disabled snaps and remove them if any exist
DISABLED_SNAPS=$(snap list --all | awk '/disabled/{print $1, $2}')
if [[ -n "$DISABLED_SNAPS" ]]; then
    while read -r snapname version; do
        sudo snap remove --purge "$snapname" --revision="$version"
    done <<< "$DISABLED_SNAPS"
else
    print_status "No unused snap revisions to remove."
fi

# Source and run snap dependencies
if [[ -f "$SCRIPT_DIR/snap.sh" ]]; then
    print_status "Loading SNAP dependencies..."
    source "$SCRIPT_DIR/snap.sh"
    install_snap_packages "${SNAP_PACKAGES[@]}"
else
    print_warning "snap.sh not found in $SCRIPT_DIR"
fi

# Check if Oh My Zsh is installed (only if zsh is available)
if command -v zsh &> /dev/null; then
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        # Install Oh My Zsh without changing shell automatically
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        
        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            print_status "Oh My Zsh installed successfully"
        else
            print_error "Oh My Zsh installation may have failed"
        fi
    else
        print_status "Oh My Zsh already installed, checking for updates..."
        # Update Oh My Zsh using its built-in upgrade mechanism
        if [[ -f "$HOME/.oh-my-zsh/tools/upgrade.sh" ]]; then
            # Run the upgrade script in non-interactive mode
            env ZSH="$HOME/.oh-my-zsh" sh "$HOME/.oh-my-zsh/tools/upgrade.sh" --unattended
            print_status "Oh My Zsh update completed"
        else
            # Fallback: try to pull latest changes manually
            print_warning "Upgrade script not found, attempting manual update..."
            cd "$HOME/.oh-my-zsh" && git pull origin master 2>/dev/null && cd - >/dev/null
            print_status "Oh My Zsh update attempted"
        fi
    fi
    
    # Install popular Oh My Zsh plugins if Oh My Zsh is available
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
        
        # Install zsh-autosuggestions
        if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
            print_status "Installing zsh-autosuggestions plugin..."
            git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        else
            print_status "Updating zsh-autosuggestions plugin..."
            cd "$ZSH_CUSTOM/plugins/zsh-autosuggestions" && git pull origin master 2>/dev/null && cd - >/dev/null
        fi
        
        # Install zsh-syntax-highlighting
        if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
            print_status "Installing zsh-syntax-highlighting plugin..."
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        else
            print_status "Updating zsh-syntax-highlighting plugin..."
            cd "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" && git pull origin master 2>/dev/null && cd - >/dev/null
        fi
        
        # Install fast-syntax-highlighting (alternative to zsh-syntax-highlighting)
        if [[ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]]; then
            print_status "Installing fast-syntax-highlighting plugin..."
            git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
        else
            print_status "Updating fast-syntax-highlighting plugin..."
            cd "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" && git pull origin master 2>/dev/null && cd - >/dev/null
        fi

        # Install you-should-use
        if [[ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]]; then
                print_status "Installing you-should-use"
                git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
        else
                print_status "Updating you should use"
                cd "$ZSH_CUSTOM/plugins/you-should-use" && git pull origin master 2>/dev/null && cd - >/dev/null
        fi
        
        print_status "Oh My Zsh plugins installation/update completed"
    fi
else
    print_warning "Zsh not available, skipping Oh My Zsh installation"
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

# Check if SDKMAN is installed
if [[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    print_status "SDKMAN found"
else
    print_warning "SDKMAN not found. Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    
    # Source SDKMAN for current session
    if [[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        print_status "SDKMAN installed successfully"
        print_warning "Note: SDKMAN will be available after restarting your terminal"
        print_warning "You can then install Java with: sdk install java"
    else
        print_error "SDKMAN installation may have failed"
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
if command -v zsh &> /dev/null && [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_status "- Oh My Zsh installed and available"
fi
if command -v node &> /dev/null; then
    print_status "- Node.js available: $(node --version)"
fi
if [[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    print_status "- SDKMAN installed and available"
fi
print_status "- Homebrew updated/installed"
print_status "- Custom Homebrew packages installed from brew.sh"
