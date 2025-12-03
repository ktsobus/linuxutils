# -----------------------------------------------
# FAPT - FZF APT Package Browser & Installer
# -----------------------------------------------

# fapt command: Browse and install APT packages with FZF
fapt() {
  local selected_package
  local package_name

  # Check if apt-cache is available
  if ! command -v apt-cache &>/dev/null; then
    echo -e "\033[1;31m╭─────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;31m│\033[0m  ❌ apt-cache nicht gefunden!"
    echo -e "\033[1;31m│\033[0m  Dieser Befehl benötigt APT."
    echo -e "\033[1;31m╰─────────────────────────────────────────╯\033[0m"
    return 1
  fi

  # Get all available packages and let user select with FZF
  selected_package=$(apt-cache search . |
    sort |
    fzf \
      --border-label='╢ APT Pakete durchsuchen ╟' \
      --preview='
        pkg=$(echo {} | awk "{print \$1}");
        
        # Header with package name
        echo -e "\033[1;36m╔════════════════════════════════════════════════════════╗\033[0m";
        echo -e "\033[1;36m║\033[0m  \033[1;97mPaket:\033[0m \033[1;33m$pkg\033[0m";
        echo -e "\033[1;36m╚════════════════════════════════════════════════════════╝\033[0m";
        echo "";
        
        # Installation status with color
        if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
          echo -e "\033[1;32m  ✓ INSTALLIERT\033[0m";
        else
          echo -e "\033[1;90m  ✗ Nicht installiert\033[0m";
        fi
        echo "";
        
        # Package details
        echo -e "\033[1;35m┌─ Details\033[0m";
        apt-cache show "$pkg" 2>/dev/null | grep -E "^(Version|Description|Section|Maintainer|Homepage):" | \
          sed "s/^Version:/\x1b[1;94m  │ Version:\x1b[0m/g" | \
          sed "s/^Description:/\x1b[1;94m  │ Beschreibung:\x1b[0m/g" | \
          sed "s/^Section:/\x1b[1;94m  │ Kategorie:\x1b[0m/g" | \
          sed "s/^Maintainer:/\x1b[1;94m  │ Maintainer:\x1b[0m/g" | \
          sed "s/^Homepage:/\x1b[1;94m  │ Homepage:\x1b[0m/g" || echo -e "\033[0;90m  Keine Details verfügbar\033[0m";
        echo -e "\033[1;35m└─\033[0m";
        echo "";
        
        # Full description
        desc=$(apt-cache show "$pkg" 2>/dev/null | sed -n "/^Description:/,/^[A-Z]/p" | sed "1d;\$d" | sed "s/^ //");
        if [[ -n "$desc" ]]; then
          echo -e "\033[1;35m┌─ Vollständige Beschreibung\033[0m";
          echo "$desc" | fold -w 52 -s | sed "s/^/\x1b[0;37m  │ \x1b[0m/g";
          echo -e "\033[1;35m└─\033[0m";
        fi
      ' \
      --preview-window=right:60%:wrap \
      --bind 'ctrl-/:toggle-preview' \
      --ansi)

  # Check if user selected a package
  if [[ -z "$selected_package" ]]; then
    echo -e "\033[0;90m❌ Keine Auswahl getroffen.\033[0m"
    return 0
  fi

  # Extract package name (first column)
  package_name=$(echo "$selected_package" | awk '{print $1}')

  # Check if package is already installed
  if dpkg -l "$package_name" 2>/dev/null | grep -q "^ii"; then
    echo -e "\033[1;33m╭─────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;33m│\033[0m  ℹ️  Paket '\033[1;36m$package_name\033[0m' ist bereits installiert."
    echo -e "\033[1;33m╰─────────────────────────────────────────╯\033[0m"
    read -p "$(echo -e '\033[1;97mMöchten Sie es neu installieren/aktualisieren? (j/N):\033[0m ') " confirm
    if [[ ! "$confirm" =~ ^[jJyY]$ ]]; then
      echo -e "\033[0;90m🚫 Abgebrochen.\033[0m"
      return 0
    fi
  fi

  # Install the package with sudo
  echo ""
  echo -e "\033[1;35m╭─────────────────────────────────────────╮\033[0m"
  echo -e "\033[1;35m│\033[0m  📦 Installiere '\033[1;33m$package_name\033[0m'..."
  echo -e "\033[1;35m╰─────────────────────────────────────────╯\033[0m"
  echo ""

  sudo apt install "$package_name"

  echo ""
  if [[ $? -eq 0 ]]; then
    echo -e "\033[1;32m╭─────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;32m│\033[0m  ✅ '\033[1;36m$package_name\033[0m' erfolgreich installiert!"
    echo -e "\033[1;32m╰─────────────────────────────────────────╯\033[0m"
  else
    echo -e "\033[1;31m╭─────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;31m│\033[0m  ❌ Installation von '\033[1;33m$package_name\033[0m' fehlgeschlagen."
    echo -e "\033[1;31m╰─────────────────────────────────────────╯\033[0m"
    return 1
  fi
}

# Optional: Add alias for quick access
alias apt-search='fapt'

# -----------------------------------------------
# Ende der FAPT Konfiguration
# -----------------------------------------------
