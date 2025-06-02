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
~/.bashrc → bashrc.sh → aliases.sh + exports.sh + functions.sh
~/.zshrc → zshrc.sh → aliases.sh + exports.sh + functions.sh
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
│   ├── aliases.sh    # alias ll='ls -la'
│   ├── bashrc.sh     # lädt common + bash-specific
│   └── zshrc.sh      # lädt common + zsh-specific
└── applications/
    └── setup_*.sh    # app-specific setup logic
```

## Neues hinzufügen

**Package:** Array in `apt.sh` oder `brew.sh` erweitern

**Alias:** `configs/shell/aliases.sh` editieren

**App:** `configs/applications/setup_newapp.sh` erstellen:
```bash
#!/bin/bash
# wird automatisch von configs/init.sh gefunden und ausgeführt
```

**Neue Kategorie:** Directory mit `init.sh` erstellen (wird von `setup.sh` gefunden)

## Sourcing Logic

- `setup.sh` findet `*/init.sh` und führt aus
- `configs/init.sh` findet `applications/setup_*.sh` und sourced
- Shell configs werden in `~/.bashrc`/`~/.zshrc` eingehängt, nicht ersetzt
- Bestehende configs werden vor Änderungen gebackupt

Scripts sind idempotent - mehrfach ausführbar ohne Duplikate.
