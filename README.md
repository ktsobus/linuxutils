# LinuxUtils

Modulares Setup-System für Ubuntu/WSL Instanzen.

## Quick Start

```bash
git clone <repo-url>
cd linuxutils
./setup.sh
```

## Wie es funktioniert

`setup.sh` führt alle `init.sh` in Subdirectories aus:
1. `dependencies/init.sh` (zuerst)
2. `configs/init.sh` (dann)

### Dependencies Flow
```
dependencies/init.sh
├── apt update/upgrade
├── source apt.sh → install APT_PACKAGES[]
└── brew install/update → source brew.sh → install BREW_PACKAGES[]
```

### Configs Flow
```
configs/init.sh
├── bashrc sourcing: echo "source path/to/bashrc.sh" >> ~/.bashrc
├── zshrc sourcing: echo "source path/to/zshrc.sh" >> ~/.zshrc  
└── applications: source alle setup_*.sh
```

### Shell Config Chain
```
~/.bashrc → bashrc.sh → common/*.sh + common/bash_*.sh
~/.zshrc → zshrc.sh → common/*.sh + common/zsh_*.sh
```

## Struktur

```
dependencies/
├── init.sh        # orchestriert package installation
├── apt.sh         # APT_PACKAGES=("package1" "package2")
└── brew.sh        # BREW_PACKAGES=() + BREW_CASKS=()

configs/
├── init.sh        # orchestriert config setup
├── shell/
│   ├── bashrc.sh     # lädt common/* + bash-specific
│   ├── zshrc.sh      # lädt common/* + zsh-specific
│   └── common/
│       ├── aliases.sh    # für beide shells
│       ├── fzf.sh        # für beide shells
│       ├── bash_*.sh     # nur für bash
│       └── zsh_*.sh      # nur für zsh
└── applications/
    └── setup_*.sh    # app-specific setup logic
```

## Neues hinzufügen

**Package:** Array in `apt.sh` oder `brew.sh` erweitern

**Alias/Function:** File in `configs/shell/common/` erstellen:
```bash
# Für beide shells
shell/common/git_aliases.sh
shell/common/docker_functions.sh

# Nur für bash
shell/common/bash_completions.sh

# Nur für zsh  
shell/common/zsh_features.sh
```

**App:** `configs/applications/setup_newapp.sh` erstellen:
```bash
#!/bin/bash
# wird automatisch von configs/init.sh gefunden und ausgeführt
```

**Neue Kategorie:** Directory mit `init.sh` erstellen (wird von `setup.sh` gefunden)

## Sourcing Logic

- `setup.sh` findet `*/init.sh` und führt aus
- `configs/init.sh` findet `applications/setup_*.sh` und sourced
- `bashrc.sh`/`zshrc.sh` sourcen automatisch alle files aus `common/`
- Shell-spezifische files (`bash_*` / `zsh_*`) werden nur von entsprechender shell geladen
- Shell configs werden in `~/.bashrc`/`~/.zshrc` eingehängt, nicht ersetzt

Scripts sind idempotent - mehrfach ausführbar ohne Duplikate.
