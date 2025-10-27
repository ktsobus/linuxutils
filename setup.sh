#!/bin/bash

# Parse command line arguments
EXTRA_ARGS=""
for arg in "$@"; do
    case $arg in
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "LinuxUtils setup script - Automates installation and configuration of development tools"
            echo ""
            echo "OPTIONS:"
            echo "  -h, --help    Show this help message"
            echo "  --nvim        Install Neovim and LazyVim configuration (passed to dependencies/init.sh)"
            echo ""
            echo "EXAMPLES:"
            echo "  $0                # Run full setup without Neovim"
            echo "  $0 --nvim         # Run full setup and install Neovim + LazyVim"
            exit 0
            ;;
        --nvim)
            EXTRA_ARGS="$EXTRA_ARGS --nvim"
            ;;
    esac
done

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

print_status "Starting linuxutils setup..."

# Define execution order (dependencies first)
SETUP_ORDER=("dependencies" "configs")

# Run init.sh scripts in specified order
for subdirectory in "${SETUP_ORDER[@]}"; do
    init_script="$SCRIPT_DIR/$subdirectory/init.sh"
    
    if [[ -f "$init_script" ]]; then
        print_status "Running setup for $subdirectory..."

        # Change to the subdirectory and run the init script
        # Pass extra args only to dependencies
        if [[ "$subdirectory" == "dependencies" ]]; then
            cd "$SCRIPT_DIR/$subdirectory" && bash init.sh $EXTRA_ARGS
        else
            cd "$SCRIPT_DIR/$subdirectory" && bash init.sh
        fi

        if [[ $? -eq 0 ]]; then
            print_status "$subdirectory setup completed successfully"
        else
            print_error "$subdirectory setup failed"
        fi

        # Return to main directory
        cd "$SCRIPT_DIR"
        echo ""
    else
        print_warning "No init.sh found in $subdirectory/"
    fi
done

# Run any other init.sh scripts not in the ordered list
for init_script in "$SCRIPT_DIR"/*/init.sh; do
    if [[ -f "$init_script" ]]; then
        subdirectory=$(basename "$(dirname "$init_script")")
        
        # Skip if already processed
        if [[ " ${SETUP_ORDER[*]} " == *" $subdirectory "* ]]; then
            continue
        fi
        
        print_status "Running setup for $subdirectory..."

        # Change to the subdirectory and run the init script
        # Pass extra args only to dependencies
        if [[ "$subdirectory" == "dependencies" ]]; then
            cd "$(dirname "$init_script")" && bash init.sh $EXTRA_ARGS
        else
            cd "$(dirname "$init_script")" && bash init.sh
        fi

        if [[ $? -eq 0 ]]; then
            print_status "$subdirectory setup completed successfully"
        else
            print_error "$subdirectory setup failed"
        fi

        # Return to main directory
        cd "$SCRIPT_DIR"
        echo ""
    fi
done

print_status "All setup completed!"
print_warning "Please restart your terminal to apply all changes"
