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

print_status "Setting up shell configurations..."

# Function to add source line to shell config
add_source_line() {
    local shell_name="$1"
    local config_file="$2"
    local source_file="$SCRIPT_DIR/shell/${shell_name}rc.sh"
    local source_line="source \"$source_file\""
    
    # Create config file if it doesn't exist
    touch "$config_file"
    
    # Check if already sourced
    if grep -Fq "$source_line" "$config_file"; then
        print_warning "$shell_name configuration already sourced in $config_file"
        return 0
    fi
    
    # Check if SDKMAN lines exist and move them to the end
    if grep -q "SDKMAN" "$config_file"; then
        print_status "Moving SDKMAN configuration to end of $config_file"
        
        # Extract SDKMAN lines
        sdkman_lines=$(grep -A1 -B1 "SDKMAN" "$config_file")
        
        # Remove SDKMAN lines from file
        sed -i '/SDKMAN/d' "$config_file"
        sed -i '/sdkman-init.sh/d' "$config_file"
        
        # Add personal source line
        echo "" >> "$config_file"
        echo "# Source personal $shell_name configuration" >> "$config_file"
        echo "$source_line" >> "$config_file"
        
        # Re-add SDKMAN lines at the end
        echo "" >> "$config_file"
        echo "#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!" >> "$config_file"
        echo "export SDKMAN_DIR=\"\$HOME/.sdkman\"" >> "$config_file"
        echo "[[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\"" >> "$config_file"
    else
        # Add source line normally
        echo "" >> "$config_file"
        echo "# Source personal $shell_name configuration" >> "$config_file"
        echo "$source_line" >> "$config_file"
    fi
}

# Setup Bash
if [[ -f "$SCRIPT_DIR/shell/bashrc.sh" ]]; then
    add_source_line "bash" "$HOME/.bashrc"
else
    print_error "bashrc.sh not found at $SCRIPT_DIR/shell/bashrc.sh"
fi

# Setup Zsh (if zsh is installed)
if command -v zsh &> /dev/null; then
    if [[ -f "$SCRIPT_DIR/shell/zshrc.sh" ]]; then
        add_source_line "zsh" "$HOME/.zshrc"
    else
        print_error "zshrc.sh not found at $SCRIPT_DIR/shell/zshrc.sh"
    fi
else
    print_warning "Zsh not installed, skipping zsh configuration"
fi

# Setup applications
print_status "Setting up applications..."

# Source application setup scripts
for setup_script in "$SCRIPT_DIR/applications/setup_"*.sh; do
    if [[ -f "$setup_script" ]]; then
        app_name=$(basename "$setup_script" | sed 's/setup_//' | sed 's/.sh//')
        print_status "Setting up $app_name..."
        source "$setup_script"
    fi
done

print_status "All configurations setup completed!"
print_warning "Please restart your terminal or run 'source ~/.bashrc' to apply changes"
