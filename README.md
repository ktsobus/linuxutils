# LinuxUtils

> A modular, automated setup system for Ubuntu/WSL development environments

LinuxUtils is a comprehensive shell configuration and development environment setup system that automates the installation and configuration of essential development tools, shell environments, and custom utilities through a hierarchical initialization system. It provides a unified configuration for both Bash and Zsh, integrates modern CLI tools with FZF-powered fuzzy finding, and offers smart editor detection with optional Neovim support.

## Table of Contents

- [Features at a Glance](#features-at-a-glance)
- [Quick Start](#quick-start)
  - [Installation](#installation)
  - [First Run](#first-run)
  - [Verify Installation](#verify-installation)
- [What Gets Installed](#what-gets-installed)
  - [System Packages (APT)](#system-packages-apt)
  - [Homebrew Packages](#homebrew-packages)
  - [Snap Packages](#snap-packages)
  - [Development Tools](#development-tools)
  - [Optional: Neovim + LazyVim](#optional-neovim--lazyvim)
- [Architecture](#architecture)
  - [Three-Tier Initialization System](#three-tier-initialization-system)
  - [Execution Flow Diagram](#execution-flow-diagram)
  - [Shell Configuration Chain](#shell-configuration-chain)
- [Custom Features & Utilities](#custom-features--utilities)
  - [FZF Integration](#fzf-integration)
  - [SSH with FZF](#ssh-with-fzf)
  - [Fuzzy Grep Search](#fuzzy-grep-search)
  - [APT Package Browser (fapt)](#apt-package-browser-fapt)
  - [Smart Editor Detection](#smart-editor-detection)
  - [SSH Agent Loader](#ssh-agent-loader)
  - [Custom Neofetch](#custom-neofetch)
- [Usage Guide](#usage-guide)
  - [Common Commands](#common-commands)
  - [Keyboard Shortcuts](#keyboard-shortcuts)
  - [Built-in Aliases](#built-in-aliases)
  - [Re-running Initialization](#re-running-initialization)
- [Customization](#customization)
  - [Adding System Packages](#adding-system-packages)
  - [Adding Shell Configurations](#adding-shell-configurations)
  - [Creating Custom Functions](#creating-custom-functions)
  - [Adding Application Setups](#adding-application-setups)
  - [Creating New Categories](#creating-new-categories)
- [Configuration Details](#configuration-details)
  - [Oh My Zsh Integration](#oh-my-zsh-integration)
  - [SDKMAN Placement](#sdkman-placement)
  - [Editor Preference Order](#editor-preference-order)
  - [File Locations](#file-locations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Features at a Glance

✅ **Automated Setup** - One-command installation of complete development environment
✅ **Idempotent Scripts** - Run setup multiple times without duplicates or conflicts
✅ **Dual Shell Support** - Unified configuration for both Bash and Zsh
✅ **Modern CLI Tools** - FZF, ripgrep, bat, lazygit, lazydocker, and more
✅ **Smart Editor Detection** - Automatically prefers Neovim over Vim
✅ **FZF Everywhere** - Fuzzy finding for files, history, SSH hosts, and packages
✅ **Custom Functions** - Extensible command system with auto-generated aliases
✅ **Oh My Zsh Integration** - Full Zsh plugin ecosystem with custom prompt
✅ **Development Ready** - Node.js (via NVM), JVM tools (via SDKMAN), Docker
✅ **SSH Made Easy** - Smart SSH agent management and FZF host selection

## Quick Start

### Installation

```bash
# Clone the repository
git clone <repo-url> ~/linuxutils
cd ~/linuxutils

# Make setup script executable (if needed)
chmod +x setup.sh
```

### First Run

```bash
# Standard setup (installs everything except Neovim)
./setup.sh

# Setup with Neovim + LazyVim configuration
./setup.sh --nvim

# View help and all options
./setup.sh --help
```

The setup process will:

1. Install and update all system packages
2. Install Oh My Zsh and plugins (if zsh available)
3. Install NVM and Node.js 22
4. Install SDKMAN for JVM tools
5. Install Homebrew and all configured packages
6. Configure shell environments (Bash/Zsh)
7. Set up Vim with plugins
8. Optionally install Neovim + LazyVim

### Verify Installation

```bash
# Restart your terminal or source the configuration
source ~/.bashrc    # for Bash
source ~/.zshrc     # for Zsh

# Test FZF integration
fzf --version

# Test custom commands
fapt --help         # FZF APT package browser
f sometext          # Fuzzy grep search
ssh                 # SSH with FZF host selection (no arguments)

# Check editor preference
echo $EDITOR        # Should show nvim or vim
```

## What Gets Installed

### System Packages (APT)

Core utilities and development tools:

| Package           | Description                                     |
| ----------------- | ----------------------------------------------- |
| `git`             | Version control system                          |
| `tree`            | Directory tree visualization                    |
| `build-essential` | Compilation tools (gcc, make, etc.)             |
| `zsh`             | Z Shell - Modern shell alternative              |
| `neofetch`        | System information display                      |
| `cowsay`          | ASCII art text generator                        |
| `ansiweather`     | Terminal weather display                        |
| `zip` / `unzip`   | Archive utilities                               |
| `tar` / `gzip`    | Compression tools                               |
| `htop`            | Interactive process viewer                      |
| `btop`            | Modern resource monitor                         |
| `ripgrep`         | Fast text search tool (rg)                      |
| `bat`             | Modern cat replacement with syntax highlighting |
| `gdu`             | Fast disk usage analyzer                        |
| `traceroute`      | Network diagnostic tool                         |

### Homebrew Packages

Modern CLI tools installed via Homebrew:

| Package      | Description                      |
| ------------ | -------------------------------- |
| `fzf`        | Command-line fuzzy finder        |
| `oh-my-posh` | Cross-shell prompt theme engine  |
| `lazygit`    | Terminal UI for git commands     |
| `lazydocker` | Terminal UI for docker commands  |
| `g-ls`       | Modern ls replacement with icons |
| `asciinema`  | Terminal session recorder        |
| `agg`        | Asciinema GIF generator          |

### Snap Packages

Containerized applications:

- **Docker** - Container platform for development

### Development Tools

**Node.js** (via NVM)

- Node.js version 22 (LTS)
- Automatically configured with default alias

**SDKMAN**

- Java SDK manager
- Pre-configured for JVM tool installation
- Run `sdk install java` after setup to install Java

**Oh My Zsh Plugins** (if Zsh available)

- `git` - Git aliases and functions
- `colorize` - Syntax highlighting for files
- `colored-man-pages` - Colorful manual pages
- `compleat` - Enhanced completions
- `emoji` - Emoji support in terminal
- `ssh` - SSH helper functions
- `you-should-use` - Reminds you to use existing aliases
- `zsh-autosuggestions` - Fish-like autosuggestions
- `zsh-syntax-highlighting` - Syntax highlighting for commands
- `fast-syntax-highlighting` - Faster syntax highlighting alternative

### Optional: Neovim + LazyVim

When using the `--nvim` flag:

- **Neovim** - Hyperextensible Vim-based text editor
- **LazyVim** - Pre-configured Neovim distribution with plugins
- Automatically backs up existing Neovim configuration
- Installs on first `nvim` startup

## Architecture

### Three-Tier Initialization System

LinuxUtils uses a hierarchical setup orchestrated by `setup.sh`:

```
setup.sh
├── 1. dependencies/init.sh    (System packages & tools)
├── 2. configs/init.sh          (Shell & application configs)
└── 3. functions/init.sh        (Custom functions & aliases)
```

### Execution Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│                    setup.sh                         │
│  Orchestrates all initialization in correct order   │
└─────────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ dependencies/ │ │   configs/    │ │  functions/   │
│    init.sh    │ │    init.sh    │ │    init.sh    │
└───────────────┘ └───────────────┘ └───────────────┘
        │               │               │
        │               │               │
        ▼               ▼               ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│  APT/Brew/    │ │  Shell Configs│ │  Make scripts │
│  Snap Packages│ │  → bashrc.sh  │ │  executable   │
│               │ │  → zshrc.sh   │ │               │
│  NVM/Node.js  │ │               │ │  Generate     │
│               │ │  Application  │ │  aliases for  │
│  SDKMAN/JVM   │ │  setups:      │ │  all custom   │
│               │ │  → setup_*.sh │ │  functions    │
│  Homebrew     │ │               │ │               │
│               │ │  Preserve     │ │  Create       │
│  Oh My Zsh    │ │  SDKMAN at    │ │  functions_   │
│  + plugins    │ │  end of .rc   │ │  aliases.sh   │
│               │ │               │ │               │
│  [Optional]   │ │               │ │               │
│  Neovim +     │ │               │ │               │
│  LazyVim      │ │               │ │               │
└───────────────┘ └───────────────┘ └───────────────┘
```

### Shell Configuration Chain

**Bash Configuration Flow:**

```
~/.bashrc
  │
  └─→ source ~/linuxutils/configs/shell/bashrc.sh
        │
        ├─→ Eval Homebrew shellenv
        ├─→ Initialize oh-my-posh
        ├─→ Configure bash-specific settings
        │
        └─→ Source all common/*.sh files
              ├─→ editor.sh (detect nvim/vim)
              ├─→ fzf.sh (fuzzy finder config)
              ├─→ aliases.sh (common aliases)
              ├─→ ssh_fzf.sh (SSH integration)
              ├─→ fuzzygrep.sh (search function)
              ├─→ fapt.sh (APT browser)
              ├─→ functions_aliases.sh (auto-generated)
              ├─→ neofetch.sh (startup display)
              ├─→ ssh-agent-loader.sh (SSH key management)
              │
              └─→ Source all bash_*.sh files (bash-specific)
```

**Zsh Configuration Flow:**

```
~/.zshrc
  │
  └─→ source ~/linuxutils/configs/shell/zshrc.sh
        │
        ├─→ Initialize Oh My Zsh (if installed)
        ├─→ Eval Homebrew shellenv
        ├─→ Initialize oh-my-posh (overrides OMZ prompt)
        ├─→ Configure zsh-specific settings
        │
        ├─→ Source all common/*.sh files
        │     (same as Bash, see above)
        │
        ├─→ Source all zsh_*.sh files (zsh-specific)
        │
        ├─→ Unalias 'g' (prevent conflict with g-ls)
        │
        ├─→ Initialize NVM
        │
        └─→ Initialize SDKMAN (must be at end!)
```

**Key Points:**

- Both shells share `configs/shell/common/*.sh` files
- Shell-specific files use prefixes: `bash_*.sh` or `zsh_*.sh`
- SDKMAN initialization must always be at the end
- Oh My Zsh integrates seamlessly with custom configurations

## Custom Features & Utilities

### FZF Integration

FZF (fuzzy finder) is deeply integrated throughout the system with custom keybindings:

**Keyboard Shortcuts:**

| Key      | Function       | Description                           |
| -------- | -------------- | ------------------------------------- |
| `Ctrl+T` | File search    | Search and insert file path at cursor |
| `Ctrl+R` | History search | Search command history with preview   |
| `Alt+C`  | Directory jump | Search and cd into directory          |
| `Ctrl+F` | File editor    | Search files and open in vim/nvim     |
| `Ctrl+/` | Toggle preview | Show/hide preview window              |

**Features:**

- Beautiful borders and labels (German localization)
- Live preview with syntax highlighting (bat/batcat)
- Smart file search using `fd` or `fdfind` when available
- Automatic nvim/vim detection for file opening
- Tree preview for directory navigation
- Custom color scheme

### SSH with FZF

Smart SSH connection with fuzzy finding:

```bash
# Run ssh without arguments to get FZF host selector
ssh

# Or use the keyboard shortcut
# Alt+S  - Opens FZF SSH host selector
```

**Features:**

- Reads hosts from `~/.ssh/config`
- Excludes wildcard patterns
- Adds selected command to shell history
- Preserves TTY for interactive sessions
- Works in both Bash and Zsh

### Fuzzy Grep Search

Interactive two-step search tool (aliased as `f`):

```bash
# Search for text across all files
f "searchterm"

# Interactive prompt if no term provided
f
```

**How it works:**

1. **Step 1:** Find all files containing the search term
2. **Step 2:** Select specific match within chosen file
3. **Opens editor** at exact line and column position

**Features:**

- Uses `ripgrep` for blazing fast search
- Preview shows context with syntax highlighting
- Opens vim/nvim at exact match location
- Smart column positioning in editor

### APT Package Browser (fapt)

Interactive APT package browser with beautiful UI:

```bash
# Launch the package browser
fapt

# Also available as
apt-search
```

**Features:**

- Browse all available APT packages with FZF
- Rich preview showing:
  - Package name and version
  - Installation status (color-coded)
  - Description and details
  - Maintainer and homepage
- Install/reinstall packages directly
- Confirmation prompt for already-installed packages
- Beautiful box-drawing characters and colors

### Smart Editor Detection

The system automatically detects and configures your preferred editor:

**Detection Order:**

1. `nvim` (Neovim) - Preferred if installed
2. `vim` (Vim) - Fallback if Neovim unavailable
3. `vi` - Last resort

**Environment Variables Set:**

- `$EDITOR` - Used by git, cron, etc.
- `$VISUAL` - Used by some applications
- `$PREFERRED_EDITOR` - Custom variable for scripts

**Integration:**

- `v` alias points to preferred editor
- FZF file opening uses detected editor
- Fuzzygrep opens files in detected editor
- All custom utilities respect preference

### SSH Agent Loader

Intelligent SSH key management on shell startup:

**Features:**

- Starts ssh-agent if not running
- Reuses existing agent if available
- Automatically detects encrypted vs unencrypted keys
- Loads unencrypted keys silently
- For encrypted keys:
  - Prompts once for common password
  - Tries common password on all encrypted keys
  - Individual prompts for keys with different passwords
  - Validates each key before moving to next
- No duplicate key loading

**Behavior:**

- Runs automatically on shell initialization
- Silent for unencrypted keys
- Interactive only when necessary
- Secure password handling (no echoing)

### Custom Neofetch

Enhanced system information display on shell startup:

**Features:**

- ASCII art with cowsay (flaming-sheep)
- Live weather for Solothurn, CH
- Color-coded by shell:
  - Zsh: Pink/Gold
  - Bash: Cyan
  - Others: White
- Only runs if all dependencies available
- Falls back to standard neofetch

## Usage Guide

### Common Commands

**Setup & Maintenance:**

```bash
# Show help and options
./setup.sh -h
./setup.sh --help

# Full setup
./setup.sh

# Setup with Neovim
./setup.sh --nvim

# Update all system packages
sau

# Re-run specific initialization
lu-dependencies        # Re-run dependency installation
lu-dependencies --nvim # With Neovim installation
lu-configs             # Re-configure shells
lu-functions           # Regenerate function aliases
```

**File & Directory Navigation:**

```bash
# Change to parent directory
..

# List files with icons
ls              # g-ls with icons
ll              # Long format with icons, sorted by name

# Search and open file
Ctrl+F          # Interactive file search
```

**Search & Find:**

```bash
# Fuzzy grep search
f "searchterm"          # Search and open at exact match
fuzzygrep "searchterm"  # Same as above

# FZF search (interactive)
Ctrl+T          # File search, insert path
Ctrl+R          # Command history
Alt+C           # Directory search and cd
```

**SSH:**

```bash
# SSH with host selection
ssh             # Opens FZF host picker
Alt+S           # Keyboard shortcut for host picker

# Traditional SSH still works
ssh user@host
```

**Package Management:**

```bash
# Interactive APT browser
fapt
apt-search      # Same as above

# System update
sau             # Update APT, Snap, Homebrew
```

**Git:**

```bash
gs              # git status
ga              # git add
lg              # lazygit (terminal UI)
```

**Editor:**

```bash
v file.txt      # Open in preferred editor (nvim/vim)
```

**Shell:**

```bash
# Switch default shell
change-my-shell # Toggle between bash and zsh
```

**Network:**

```bash
# Unset all proxy variables
unset-proxys
```

### Keyboard Shortcuts

**FZF Integration:**

- `Ctrl+T` - Search files and insert path
- `Ctrl+R` - Search command history
- `Alt+C` - Search and change directory
- `Ctrl+F` - Search and open file in editor
- `Ctrl+/` - Toggle preview in FZF
- `Alt+S` - SSH host selector (FZF)

**Bash Specific:**

- Tab completion is case-insensitive
- First tab shows all ambiguous completions

**Zsh Specific:**

- `Ctrl+R` - Incremental backward search

### Built-in Aliases

**Essential:**

```bash
cls                    # Clear screen
v                      # nvim or vim (auto-detected)
sau                    # System update (APT + Snap + Brew)
```

**Navigation:**

```bash
..                     # cd ..
ls                     # g --icon --sort=name
ll                     # g --icon --long --sort=name --sh
la                     # ls -A
```

**Git:**

```bash
gs                     # git status
ga                     # git add
lg                     # lazygit
```

**Search:**

```bash
f                      # fuzzygrep (search and edit)
```

**Setup:**

```bash
lu-dependencies        # Re-run dependencies/init.sh
lu-configs             # Re-run configs/init.sh
lu-functions           # Re-run functions/init.sh
```

**Network:**

```bash
unset-proxys          # Unset all proxy environment variables
```

**Package Management:**

```bash
apt-search            # fapt (APT package browser)
```

### Re-running Initialization

After making changes to configurations:

**Shell Configuration Changes:**

```bash
# Apply changes without restarting terminal
source ~/.bashrc      # For Bash
source ~/.zshrc       # For Zsh

# Or use the alias after re-running config init
lu-configs
source ~/.bashrc      # or ~/.zshrc
```

**Added New Function:**

```bash
# Regenerate aliases and reload
lu-functions
source ~/.bashrc      # or ~/.zshrc
```

**Added New Package:**

```bash
# Edit apt.sh, brew.sh, or snap.sh, then:
lu-dependencies
```

**Full Re-initialization:**

```bash
cd ~/linuxutils
./setup.sh           # Run full setup again (idempotent)
```

## Customization

### Adding System Packages

**APT Packages:**

1. Edit `dependencies/apt.sh`
2. Add package name to `APT_PACKAGES` array:

```bash
APT_PACKAGES=(
    "git"
    "vim"
    "your-new-package"  # Add here
)
```

3. Run: `lu-dependencies`

**Homebrew Packages:**

1. Edit `dependencies/brew.sh`
2. Add to `BREW_PACKAGES` or `BREW_CASKS` array:

```bash
BREW_PACKAGES=(
    "fzf"
    "your-new-package"  # Add here
)
```

3. Run: `lu-dependencies`

**Snap Packages:**

1. Edit `dependencies/snap.sh`
2. Add to `SNAP_PACKAGES` array:

```bash
SNAP_PACKAGES=(
    "docker"
    "your-new-package"  # Add here
)
```

3. Run: `lu-dependencies`

### Adding Shell Configurations

Create files in `configs/shell/common/`:

**For Both Shells:**

```bash
# Create a new configuration file
touch configs/shell/common/my-feature.sh

# Add your configuration
echo 'export MY_VAR="value"' >> configs/shell/common/my-feature.sh
echo 'alias myalias="command"' >> configs/shell/common/my-feature.sh

# No additional setup needed - automatically loaded on next shell start
```

**Bash Only:**

```bash
# Create bash-specific configuration
touch configs/shell/common/bash_my-feature.sh
```

**Zsh Only:**

```bash
# Create zsh-specific configuration
touch configs/shell/common/zsh_my-feature.sh
```

**Apply Changes:**

```bash
source ~/.bashrc    # or ~/.zshrc
```

### Creating Custom Functions

Custom scripts in `functions/` become globally available commands:

**Example:**

```bash
# Create a new function
cat > functions/backup-db.sh << 'EOF'
#!/bin/bash
echo "Backing up database..."
# Your backup logic here
EOF

# Regenerate aliases
lu-functions

# Reload shell
source ~/.bashrc    # or ~/.zshrc

# Now available as command (without .sh)
backup-db
```

**How it works:**

- `functions/init.sh` makes all `*.sh` files executable
- Auto-generates alias for each script (minus `.sh` extension)
- Aliases stored in `configs/shell/common/functions_aliases.sh`
- Scripts can be run from anywhere in the system

### Adding Application Setups

Application-specific configurations go in `configs/applications/`:

**Example:**

```bash
# Create application setup script
cat > configs/applications/setup_myapp.sh << 'EOF'
#!/bin/bash

print_status "Setting up MyApp..."

# Your setup logic here
# - Create config files
# - Symlink configurations
# - Install plugins
# - etc.

print_status "MyApp setup complete!"
EOF

# Run configs initialization
lu-configs
```

**Auto-discovery:**

- All `setup_*.sh` files are automatically found and executed
- Use `print_status`, `print_warning`, `print_error` for consistent output
- Check `configs/applications/setup_vim.sh` for a complete example

### Creating New Categories

Add completely new initialization categories:

**Example:**

```bash
# Create new category directory
mkdir -p ~/linuxutils/cloud-tools

# Create initialization script
cat > ~/linuxutils/cloud-tools/init.sh << 'EOF'
#!/bin/bash

print_status "Setting up cloud tools..."

# Install AWS CLI
# Install Azure CLI
# Install GCloud SDK
# Configure credentials
# etc.

print_status "Cloud tools setup complete!"
EOF

# Make executable
chmod +x ~/linuxutils/cloud-tools/init.sh

# Run full setup (auto-discovers new category)
cd ~/linuxutils
./setup.sh
```

**Note:** To control execution order, edit `SETUP_ORDER` array in `setup.sh`:

```bash
SETUP_ORDER=("dependencies" "configs" "cloud-tools")
```

## Configuration Details

### Oh My Zsh Integration

When Oh My Zsh is installed, the system:

1. **Initializes Oh My Zsh first** (with empty theme)
2. **Sources Homebrew environment** for package availability
3. **Initializes oh-my-posh** (overrides Oh My Zsh prompt)
4. **Sources all common configs** (see Shell Configuration Chain)
5. **Unaliases `g`** to prevent conflict with `g-ls` (git alias from OMZ)

**Active Plugins:**

- `git` - Git aliases and functions
- `colorize` - Syntax highlighting for files
- `colored-man-pages` - Colorful manual pages
- `compleat` - Enhanced completions
- `emoji` - Emoji support
- `ssh` - SSH helper functions
- `you-should-use` - Alias usage reminders
- `zsh-autosuggestions` - Fish-like suggestions
- `zsh-syntax-highlighting` - Command syntax highlighting
- `fast-syntax-highlighting` - Alternative faster highlighting

### SDKMAN Placement

**Critical Rule:** SDKMAN initialization must be at the end of shell configs.

**Why?** SDKMAN modifies PATH and other variables that can interfere with other tools if loaded too early.

**How it's handled:**

- `configs/init.sh` automatically detects existing SDKMAN lines
- Removes them temporarily during configuration
- Adds custom config sourcing
- Re-adds SDKMAN lines at the very end

**Manual Verification:**

```bash
# Check that SDKMAN is at the end
tail ~/.bashrc    # or ~/.zshrc

# Should see these lines at the bottom:
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

### Editor Preference Order

The system detects and configures editors in this priority:

1. **Neovim** (`nvim`) - Preferred if available
2. **Vim** (`vim`) - Fallback option
3. **Vi** (`vi`) - Last resort

**Environment Variables:**

```bash
echo $EDITOR            # nvim, vim, or vi
echo $VISUAL            # Same as $EDITOR
echo $PREFERRED_EDITOR  # Custom variable for scripts
```

**Where it's used:**

- `v` alias in `configs/shell/common/aliases.sh`
- FZF file opening in `configs/shell/common/fzf.sh`
- Fuzzygrep in `configs/shell/common/fuzzygrep.sh`
- Any custom scripts can use `$PREFERRED_EDITOR`

### File Locations

**Configuration Files:**

```
~/.bashrc                    # Modified to source bashrc.sh
~/.zshrc                     # Replaced/modified to source zshrc.sh
~/.vimrc                     # Symlinked to configs/applications/vim/vimrc
```

**LinuxUtils Locations:**

```
~/linuxutils/                                  # Main directory
├── setup.sh                                   # Main setup script
├── dependencies/init.sh                       # Package installation
├── configs/init.sh                            # Configuration setup
├── configs/shell/bashrc.sh                    # Bash configuration
├── configs/shell/zshrc.sh                     # Zsh configuration
├── configs/shell/common/                      # Shared shell configs
│   ├── aliases.sh                            # Common aliases
│   ├── editor.sh                             # Editor detection
│   ├── fzf.sh                                # FZF configuration
│   ├── fuzzygrep.sh                          # Fuzzy grep function
│   ├── ssh_fzf.sh                            # SSH with FZF
│   ├── fapt.sh                               # APT package browser
│   ├── ssh-agent-loader.sh                   # SSH agent management
│   ├── neofetch.sh                           # System info display
│   ├── functions_aliases.sh                  # Auto-generated aliases
│   ├── bash_*.sh                             # Bash-specific configs
│   └── zsh_*.sh                              # Zsh-specific configs
├── configs/shell/ohmyposh/custom-zash.omp.json  # Oh-my-posh theme
├── configs/applications/                      # Application setups
│   ├── setup_vim.sh                          # Vim setup script
│   └── vim/                                  # Vim configuration
│       ├── vimrc                             # Vim config file
│       └── plugins.vim                       # Vim plugins
└── functions/                                 # Custom functions directory
    ├── init.sh                               # Functions initialization
    └── *.sh                                  # Custom function scripts
```

**Oh My Zsh:**

```
~/.oh-my-zsh/                # Oh My Zsh installation
~/.oh-my-zsh/custom/plugins/ # Custom OMZ plugins
```

**Development Tools:**

```
~/.nvm/                      # Node Version Manager
~/.sdkman/                   # SDKMAN installation
/home/linuxbrew/.linuxbrew/  # Homebrew installation
```

## Troubleshooting

**Shell configuration not loading:**

```bash
# Check if linuxutils is sourced in rc file
grep "linuxutils" ~/.bashrc    # or ~/.zshrc

# If missing, re-run configs
lu-configs
source ~/.bashrc    # or ~/.zshrc
```

**FZF not working:**

```bash
# Check if FZF is installed
fzf --version

# Reinstall via dependencies
lu-dependencies

# Or install directly
brew install fzf
```

**Custom function not available:**

```bash
# Check if script exists and is executable
ls -la ~/linuxutils/functions/

# Regenerate aliases
lu-functions
source ~/.bashrc    # or ~/.zshrc
```

**Vim plugins not installed:**

```bash
# Open vim and manually install
vim +PlugInstall +qall

# Or re-run configs
lu-configs
```

**SDKMAN not working:**

```bash
# Check if SDKMAN is at end of rc file
tail ~/.bashrc    # or ~/.zshrc

# If not, re-run configs (handles SDKMAN placement)
lu-configs
source ~/.bashrc    # or ~/.zshrc
```

**Oh My Zsh conflicts:**

```bash
# The system handles OMZ integration automatically
# If issues persist, backup and remove .zshrc
mv ~/.zshrc ~/.zshrc.backup
lu-configs
```

**Neovim LazyVim issues:**

```bash
# Check if Neovim is installed
nvim --version

# Reinstall LazyVim
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
lu-dependencies --nvim

# Or install manually
./setup.sh --nvim
```

**PATH issues after setup:**

```bash
# Ensure Homebrew is in PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Check PATH
echo $PATH

# Restart terminal to apply all changes
```

**SSH agent not loading keys:**

```bash
# Check if ssh-agent is running
ps aux | grep ssh-agent

# Check loaded keys
ssh-add -l

# Manually reload
source ~/linuxutils/configs/shell/common/ssh-agent-loader.sh
```

**Package installation fails:**

```bash
# Update package lists first
sudo apt update

# Check for held packages
sudo apt-mark showhold

# Try installing package manually to see error
sudo apt install <package-name>
```

## Contributing

Contributions are welcome! Here's how you can help:

**Adding Features:**

1. Fork the repository
2. Create a feature branch
3. Add your feature following existing patterns:
   - New packages → Edit `dependencies/*.sh`
   - New shell configs → Add to `configs/shell/common/`
   - New utilities → Add to `functions/`
   - New app setup → Add to `configs/applications/`
4. Test thoroughly on clean Ubuntu/WSL instance
5. Submit pull request with clear description

**Reporting Issues:**

- Use GitHub issues
- Include: OS version, shell type, error messages
- Describe steps to reproduce

**Best Practices:**

- Keep scripts idempotent (safe to run multiple times)
- Use `print_status`, `print_warning`, `print_error` for output
- Test in both Bash and Zsh if adding shell configs
- Document new features in README
- Follow existing code style

---

**Note:** This project is tailored for Ubuntu/WSL environments. Some features may require adaptation for other Linux distributions.
