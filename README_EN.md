# LinuxUtils

> A modular, automated setup system for Ubuntu/WSL development environments

[![Deutsch](https://img.shields.io/badge/lang-Deutsch-blue)](README.md)

LinuxUtils automates the installation and configuration of development tools, shell environments, and custom utilities through a hierarchical initialization system. It provides a unified configuration for Bash and Zsh, integrates modern CLI tools with FZF-powered fuzzy finding, and automatically detects the preferred editor.

## Table of Contents

- [Quick Start](#quick-start)
  - [Installation](#installation)
  - [First Run](#first-run)
  - [Verify Installation](#verify-installation)
- [Features](#features)
- [Usage](#usage)
  - [Commands & Aliases](#commands--aliases)
  - [Keyboard Shortcuts](#keyboard-shortcuts)
  - [FZF Tools](#fzf-tools)
  - [SSH Agent](#ssh-agent)
  - [Fastfetch](#fastfetch)
- [What Gets Installed](#what-gets-installed)
  - [System Packages (APT)](#system-packages-apt)
  - [Homebrew Packages](#homebrew-packages)
  - [Snap Packages](#snap-packages)
  - [Development Tools](#development-tools)
  - [Oh My Zsh Plugins](#oh-my-zsh-plugins)
  - [Optional: Neovim + LazyVim](#optional-neovim--lazyvim)
- [Architecture](#architecture)
  - [Three-Tier Initialization](#three-tier-initialization)
  - [Shell Configuration Chain](#shell-configuration-chain)
  - [File Structure](#file-structure)
- [Customization](#customization)
  - [Adding Packages](#adding-packages)
  - [Adding Shell Configuration](#adding-shell-configuration)
  - [Creating Custom Functions](#creating-custom-functions)
  - [Adding Application Setup](#adding-application-setup)
  - [Creating a New Category](#creating-a-new-category)
- [Configuration Details](#configuration-details)
  - [Oh My Zsh Integration](#oh-my-zsh-integration)
  - [SDKMAN Placement](#sdkman-placement)
  - [Editor Preference](#editor-preference)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

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

The setup process performs the following steps:

1. Install and update all system packages
2. Install Oh My Zsh and plugins (if Zsh is available)
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
fapt                # FZF APT package browser
f searchterm        # Fuzzy grep search
ssh                 # SSH with FZF host selection (no arguments)

# Check editor preference
echo $EDITOR        # Should show nvim or vim
```

## Features

- **Automated Setup** — One command installs the complete development environment
- **Idempotent Scripts** — Run multiple times without duplicates or conflicts
- **Dual Shell Support** — Unified configuration for both Bash and Zsh
- **Modern CLI Tools** — FZF, ripgrep, bat, lazygit, lazydocker, and more
- **Smart Editor Detection** — Automatically prefers Neovim over Vim; sets `$EDITOR`, `$VISUAL`, and `$PREFERRED_EDITOR`
- **FZF Everywhere** — Fuzzy finding for files, history, SSH hosts, and APT packages
- **Custom Functions** — Extensible command system with auto-generated aliases
- **Oh My Zsh Integration** — Full Zsh plugin ecosystem with oh-my-posh prompt
- **Development Ready** — Node.js (via NVM), JVM tools (via SDKMAN), Docker
- **SSH Made Easy** — Smart SSH agent management and FZF host selection

## Usage

### Commands & Aliases

**Setup & Maintenance:**

| Alias | Command | Description |
|-------|---------|-------------|
| `sau` | `apt update && upgrade + snap refresh + brew upgrade` | Update all packages, restart shell |
| `lu-dependencies` | `source ~/linuxutils/dependencies/init.sh` | Re-run dependency installation |
| `lu-dependencies --nvim` | — | With Neovim installation |
| `lu-configs` | `source ~/linuxutils/configs/init.sh` | Re-configure shells |
| `lu-functions` | `source ~/linuxutils/functions/init.sh` | Regenerate function aliases |

**Navigation:**

| Alias | Command | Description |
|-------|---------|-------------|
| `..` | `cd ..` | Go up one directory |
| `ls` | `g --icon --sort=name` | List files with icons |
| `ll` | `g --icon --long --sort=name --sh` | Long format listing with icons |
| `la` | `ls -A` | List all files including hidden |
| `cls` | `clear` | Clear screen |

**Editor:**

| Alias | Command | Description |
|-------|---------|-------------|
| `v` | `nvim` or `vim` | Open preferred editor (auto-detected) |

**Git:**

| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Show git status |
| `ga` | `git add` | Stage files |
| `lg` | `lazygit` | Terminal UI for git |

**Search:**

| Alias | Command | Description |
|-------|---------|-------------|
| `f` | `fuzzygrep` | Interactive text search with FZF (see [FZF Tools](#fzf-tools)) |

**Packages:**

| Alias | Command | Description |
|-------|---------|-------------|
| `fapt` / `apt-search` | — | Interactive APT package browser (see [FZF Tools](#fzf-tools)) |

**Network:**

| Alias | Command | Description |
|-------|---------|-------------|
| `unset-proxys` | `unset HTTP_PROXY HTTPS_PROXY ...` | Unset all proxy variables |

**Shell:**

| Alias | Command | Description |
|-------|---------|-------------|
| `change-my-shell` | — | Switch between Bash and Zsh |

### Keyboard Shortcuts

All FZF keyboard shortcuts at a glance:

| Key | Function | Description |
|-----|----------|-------------|
| `Ctrl+T` | File search | Search and insert file path at cursor position |
| `Ctrl+R` | History search | Search command history with preview |
| `Alt+C` | Directory jump | Search and cd into directory |
| `Ctrl+F` | File editor | Search files and open in vim/nvim |
| `Ctrl+/` | Toggle preview | Show/hide preview window |
| `Alt+S` | SSH host picker | Start FZF-based SSH connection |

### FZF Tools

#### Fuzzy Grep Search (`f` / `fuzzygrep`)

Interactive two-step text search across all files:

```bash
f "searchterm"     # Search directly
f                  # Interactive prompt
```

**How it works:**

1. **Step 1:** Find all files containing the search term (via `ripgrep`)
2. **Step 2:** Select a specific match within the chosen file
3. **Editor** opens at the exact line and column position

The preview shows context with syntax highlighting (via `bat`).

#### APT Package Browser (`fapt` / `apt-search`)

Interactive APT package browser with detailed preview:

```bash
fapt               # Launch package browser
apt-search          # Same function
```

**Preview shows:**
- Package name and version
- Installation status (color-coded)
- Description, category, maintainer, and homepage

Packages can be installed directly from the browser. For already-installed packages, a confirmation prompt for reinstallation/update is shown.

#### SSH with FZF (`ssh` / `Alt+S`)

Smart SSH with fuzzy host selection:

```bash
ssh                 # Without arguments: FZF host selection from ~/.ssh/config
ssh user@host       # Traditional SSH still works
# Alt+S             # Keyboard shortcut for host selection
```

**How it works:**
- Reads hosts from `~/.ssh/config` (excluding wildcards)
- Adds the selected command to shell history
- Preserves TTY for interactive sessions
- Works in both Bash and Zsh

### SSH Agent

Smart SSH key management on shell startup:

- Starts `ssh-agent` automatically if not running
- Reuses existing agent if available
- Automatically detects encrypted vs. unencrypted keys
- Loads unencrypted keys silently
- For encrypted keys:
  - Prompts once for a common password
  - Tries that password on all encrypted keys
  - Individual prompt only for keys with different passwords
- No duplicate key loading

### Fastfetch

Customized system information display on shell startup:

- ASCII art with `cowsay` (Tux penguin)
- Live weather for Solothurn, CH (via `ansiweather`)
- Color-coded by shell: Zsh (purple), Bash (cyan), others (white)
- Falls back to standard fastfetch if dependencies are missing

## What Gets Installed

### System Packages (APT)

| Package | Description |
|---------|-------------|
| `git` | Version control system |
| `tree` | Directory tree visualization |
| `build-essential` | Compilation tools (gcc, make, etc.) |
| `zsh` | Z Shell — Modern shell alternative |
| `fastfetch` | System information display |
| `cowsay` | ASCII art text generator |
| `ansiweather` | Terminal weather display |
| `zip` / `unzip` | Archive utilities |
| `tar` / `gzip` | Compression tools |
| `htop` | Interactive process viewer |
| `btop` | Modern resource monitor |
| `ripgrep` | Fast text search tool (`rg`) |
| `bat` | Modern `cat` replacement with syntax highlighting |
| `gdu` | Fast disk usage analyzer |
| `traceroute` | Network diagnostic tool |

### Homebrew Packages

| Package | Description |
|---------|-------------|
| `fzf` | Command-line fuzzy finder |
| `oh-my-posh` | Cross-shell prompt theme engine |
| `lazygit` | Terminal UI for git |
| `lazydocker` | Terminal UI for Docker |
| `g-ls` | Modern `ls` replacement with icons |
| `asciinema` | Terminal session recorder |
| `agg` | Asciinema GIF generator |
| `snitch` | Network traffic monitor |

### Snap Packages

- **Docker** — Container platform for development

### Development Tools

**Node.js** (via NVM)
- Node.js version 22 (LTS)
- Automatically configured as default

**SDKMAN**
- Java SDK manager for JVM tools
- Run `sdk install java` after setup to install Java

### Oh My Zsh Plugins

The following plugins are automatically installed and activated (if Zsh is available):

| Plugin | Description |
|--------|-------------|
| `git` | Git aliases and functions |
| `colorize` | Syntax highlighting for files |
| `colored-man-pages` | Colorful manual pages |
| `compleat` | Enhanced tab completion |
| `emoji` | Emoji support in terminal |
| `ssh` | SSH helper functions |
| `you-should-use` | Reminds you to use existing aliases |
| `zsh-autosuggestions` | Fish-like autosuggestions |
| `zsh-syntax-highlighting` | Syntax highlighting for commands |
| `fast-syntax-highlighting` | Faster syntax highlighting alternative |

### Optional: Neovim + LazyVim

When using the `--nvim` flag:

- **Neovim** — Hyperextensible Vim-based text editor
- **LazyVim** — Pre-configured Neovim distribution with plugins
- Automatically backs up existing Neovim configuration
- Plugins are installed on first `nvim` startup

## Architecture

### Three-Tier Initialization

LinuxUtils uses a hierarchical setup orchestrated by `setup.sh`:

```
┌─────────────────────────────────────────────────────┐
│                    setup.sh                         │
│  Orchestrates all initialization in the             │
│  correct order                                      │
└─────────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ dependencies/ │ │   configs/    │ │  functions/   │
│    init.sh    │ │    init.sh    │ │    init.sh    │
└───────────────┘ └───────────────┘ └───────────────┘
        │               │               │
        ▼               ▼               ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│  APT/Brew/    │ │  Shell Configs│ │  Make scripts │
│  Snap Packages│ │  → bashrc.sh  │ │  executable   │
│               │ │  → zshrc.sh   │ │               │
│  NVM/Node.js  │ │               │ │  Generate     │
│               │ │  Applications:│ │  aliases for  │
│  SDKMAN/JVM   │ │  → setup_*.sh │ │  all custom   │
│               │ │               │ │  functions    │
│  Homebrew     │ │  Preserve     │ │               │
│               │ │  SDKMAN at    │ │               │
│  Oh My Zsh    │ │  end of .rc   │ │               │
│  + Plugins    │ │  files        │ │               │
│               │ │               │ │               │
│  [Optional]   │ │               │ │               │
│  Neovim +     │ │               │ │               │
│  LazyVim      │ │               │ │               │
└───────────────┘ └───────────────┘ └───────────────┘
```

**Tier 1 — Dependencies** (`dependencies/init.sh`): Installs and updates all system packages (APT, Snap, Homebrew), development tools (NVM, SDKMAN), Oh My Zsh with plugins, and optionally Neovim.

**Tier 2 — Configs** (`configs/init.sh`): Modifies `~/.bashrc` and `~/.zshrc` to source custom shell configurations. Automatically runs all `applications/setup_*.sh` scripts. Ensures SDKMAN exports remain at the end of shell files.

**Tier 3 — Functions** (`functions/init.sh`): Makes all `*.sh` scripts in `functions/` executable and auto-generates aliases (without `.sh` extension) in `configs/shell/common/functions_aliases.sh`.

### Shell Configuration Chain

Both shells load shared configurations from `configs/shell/common/`:

**Bash:**
```
~/.bashrc → configs/shell/bashrc.sh → common/*.sh → common/bash_*.sh
```

**Zsh:**
```
~/.zshrc → configs/shell/zshrc.sh → Oh My Zsh → common/*.sh → common/zsh_*.sh
```

**Important details:**
- Files in `common/` are loaded by both shells (except those prefixed with `bash_` or `zsh_`)
- `zshrc.sh` replaces the default Oh My Zsh `.zshrc` but preserves SDKMAN configuration
- Oh My Zsh is initialized with an empty theme; `oh-my-posh` takes over the prompt
- The `g` alias is removed after Oh My Zsh to prevent conflicts with `g-ls`
- Homebrew shellenv is loaded early to ensure all Brew commands are available

### File Structure

```
~/linuxutils/
├── setup.sh                                   # Main setup script
├── README.md                                  # Documentation (German)
├── README_EN.md                               # Documentation (English)
│
├── dependencies/                              # Tier 1: Package installation
│   ├── init.sh                                # Main dependency script
│   ├── apt.sh                                 # APT package list
│   ├── brew.sh                                # Homebrew package list
│   ├── snap.sh                                # Snap package list
│   └── nvim.sh                                # Neovim + LazyVim setup
│
├── configs/                                   # Tier 2: Configurations
│   ├── init.sh                                # Configuration setup
│   ├── shell/
│   │   ├── bashrc.sh                          # Bash configuration
│   │   ├── zshrc.sh                           # Zsh configuration
│   │   ├── common/                            # Shared shell configs
│   │   │   ├── aliases.sh                     # General aliases
│   │   │   ├── editor.sh                      # Editor detection
│   │   │   ├── fzf.sh                         # FZF configuration & keybindings
│   │   │   ├── fuzzygrep.sh                   # Fuzzy grep function
│   │   │   ├── ssh_fzf.sh                     # SSH with FZF
│   │   │   ├── fapt.sh                        # APT package browser
│   │   │   ├── ssh-agent-loader.sh            # SSH agent management
│   │   │   ├── fastfetch.sh                   # System info display
│   │   │   ├── functions_aliases.sh           # Auto-generated aliases
│   │   │   ├── bash_*.sh                      # Bash-only configs
│   │   │   └── zsh_*.sh                       # Zsh-only configs
│   │   └── ohmyposh/
│   │       └── custom-zash.omp.json           # Oh-my-posh theme
│   └── applications/
│       ├── setup_vim.sh                       # Vim setup
│       └── vim/                               # Vim configuration
│           ├── vimrc                          # → Symlinked to ~/.vimrc
│           └── plugins.vim                    # Vim plugins
│
└── functions/                                 # Tier 3: Custom functions
    ├── init.sh                                # Functions initialization
    └── change-my-shell.sh                     # Shell switching utility
```

## Customization

### Adding Packages

**APT packages** — Edit `dependencies/apt.sh`:

```bash
APT_PACKAGES=(
    "git"
    "vim"
    "new-package"    # Add here
)
```

**Homebrew packages** — Edit `dependencies/brew.sh`:

```bash
BREW_PACKAGES=(
    "fzf"
    "new-package"    # Add here
)
```

**Snap packages** — Edit `dependencies/snap.sh`:

```bash
SNAP_PACKAGES=(
    "docker"
    "new-package"    # Add here
)
```

Then run: `lu-dependencies`

### Adding Shell Configuration

Create new files in `configs/shell/common/`:

```bash
# For both shells (Bash + Zsh)
configs/shell/common/my-feature.sh

# Bash only
configs/shell/common/bash_my-feature.sh

# Zsh only
configs/shell/common/zsh_my-feature.sh
```

Files are automatically loaded on next shell start — no additional setup needed. To load immediately:

```bash
source ~/.bashrc    # or ~/.zshrc
```

### Creating Custom Functions

Scripts in `functions/` become globally available commands:

```bash
# Create a new script
cat > functions/backup-db.sh << 'EOF'
#!/bin/bash
echo "Backing up database..."
# Backup logic here
EOF

# Regenerate aliases and reload shell
lu-functions
source ~/.bashrc    # or ~/.zshrc

# Now available as a command (without .sh)
backup-db
```

**How it works:**
- `functions/init.sh` makes all `*.sh` files executable
- Auto-generates an alias for each script (without `.sh` extension)
- Aliases are stored in `configs/shell/common/functions_aliases.sh`

### Adding Application Setup

Place application-specific configurations in `configs/applications/`:

```bash
# Create setup script (must start with setup_)
configs/applications/setup_my-app.sh
```

All `setup_*.sh` files are automatically discovered and executed by `configs/init.sh`. Use `print_status`, `print_warning`, and `print_error` for consistent output. See `configs/applications/setup_vim.sh` as a reference.

### Creating a New Category

Create a new directory with an `init.sh` file — `setup.sh` will automatically find and execute it:

```bash
mkdir ~/linuxutils/cloud-tools
# Create cloud-tools/init.sh with setup logic
```

Execution order can be controlled via `SETUP_ORDER` in `setup.sh`.

## Configuration Details

### Oh My Zsh Integration

When Oh My Zsh is installed, `zshrc.sh` performs the following steps:

1. Initialize Oh My Zsh (with empty theme to avoid conflicts)
2. Load Homebrew environment (for package availability)
3. Initialize `oh-my-posh` (overrides Oh My Zsh prompt)
4. Source all shared configs
5. Remove `g` alias (prevents conflict with `g-ls` — the `g` alias comes from the Oh My Zsh git plugin)

### SDKMAN Placement

SDKMAN exports **must** be at the end of shell configuration files. SDKMAN modifies PATH and other variables that can interfere with other tools if loaded too early.

`configs/init.sh` handles this automatically:
1. Detects existing SDKMAN lines
2. Removes them temporarily
3. Adds custom config sourcing line
4. Re-adds SDKMAN lines at the end

**Verification:**

```bash
tail ~/.bashrc    # or ~/.zshrc

# Should show at the end:
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

### Editor Preference

The system automatically detects and configures the preferred editor:

**Detection order:** `nvim` → `vim` → `vi`

**Environment variables set:**

| Variable | Description |
|----------|-------------|
| `$EDITOR` | Used by git, cron, etc. |
| `$VISUAL` | Used by some applications |
| `$PREFERRED_EDITOR` | Custom variable for scripts |

**Where it's used:**
- `v` alias in `aliases.sh`
- FZF file opening (`Ctrl+F`) in `fzf.sh`
- Fuzzygrep in `fuzzygrep.sh`
- Custom scripts can use `$PREFERRED_EDITOR`

## Troubleshooting

**Shell configuration not loading:**

```bash
# Check if linuxutils is sourced in RC file
grep "linuxutils" ~/.bashrc    # or ~/.zshrc

# If missing, re-run configs
lu-configs
source ~/.bashrc    # or ~/.zshrc
```

**FZF not working:**

```bash
fzf --version           # Check installation
brew install fzf        # Install directly
# or: lu-dependencies   # Re-install everything
```

**Custom function not available:**

```bash
ls -la ~/linuxutils/functions/    # Script exists and is executable?
lu-functions                       # Regenerate aliases
source ~/.bashrc                   # Reload shell
```

**Vim plugins not installed:**

```bash
vim +PlugInstall +qall    # Install plugins manually
# or: lu-configs          # Re-run configuration
```

**SDKMAN not working:**

```bash
tail ~/.bashrc    # Is SDKMAN at the end of the file?
lu-configs        # Re-run configuration (handles placement)
source ~/.bashrc
```

**Oh My Zsh conflicts:**

```bash
# The system handles OMZ integration automatically
# If issues persist:
mv ~/.zshrc ~/.zshrc.backup
lu-configs
```

**Neovim/LazyVim issues:**

```bash
nvim --version                    # Is Neovim installed?

# Completely reinstall LazyVim
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
lu-dependencies --nvim
```

**PATH issues after setup:**

```bash
# Ensure Homebrew is in PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo $PATH

# Restart terminal to apply all changes
```

**SSH agent not loading keys:**

```bash
ps aux | grep ssh-agent                                     # Is the agent running?
ssh-add -l                                                  # Check loaded keys
source ~/linuxutils/configs/shell/common/ssh-agent-loader.sh  # Manually reload
```

**Package installation fails:**

```bash
sudo apt update                  # Update package lists
sudo apt-mark showhold           # Check for held packages
sudo apt install <package-name>  # Install manually for error details
```

## Contributing

Contributions are welcome! Here's how you can help:

**Adding features:**

1. Fork the repository
2. Create a feature branch
3. Implement your feature following existing patterns:
   - New packages → Edit `dependencies/*.sh`
   - New shell configs → Add to `configs/shell/common/`
   - New utilities → Add to `functions/`
   - New app setup → Add to `configs/applications/`
4. Test thoroughly on a clean Ubuntu/WSL instance
5. Submit a pull request with a clear description

**Important conventions:**

- Scripts must be **idempotent** (safe to run multiple times)
- Use `print_status`, `print_warning`, `print_error` for output
- Test shell configurations in **both Bash and Zsh**
- SDKMAN exports must remain at the **end** of shell files
- Update README in **both languages** (DE + EN)

**Reporting issues:**

- Use GitHub Issues
- Include: OS version, shell type, error messages
- Describe steps to reproduce

---

**Note:** This project is tailored for Ubuntu/WSL environments. Some features may require adaptation for other Linux distributions.
