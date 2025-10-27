# LinuxUtils

Modulares Setup-System für Ubuntu/WSL Instanzen.
Beinhaltet [fzf-utils](https://gitlab.so.ch/solerbus/fzf-utils)

## Quick Start

```bash
git clone <repo-url>
cd linuxutils
./setup.sh         # Standard setup
./setup.sh --nvim  # Setup with Neovim + LazyVim
./setup.sh -h      # Show help
```

## Wie es funktioniert

`setup.sh` führt alle `init.sh` in Subdirectories aus:
1. `dependencies/init.sh` (zuerst)
2. `configs/init.sh` (dann)
3. `functions/init.sh` (zuletzt)

### Dependencies Flow
```
dependencies/init.sh [--nvim]
├── apt update/upgrade
├── source apt.sh → install APT_PACKAGES[]
├── snap refresh
├── source snap.sh → install SNAP_PACKAGES[]
├── Oh My Zsh → install + plugins (if zsh available)
├── NVM → install Node.js 22
├── SDKMAN → install JVM tools
├── brew install/update → source brew.sh → install BREW_PACKAGES[]
└── [--nvim] Neovim + LazyVim (optional)
```

### Configs Flow
```
configs/init.sh
├── bashrc sourcing: echo "source path/to/bashrc.sh" >> ~/.bashrc
├── zshrc sourcing: replace ~/.zshrc + preserve SDKMAN (am Ende)
└── applications: source alle setup_*.sh
```

### Functions Flow
```
functions/init.sh
├── chmod +x alle *.sh scripts
└── generiert functions_aliases.sh → shell/common/
```

### Shell Config Chain
```
~/.bashrc → bashrc.sh → common/*.sh + common/bash_*.sh
~/.zshrc → zshrc.sh → common/*.sh + common/zsh_*.sh
```

## Struktur

```
dependencies/
├── init.sh        # orchestriert package installation + NVM + SDKMAN
├── apt.sh         # APT_PACKAGES=("curl" "git" "vim" ...)
├── snap.sh        # SNAP_PACKAGES=()
└── brew.sh        # BREW_PACKAGES=() + BREW_CASKS=()

configs/
├── init.sh        # orchestriert config setup
├── shell/
│   ├── bashrc.sh     # lädt common/* + bash-specific
│   ├── zshrc.sh      # lädt common/* + zsh-specific
│   ├── ohmyposh/     # oh-my-posh themes
│   └── common/
│       ├── aliases.sh            # für beide shells (v alias: nvim > vim)
│       ├── editor.sh             # editor detection (nvim > vim > vi)
│       ├── fzf.sh                # fzf configuration (uses nvim if available)
│       ├── ssh_fzf.sh            # SSH mit fzf
│       ├── ssh-agent-loader.sh   # SSH agent setup
│       ├── fapt.sh               # APT helper utilities
│       ├── fuzzygrep.sh          # fuzzy grep function (uses nvim if available)
│       ├── neofetch.sh           # neofetch configuration
│       ├── functions_aliases.sh  # auto-generated function aliases
│       └── bash_*.sh / zsh_*.sh  # shell-spezifische files
└── applications/
    ├── setup_vim.sh  # vim + plugins setup
    └── vim/
        ├── vimrc     # vim configuration
        └── plugins.vim # vim-plug plugins

functions/
└── init.sh          # macht *.sh executable + erstellt aliases
```

## Neues hinzufügen

**Package:** Array in `apt.sh` oder `brew.sh` erweitern

**Shell Config:** File in `configs/shell/common/` erstellen:
```bash
# Für beide shells
shell/common/docker_aliases.sh
shell/common/git_functions.sh

# Nur für bash
shell/common/bash_completions.sh

# Nur für zsh
shell/common/zsh_features.sh
```

**Custom Function:** Script in `functions/` erstellen:
```bash
# functions/backup-db.sh
#!/bin/bash
echo "Backing up database..."
# wird automatisch als 'backup-db' alias verfügbar
```

**App:** `configs/applications/setup_newapp.sh` erstellen:
```bash
#!/bin/bash
# wird automatisch von configs/init.sh gefunden und ausgeführt
```

**Neue Kategorie:** Directory mit `init.sh` erstellen (wird von `setup.sh` gefunden)

## Features

- **Komplettes Development Setup**: APT packages, Homebrew, Node.js (NVM), JVM tools (SDKMAN)
- **Modulare Shell Configs**: Gemeinsame + shell-spezifische Konfigurationen
- **Custom Functions**: Eigene Scripts als global verfügbare Commands
- **Application Setup**: Automatisierte Tool-Konfiguration (Vim, etc.)
- **SSH Integration**: SSH agent + FZF integration für easy connections
- **Modern Tools**: FZF, ripgrep, bat, g-ls, neofetch, lazygit, lazydocker, oh-my-posh und mehr
- **Optional Neovim**: LazyVim installation via `--nvim` flag
- **Smart Editor Detection**: Automatisch nvim wenn installiert, sonst vim fallback
- **Help Documentation**: Built-in help via `-h` or `--help` flags

## Sourcing Logic

- `setup.sh` findet `*/init.sh` und führt in definierter Reihenfolge aus
- `configs/init.sh` findet `applications/setup_*.sh` und sourced automatisch
- `functions/init.sh` erstellt aliases für alle custom scripts
- `bashrc.sh`/`zshrc.sh` sourcen automatisch alle files aus `common/` (außer shell-spezifische)
- Shell-spezifische files (`bash_*` / `zsh_*`) werden nur von entsprechender shell geladen
- Shell configs werden in `~/.bashrc`/`~/.zshrc` eingehängt, nicht ersetzt

Scripts sind idempotent - mehrfach ausführbar ohne Duplikate.
