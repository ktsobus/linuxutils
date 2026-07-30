# LinuxUtils

> Ein modulares, automatisiertes Setup-System für Ubuntu/WSL-Entwicklungsumgebungen

[![English](https://img.shields.io/badge/lang-English-blue)](README_EN.md)

LinuxUtils automatisiert die Installation und Konfiguration von Entwicklungswerkzeugen, Shell-Umgebungen und eigenen Utilities über ein hierarchisches Initialisierungssystem. Es bietet eine einheitliche Konfiguration für Bash und Zsh, integriert moderne CLI-Tools mit FZF-basiertem Fuzzy-Finding und erkennt automatisch den bevorzugten Editor.

## Inhaltsverzeichnis

- [Schnellstart](#schnellstart)
  - [Installation](#installation)
  - [Erster Start](#erster-start)
  - [Installation überprüfen](#installation-überprüfen)
- [Features](#features)
- [Nutzung](#nutzung)
  - [Befehle & Aliase](#befehle--aliase)
  - [Tastenkürzel](#tastenkürzel)
  - [FZF-Werkzeuge](#fzf-werkzeuge)
  - [SSH-Agent](#ssh-agent)
  - [Fastfetch](#fastfetch)
- [Was wird installiert](#was-wird-installiert)
  - [Systempakete (APT)](#systempakete-apt)
  - [Homebrew-Pakete](#homebrew-pakete)
  - [Snap-Pakete](#snap-pakete)
  - [Entwicklungswerkzeuge](#entwicklungswerkzeuge)
  - [Oh My Zsh Plugins](#oh-my-zsh-plugins)
  - [Optional: Neovim + LazyVim](#optional-neovim--lazyvim)
- [Architektur](#architektur)
  - [Drei-Stufen-Initialisierung](#drei-stufen-initialisierung)
  - [Shell-Konfigurationskette](#shell-konfigurationskette)
  - [Dateistruktur](#dateistruktur)
- [Anpassung](#anpassung)
  - [Pakete hinzufügen](#pakete-hinzufügen)
  - [Shell-Konfiguration hinzufügen](#shell-konfiguration-hinzufügen)
  - [Eigene Funktionen erstellen](#eigene-funktionen-erstellen)
  - [Anwendungs-Setup hinzufügen](#anwendungs-setup-hinzufügen)
  - [Neue Kategorie erstellen](#neue-kategorie-erstellen)
- [Konfigurationsdetails](#konfigurationsdetails)
  - [Oh My Zsh Integration](#oh-my-zsh-integration)
  - [SDKMAN-Platzierung](#sdkman-platzierung)
  - [Editor-Präferenz](#editor-präferenz)
- [Fehlerbehebung](#fehlerbehebung)
- [Mitwirken](#mitwirken)

## Schnellstart

### Installation

```bash
# Repository klonen
git clone https://gitlab.so.ch/solerbus/linuxutils.git ~/linuxutils
cd ~/linuxutils

# Setup-Skript ausführbar machen (falls nötig)
chmod +x setup.sh
```

### Erster Start

```bash
# Standard-Setup (installiert alles ausser Neovim)
./setup.sh

# Setup mit Neovim + LazyVim-Konfiguration
./setup.sh --nvim

# Hilfe und alle Optionen anzeigen
./setup.sh --help
```

Der Setup-Prozess durchläuft folgende Schritte:

1. Systemweit alle Pakete installieren und aktualisieren
2. Oh My Zsh und Plugins installieren (falls Zsh verfügbar)
3. NVM und Node.js 22 installieren
4. SDKMAN für JVM-Tools installieren
5. Homebrew installieren und konfigurierte Pakete einrichten
6. Shell-Umgebungen (Bash/Zsh) konfigurieren
7. Vim mit Plugins einrichten
8. Optional: Neovim + LazyVim installieren

### Installation überprüfen

```bash
# Terminal neustarten oder Konfiguration laden
source ~/.bashrc    # für Bash
source ~/.zshrc     # für Zsh

# FZF-Integration testen
fzf --version

# Eigene Befehle testen
fapt                # FZF-APT-Paketbrowser
f suchbegriff       # Fuzzy-Grep-Suche
ssh                 # SSH mit FZF-Hostauswahl (ohne Argumente)

# Editor-Präferenz prüfen
echo $EDITOR        # Sollte nvim oder vim zeigen
```

## Features

- **Automatisiertes Setup** — Ein Befehl installiert die komplette Entwicklungsumgebung
- **Idempotente Skripte** — Mehrfach ausführbar ohne Duplikate oder Konflikte
- **Dual-Shell-Support** — Einheitliche Konfiguration für Bash und Zsh
- **Moderne CLI-Tools** — FZF, ripgrep, bat, lazygit, lazydocker und mehr
- **Intelligente Editor-Erkennung** — Bevorzugt automatisch Neovim gegenüber Vim; setzt `$EDITOR`, `$VISUAL` und `$PREFERRED_EDITOR`
- **FZF überall** — Fuzzy-Finding für Dateien, History, SSH-Hosts und APT-Pakete
- **Eigene Funktionen** — Erweiterbares Befehlssystem mit auto-generierten Aliasen
- **Oh My Zsh Integration** — Vollständiges Zsh-Plugin-Ökosystem mit oh-my-posh Prompt
- **Entwicklung sofort bereit** — Node.js (via NVM), JVM-Tools (via SDKMAN), Docker
- **SSH leicht gemacht** — Intelligentes SSH-Agent-Management und FZF-Hostauswahl

## Nutzung

### Befehle & Aliase

**Setup & Wartung:**

| Alias                    | Befehl                                                | Beschreibung                                |
| ------------------------ | ----------------------------------------------------- | ------------------------------------------- |
| `sau`                    | `apt update && upgrade + snap refresh + brew upgrade` | Alle Pakete aktualisieren, Shell neustarten |
| `lu-dependencies`        | `source ~/linuxutils/dependencies/init.sh`            | Abhängigkeiten neu installieren             |
| `lu-dependencies --nvim` | —                                                     | Mit Neovim-Installation                     |
| `lu-configs`             | `source ~/linuxutils/configs/init.sh`                 | Shell-Konfiguration neu einrichten          |
| `lu-functions`           | `source ~/linuxutils/functions/init.sh`               | Funktions-Aliase neu generieren             |

**Navigation:**

| Alias | Befehl                             | Beschreibung                  |
| ----- | ---------------------------------- | ----------------------------- |
| `..`  | `cd ..`                            | Ein Verzeichnis nach oben     |
| `ls`  | `g --icon --sort=name`             | Dateien mit Icons auflisten   |
| `ll`  | `g --icon --long --sort=name --sh` | Ausführliche Liste mit Icons  |
| `la`  | `ls -A`                            | Alle Dateien inkl. versteckte |
| `cls` | `clear`                            | Bildschirm löschen            |

**Editor:**

| Alias | Befehl            | Beschreibung                             |
| ----- | ----------------- | ---------------------------------------- |
| `v`   | `nvim` oder `vim` | Bevorzugten Editor öffnen (auto-erkannt) |

**Git:**

| Alias | Befehl       | Beschreibung        |
| ----- | ------------ | ------------------- |
| `gs`  | `git status` | Git-Status anzeigen |
| `ga`  | `git add`    | Dateien stagen      |
| `lg`  | `lazygit`    | Terminal-UI für Git |

**Suche:**

| Alias | Befehl      | Beschreibung                                                          |
| ----- | ----------- | --------------------------------------------------------------------- |
| `f`   | `fuzzygrep` | Interaktive Textsuche mit FZF (siehe [FZF-Werkzeuge](#fzf-werkzeuge)) |

**Pakete:**

| Alias                 | Befehl | Beschreibung                                                          |
| --------------------- | ------ | --------------------------------------------------------------------- |
| `fapt` / `apt-search` | —      | Interaktiver APT-Paketbrowser (siehe [FZF-Werkzeuge](#fzf-werkzeuge)) |

**Netzwerk:**

| Alias          | Befehl                             | Beschreibung                   |
| -------------- | ---------------------------------- | ------------------------------ |
| `unset-proxys` | `unset HTTP_PROXY HTTPS_PROXY ...` | Alle Proxy-Variablen entfernen |

**Shell:**

| Alias             | Befehl | Beschreibung                   |
| ----------------- | ------ | ------------------------------ |
| `change-my-shell` | —      | Zwischen Bash und Zsh wechseln |

### Tastenkürzel

Alle FZF-Tastenkürzel auf einen Blick:

| Taste    | Funktion            | Beschreibung                                      |
| -------- | ------------------- | ------------------------------------------------- |
| `Ctrl+T` | Pfad durchsuchen    | Datei suchen und Pfad an Cursor-Position einfügen |
| `Ctrl+R` | History durchsuchen | Befehlsverlauf mit Vorschau durchsuchen           |
| `Alt+C`  | Verzeichniswechsel  | Verzeichnis suchen und per `cd` wechseln          |
| `Ctrl+F` | Datei bearbeiten    | Datei suchen und in vim/nvim öffnen               |
| `Ctrl+/` | Vorschau umschalten | Vorschaufenster ein-/ausblenden                   |
| `Alt+S`  | SSH-Hostauswahl     | FZF-basierte SSH-Verbindung starten               |

### FZF-Werkzeuge

#### Fuzzy-Grep-Suche (`f` / `fuzzygrep`)

Interaktive Zwei-Stufen-Textsuche über alle Dateien:

```bash
f "suchbegriff"    # Direkt suchen
f                  # Interaktive Eingabe
```

**Ablauf:**

1. **Schritt 1:** Alle Dateien mit dem Suchbegriff finden (via `ripgrep`)
2. **Schritt 2:** Spezifischen Treffer in der ausgewählten Datei auswählen
3. **Editor** öffnet sich an exakter Zeilen- und Spaltenposition

Die Vorschau zeigt den Kontext mit Syntax-Highlighting (via `bat`).

#### APT-Paketbrowser (`fapt` / `apt-search`)

Interaktiver APT-Paketbrowser mit detaillierter Vorschau:

```bash
fapt               # Paketbrowser starten
apt-search          # Gleiche Funktion
```

**Vorschau zeigt:**

- Paketname und Version
- Installationsstatus (farbcodiert)
- Beschreibung, Kategorie, Maintainer und Homepage

Pakete können direkt aus dem Browser installiert werden. Bei bereits installierten Paketen wird eine Bestätigung für Neuinstallation/Aktualisierung abgefragt.

#### SSH mit FZF (`ssh` / `Alt+S`)

Smartes SSH mit Fuzzy-Hostauswahl:

```bash
ssh                 # Ohne Argumente: FZF-Hostauswahl aus ~/.ssh/config
ssh user@host       # Traditionelles SSH funktioniert weiterhin
# Alt+S             # Tastenkürzel für Hostauswahl
```

**Funktionsweise:**

- Liest Hosts aus `~/.ssh/config` (ohne Wildcards)
- Fügt den gewählten Befehl zur Shell-History hinzu
- Erhält TTY für interaktive Sitzungen
- Funktioniert in Bash und Zsh

### SSH-Agent

Intelligentes SSH-Key-Management beim Shell-Start:

- Startet `ssh-agent` automatisch, falls nicht aktiv
- Nutzt vorhandenen Agent wieder, falls vorhanden
- Erkennt automatisch verschlüsselte vs. unverschlüsselte Schlüssel
- Lädt unverschlüsselte Schlüssel lautlos
- Bei verschlüsselten Schlüsseln:
  - Fragt einmal nach einem gemeinsamen Passwort
  - Probiert dieses Passwort bei allen verschlüsselten Schlüsseln
  - Individuelle Abfrage nur für Schlüssel mit abweichendem Passwort
- Keine doppelte Schlüsselladung

### Fastfetch

Angepasste Systemanzeige beim Shell-Start:

- ASCII-Art mit `cowsay` (Tux-Pinguin)
- Live-Wetter für Solothurn, CH (via `ansiweather`)
- Farbcodiert nach Shell: Zsh (Lila), Bash (Cyan), andere (Weiss)
- Fallback auf Standard-Fastfetch, falls Abhängigkeiten fehlen

## Was wird installiert

### Systempakete (APT)

| Paket             | Beschreibung                                  |
| ----------------- | --------------------------------------------- |
| `git`             | Versionskontrollsystem                        |
| `tree`            | Verzeichnisbaum-Visualisierung                |
| `build-essential` | Kompilierungswerkzeuge (gcc, make, etc.)      |
| `zsh`             | Z Shell — Moderne Shell-Alternative           |
| `fastfetch`       | Systeminformationsanzeige                     |
| `cowsay`          | ASCII-Art-Textgenerator                       |
| `ansiweather`     | Wetter im Terminal                            |
| `zip` / `unzip`   | Archiv-Utilities                              |
| `tar` / `gzip`    | Komprimierungswerkzeuge                       |
| `htop`            | Interaktiver Prozess-Viewer                   |
| `btop`            | Moderner Ressourcenmonitor                    |
| `ripgrep`         | Schnelles Textsuch-Tool (`rg`)                |
| `bat`             | Moderner `cat`-Ersatz mit Syntax-Highlighting |
| `gdu`             | Schneller Speicherplatz-Analyzer              |
| `traceroute`      | Netzwerk-Diagnosewerkzeug                     |

### Homebrew-Pakete

| Paket        | Beschreibung                    |
| ------------ | ------------------------------- |
| `fzf`        | Kommandozeilen-Fuzzy-Finder     |
| `oh-my-posh` | Cross-Shell Prompt-Theme-Engine |
| `lazygit`    | Terminal-UI für Git             |
| `lazydocker` | Terminal-UI für Docker          |
| `g-ls`       | Moderner `ls`-Ersatz mit Icons  |
| `asciinema`  | Terminal-Session-Recorder       |
| `agg`        | Asciinema-GIF-Generator         |
| `snitch`     | Netzwerkverkehr-Monitor         |

### Snap-Pakete

- **Docker** — Container-Plattform für Entwicklung

### Entwicklungswerkzeuge

**Node.js** (via NVM)

- Node.js Version 22 (LTS)
- Automatisch als Standard konfiguriert

**SDKMAN**

- Java SDK Manager für JVM-Tools
- `sdk install java` nach Setup ausführen, um Java zu installieren

### Oh My Zsh Plugins

Folgende Plugins werden automatisch installiert und aktiviert (falls Zsh vorhanden):

| Plugin                     | Beschreibung                               |
| -------------------------- | ------------------------------------------ |
| `git`                      | Git-Aliase und -Funktionen                 |
| `colorize`                 | Syntax-Highlighting für Dateien            |
| `colored-man-pages`        | Farbige Manpages                           |
| `compleat`                 | Erweiterte Tab-Completion                  |
| `emoji`                    | Emoji-Support im Terminal                  |
| `ssh`                      | SSH-Hilfsfunktionen                        |
| `you-should-use`           | Erinnert an vorhandene Aliase              |
| `zsh-autosuggestions`      | Fish-ähnliche Autovervollständigung        |
| `zsh-syntax-highlighting`  | Syntax-Highlighting für Befehle            |
| `fast-syntax-highlighting` | Schnellere Syntax-Highlighting Alternative |

### Optional: Neovim + LazyVim

Mit dem `--nvim` Flag:

- **Neovim** — Hypererweiterbarer Vim-basierter Texteditor
- **LazyVim** — Vorkonfigurierte Neovim-Distribution mit Plugins
- Sichert automatisch vorhandene Neovim-Konfiguration
- Plugins werden beim ersten `nvim`-Start installiert

## Architektur

### Drei-Stufen-Initialisierung

LinuxUtils verwendet ein hierarchisches Setup, orchestriert durch `setup.sh`:

```
┌─────────────────────────────────────────────────────┐
│                    setup.sh                         │
│  Orchestriert alle Initialisierungen in der         │
│  richtigen Reihenfolge                              │
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
│  APT/Brew/    │ │  Shell Configs│ │  Skripte      │
│  Snap Pakete  │ │  → bashrc.sh  │ │  ausführbar   │
│               │ │  → zshrc.sh   │ │  machen       │
│  NVM/Node.js  │ │               │ │               │
│               │ │  Anwendungen: │ │  Aliase für   │
│  SDKMAN/JVM   │ │  → setup_*.sh │ │  alle eigenen │
│               │ │               │ │  Funktionen   │
│  Homebrew     │ │  SDKMAN am    │ │  generieren   │
│               │ │  Ende der .rc │ │               │
│  Oh My Zsh    │ │  Dateien      │ │               │
│  + Plugins    │ │  erhalten     │ │               │
│               │ │               │ │               │
│  [Optional]   │ │               │ │               │
│  Neovim +     │ │               │ │               │
│  LazyVim      │ │               │ │               │
└───────────────┘ └───────────────┘ └───────────────┘
```

**Stufe 1 — Dependencies** (`dependencies/init.sh`): Installiert und aktualisiert alle System-Pakete (APT, Snap, Homebrew), Entwicklungstools (NVM, SDKMAN), Oh My Zsh mit Plugins und optional Neovim.

**Stufe 2 — Configs** (`configs/init.sh`): Modifiziert `~/.bashrc` und `~/.zshrc`, um die eigenen Shell-Konfigurationen zu laden. Führt automatisch alle `applications/setup_*.sh` Skripte aus. Stellt sicher, dass SDKMAN-Exports am Ende der Shell-Dateien bleiben.

**Stufe 3 — Functions** (`functions/init.sh`): Macht alle `*.sh` Skripte in `functions/` ausführbar und generiert automatisch Aliase (ohne `.sh`-Endung) in `configs/shell/common/functions_aliases.sh`.

### Shell-Konfigurationskette

Beide Shells laden die gemeinsamen Konfigurationen aus `configs/shell/common/`:

**Bash:**

```
~/.bashrc → configs/shell/bashrc.sh → common/*.sh → common/bash_*.sh
```

**Zsh:**

```
~/.zshrc → configs/shell/zshrc.sh → Oh My Zsh → common/*.sh → common/zsh_*.sh
```

**Wichtige Details:**

- Dateien in `common/` werden von beiden Shells geladen (ausser mit `bash_` oder `zsh_` Präfix)
- `zshrc.sh` ersetzt die Standard-Oh-My-Zsh `.zshrc`, behält aber SDKMAN-Konfiguration bei
- Oh My Zsh wird mit leerem Theme initialisiert; `oh-my-posh` übernimmt den Prompt
- Das `g`-Alias wird nach Oh My Zsh entfernt, um Konflikte mit `g-ls` zu vermeiden
- Homebrew shellenv wird früh geladen, damit alle Brew-Befehle verfügbar sind

### Dateistruktur

```
~/linuxutils/
├── setup.sh                                   # Haupt-Setup-Skript
├── README.md                                  # Dokumentation (Deutsch)
├── README_EN.md                               # Dokumentation (Englisch)
│
├── dependencies/                              # Stufe 1: Paket-Installation
│   ├── init.sh                                # Hauptskript für Abhängigkeiten
│   ├── apt.sh                                 # APT-Paketliste
│   ├── brew.sh                                # Homebrew-Paketliste
│   ├── snap.sh                                # Snap-Paketliste
│   └── nvim.sh                                # Neovim + LazyVim Setup
│
├── configs/                                   # Stufe 2: Konfigurationen
│   ├── init.sh                                # Konfigurationseinrichtung
│   ├── shell/
│   │   ├── bashrc.sh                          # Bash-Konfiguration
│   │   ├── zshrc.sh                           # Zsh-Konfiguration
│   │   ├── common/                            # Gemeinsame Shell-Configs
│   │   │   ├── aliases.sh                     # Allgemeine Aliase
│   │   │   ├── editor.sh                      # Editor-Erkennung
│   │   │   ├── fzf.sh                         # FZF-Konfiguration & Keybindings
│   │   │   ├── fuzzygrep.sh                   # Fuzzy-Grep-Funktion
│   │   │   ├── ssh_fzf.sh                     # SSH mit FZF
│   │   │   ├── fapt.sh                        # APT-Paketbrowser
│   │   │   ├── ssh-agent-loader.sh            # SSH-Agent-Management
│   │   │   ├── fastfetch.sh                   # Systeminfo-Anzeige
│   │   │   ├── functions_aliases.sh           # Auto-generierte Aliase
│   │   │   ├── bash_*.sh                      # Nur-Bash-Configs
│   │   │   └── zsh_*.sh                       # Nur-Zsh-Configs
│   │   └── ohmyposh/
│   │       └── custom-zash.omp.json           # Oh-my-posh Theme
│   └── applications/
│       ├── setup_vim.sh                       # Vim-Setup
│       └── vim/                               # Vim-Konfiguration
│           ├── vimrc                          # → Symlink nach ~/.vimrc
│           └── plugins.vim                    # Vim-Plugins
│
└── functions/                                 # Stufe 3: Eigene Funktionen
    ├── init.sh                                # Funktions-Initialisierung
    └── change-my-shell.sh                     # Shell-Wechsel-Utility
```

## Anpassung

### Pakete hinzufügen

**APT-Pakete** — `dependencies/apt.sh` bearbeiten:

```bash
APT_PACKAGES=(
    "git"
    "vim"
    "neues-paket"    # Hier hinzufügen
)
```

**Homebrew-Pakete** — `dependencies/brew.sh` bearbeiten:

```bash
BREW_PACKAGES=(
    "fzf"
    "neues-paket"    # Hier hinzufügen
)
```

**Snap-Pakete** — `dependencies/snap.sh` bearbeiten:

```bash
SNAP_PACKAGES=(
    "docker"
    "neues-paket"    # Hier hinzufügen
)
```

Danach: `lu-dependencies` ausführen.

### Shell-Konfiguration hinzufügen

Neue Dateien in `configs/shell/common/` erstellen:

```bash
# Für beide Shells (Bash + Zsh)
configs/shell/common/mein-feature.sh

# Nur für Bash
configs/shell/common/bash_mein-feature.sh

# Nur für Zsh
configs/shell/common/zsh_mein-feature.sh
```

Die Dateien werden beim nächsten Shell-Start automatisch geladen — kein weiteres Setup nötig. Zum sofortigen Laden:

```bash
source ~/.bashrc    # oder ~/.zshrc
```

### Eigene Funktionen erstellen

Skripte in `functions/` werden zu global verfügbaren Befehlen:

```bash
# Neues Skript erstellen
cat > functions/backup-db.sh << 'EOF'
#!/bin/bash
echo "Datenbank wird gesichert..."
# Backup-Logik hier
EOF

# Aliase neu generieren und Shell laden
lu-functions
source ~/.bashrc    # oder ~/.zshrc

# Jetzt als Befehl verfügbar (ohne .sh)
backup-db
```

**So funktioniert es:**

- `functions/init.sh` macht alle `*.sh` Dateien ausführbar
- Generiert automatisch ein Alias pro Skript (ohne `.sh`-Endung)
- Aliase werden in `configs/shell/common/functions_aliases.sh` gespeichert

### Anwendungs-Setup hinzufügen

Anwendungsspezifische Konfigurationen in `configs/applications/` ablegen:

```bash
# Setup-Skript erstellen (muss mit setup_ beginnen)
configs/applications/setup_meine-app.sh
```

Alle `setup_*.sh` Dateien werden automatisch von `configs/init.sh` erkannt und ausgeführt. Verwende `print_status`, `print_warning` und `print_error` für einheitliche Ausgaben. Siehe `configs/applications/setup_vim.sh` als Referenz.

### Neue Kategorie erstellen

Ein neues Verzeichnis mit `init.sh` erstellen — `setup.sh` findet und führt es automatisch aus:

```bash
mkdir ~/linuxutils/cloud-tools
# cloud-tools/init.sh erstellen mit Setup-Logik
```

Die Ausführungsreihenfolge kann über `SETUP_ORDER` in `setup.sh` gesteuert werden.

## Konfigurationsdetails

### Oh My Zsh Integration

Wenn Oh My Zsh installiert ist, durchläuft `zshrc.sh` folgende Schritte:

1. Oh My Zsh initialisieren (mit leerem Theme, um Konflikte zu vermeiden)
2. Homebrew-Umgebung laden (für Paketverfügbarkeit)
3. `oh-my-posh` initialisieren (überschreibt Oh My Zsh Prompt)
4. Alle gemeinsamen Configs laden
5. `g`-Alias entfernen (verhindert Konflikt mit `g-ls` — das `g`-Alias stammt vom Oh My Zsh git-Plugin)

### SDKMAN-Platzierung

SDKMAN-Exports **müssen** am Ende der Shell-Konfigurationsdateien stehen. SDKMAN modifiziert PATH und andere Variablen, die bei zu früher Ladung andere Tools stören können.

`configs/init.sh` handhabt dies automatisch:

1. Erkennt vorhandene SDKMAN-Zeilen
2. Entfernt sie temporär
3. Fügt die eigene Config-Sourcing-Zeile hinzu
4. Setzt SDKMAN-Zeilen am Ende wieder ein

**Überprüfung:**

```bash
tail ~/.bashrc    # oder ~/.zshrc

# Sollte am Ende zeigen:
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

### Editor-Präferenz

Das System erkennt und konfiguriert automatisch den bevorzugten Editor:

**Erkennungsreihenfolge:** `nvim` → `vim` → `vi`

**Gesetzte Umgebungsvariablen:**

| Variable            | Beschreibung                           |
| ------------------- | -------------------------------------- |
| `$EDITOR`           | Wird von Git, Cron, etc. verwendet     |
| `$VISUAL`           | Wird von einigen Anwendungen verwendet |
| `$PREFERRED_EDITOR` | Eigene Variable für Skripte            |

**Wo es verwendet wird:**

- `v`-Alias in `aliases.sh`
- FZF-Dateiöffnung (`Ctrl+F`) in `fzf.sh`
- Fuzzygrep in `fuzzygrep.sh`
- Eigene Skripte können `$PREFERRED_EDITOR` nutzen

## Fehlerbehebung

**Shell-Konfiguration lädt nicht:**

```bash
# Prüfen ob linuxutils in der RC-Datei eingetragen ist
grep "linuxutils" ~/.bashrc    # oder ~/.zshrc

# Falls nicht, Configs neu einrichten
lu-configs
source ~/.bashrc    # oder ~/.zshrc
```

**FZF funktioniert nicht:**

```bash
fzf --version           # Installation prüfen
brew install fzf        # Direkt installieren
# oder: lu-dependencies # Alles neu installieren
```

**Eigene Funktion nicht verfügbar:**

```bash
ls -la ~/linuxutils/functions/    # Skript vorhanden und ausführbar?
lu-functions                       # Aliase neu generieren
source ~/.bashrc                   # Shell neu laden
```

**Vim-Plugins nicht installiert:**

```bash
vim +PlugInstall +qall    # Plugins manuell installieren
# oder: lu-configs        # Konfiguration neu einrichten
```

**SDKMAN funktioniert nicht:**

```bash
tail ~/.bashrc    # SDKMAN am Ende der Datei?
lu-configs        # Konfiguration neu einrichten (handhabt Platzierung)
source ~/.bashrc
```

**Oh My Zsh Konflikte:**

```bash
# System handhabt OMZ-Integration automatisch
# Falls Probleme bestehen:
mv ~/.zshrc ~/.zshrc.backup
lu-configs
```

**Neovim/LazyVim Probleme:**

```bash
nvim --version                    # Neovim installiert?

# LazyVim komplett neu installieren
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
lu-dependencies --nvim
```

**PATH-Probleme nach Setup:**

```bash
# Homebrew-PATH sicherstellen
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo $PATH

# Terminal komplett neustarten für alle Änderungen
```

**SSH-Agent lädt keine Schlüssel:**

```bash
ps aux | grep ssh-agent                                     # Agent läuft?
ssh-add -l                                                  # Geladene Schlüssel prüfen
source ~/linuxutils/configs/shell/common/ssh-agent-loader.sh  # Manuell neu laden
```

**Paketinstallation schlägt fehl:**

```bash
sudo apt update                  # Paketlisten aktualisieren
sudo apt-mark showhold           # Gehaltene Pakete prüfen
sudo apt install <paketname>     # Manuell installieren für Fehlerdetails
```

## Mitwirken

Beiträge sind willkommen! So kannst du helfen:

**Neue Features hinzufügen:**

1. Repository forken
2. Feature-Branch erstellen
3. Feature nach bestehenden Patterns implementieren:
   - Neue Pakete → `dependencies/*.sh` bearbeiten
   - Neue Shell-Configs → `configs/shell/common/` hinzufügen
   - Neue Utilities → `functions/` hinzufügen
   - Neues App-Setup → `configs/applications/` hinzufügen
4. Gründlich auf einer sauberen Ubuntu/WSL-Instanz testen
5. Pull Request mit klarer Beschreibung einreichen

**Wichtige Konventionen:**

- Skripte müssen **idempotent** sein (sicher mehrfach ausführbar)
- `print_status`, `print_warning`, `print_error` für Ausgaben verwenden
- Shell-Konfigurationen in **Bash und Zsh** testen
- SDKMAN-Exports müssen am **Ende** der Shell-Dateien bleiben
- README in **beiden Sprachen** (DE + EN) aktualisieren

**Fehler melden:**

- GitHub Issues verwenden
- Angeben: OS-Version, Shell-Typ, Fehlermeldungen
- Schritte zur Reproduktion beschreiben

---

**Hinweis:** Dieses Projekt ist auf Ubuntu/WSL-Umgebungen zugeschnitten. Einige Features erfordern möglicherweise Anpassungen für andere Linux-Distributionen.
