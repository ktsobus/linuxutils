#!/bin/bash

# Neovim and LazyVim installation script

# Colors for output (if not already defined)
if [ -z "$GREEN" ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
fi

# Function to print colored output (if not already defined)
if ! type print_status &> /dev/null; then
    print_status() {
        echo -e "${GREEN}[INFO]${NC} $1"
    }
fi

if ! type print_warning &> /dev/null; then
    print_warning() {
        echo -e "${YELLOW}[WARNING]${NC} $1"
    }
fi

if ! type print_error &> /dev/null; then
    print_error() {
        echo -e "${RED}[ERROR]${NC} $1"
    }
fi

print_status "Starting Neovim and LazyVim installation..."

# Check if Homebrew is available
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed. Please run the main setup first."
    return 1
fi

# Check if Neovim is installed
if command -v nvim &> /dev/null; then
    print_status "Neovim is already installed: $(nvim --version | head -n1)"
else
    print_status "Neovim not found. Installing via Homebrew..."
    brew install neovim

    if command -v nvim &> /dev/null; then
        print_status "Neovim installed successfully: $(nvim --version | head -n1)"
    else
        print_error "Neovim installation failed"
        return 1
    fi
fi

# Check if LazyVim is already installed
NVIM_CONFIG_DIR="$HOME/.config/nvim"
LAZYVIM_MARKER="$NVIM_CONFIG_DIR/lua/config/lazy.lua"

if [[ -f "$LAZYVIM_MARKER" ]]; then
    print_status "LazyVim appears to be already installed at $NVIM_CONFIG_DIR"
    print_warning "Skipping LazyVim installation. Remove $NVIM_CONFIG_DIR to reinstall."
    return 0
fi

# Backup existing Neovim configuration if it exists
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    BACKUP_DIR="$NVIM_CONFIG_DIR.bak.$TIMESTAMP"
    print_warning "Existing Neovim config found. Backing up to $BACKUP_DIR"
    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
    print_status "Backup completed: $BACKUP_DIR"
fi

# Backup existing Neovim data directory
NVIM_DATA_DIR="$HOME/.local/share/nvim"
if [[ -d "$NVIM_DATA_DIR" ]]; then
    BACKUP_DATA_DIR="$NVIM_DATA_DIR.bak.$TIMESTAMP"
    print_warning "Existing Neovim data found. Backing up to $BACKUP_DATA_DIR"
    mv "$NVIM_DATA_DIR" "$BACKUP_DATA_DIR"
    print_status "Backup completed: $BACKUP_DATA_DIR"
fi

# Clone LazyVim starter template
print_status "Cloning LazyVim starter template..."
if git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"; then
    print_status "LazyVim starter cloned successfully"
else
    print_error "Failed to clone LazyVim starter"
    return 1
fi

# Remove .git folder from the cloned repository
print_status "Removing .git folder from LazyVim config..."
rm -rf "$NVIM_CONFIG_DIR/.git"

print_status "LazyVim installation completed successfully!"
print_status ""
print_status "Next steps:"
print_status "  1. Run 'nvim' to start Neovim"
print_status "  2. LazyVim will automatically install all plugins on first startup"
print_status "  3. After plugins are installed, run ':LazyHealth' to check the setup"
print_status "  4. Visit https://www.lazyvim.org/ for documentation"
print_status ""
print_warning "Note: First startup may take a few minutes while plugins are installed"

# Check if recommended tools are installed
print_status "Checking recommended tools..."
MISSING_TOOLS=()

if ! command -v fzf &> /dev/null; then
    MISSING_TOOLS+=("fzf")
fi

if ! command -v lazygit &> /dev/null; then
    MISSING_TOOLS+=("lazygit")
fi

if ! command -v rg &> /dev/null; then
    MISSING_TOOLS+=("ripgrep")
fi

if ! command -v fd &> /dev/null; then
    MISSING_TOOLS+=("fd")
fi

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    print_warning "The following recommended tools are not installed: ${MISSING_TOOLS[*]}"
    print_warning "These tools enhance LazyVim functionality. They are available in brew.sh"
else
    print_status "All recommended tools are installed!"
fi
