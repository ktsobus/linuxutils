# -----------------------------------------------
# FZF Konfiguration & Keybindings für Bash
# -----------------------------------------------
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# --- Detect Shell ---
if [[ -n "$ZSH_VERSION" ]]; then
  IS_ZSH=true
  source <(fzf --zsh)
else
  IS_ZSH=false
  eval "$(fzf --bash)"
fi

# Dynamische Label-Bindings für alle Widgets
export FZF_LABEL_BINDS="
    --bind 'result:transform-list-label:
        if [[ -z \$FZF_QUERY ]]; then
            echo \" \$FZF_MATCH_COUNT Einträge \"
        else
            echo \" \$FZF_MATCH_COUNT Treffer für [\$FZF_QUERY] \"
        fi'
    --bind 'focus:transform-preview-label:
        [[ -n {} ]] && printf \" Vorschau [%s] \" {}'
#    --bind 'focus:+transform-header:file --brief {} || echo \"No file selected\"'

"

export FZF_COLORS="
    --color 'preview-border:#9999cc,preview-label:#ccccff'
    --color 'list-border:#669966,list-label:#99cc99'
    --color 'input-border:#996666,input-label:#ffcccc'
    --color 'header-border:#6699cc,header-label:#99ccff'
"

# Ctrl+T: Pfad durchsuchen
export FZF_CTRL_T_OPTS="
  --border-label='╢ Pfad durchsuchen ╟'
  --preview 'batcat --color=always --style=numbers --line-range=:500 {} || cat {}'
  --bind 'ctrl-/:toggle-preview'
"

# Alt+C: Verzeichnisse durchsuchen
export FZF_ALT_C_OPTS="
  --border-label='╢ Verzeichnisse durchsuchen ╟'
  --scheme=path
  --preview 'tree -C -L 2 {} | head -n 30'
  --bind 'ctrl-/:toggle-preview'
"

# Ctrl+R: Bash-History durchsuchen, Input-Feld ganz oben!
export FZF_CTRL_R_OPTS="
  --border-label='╢ Bash-History durchsuchen ╟'
  --scheme=history
#  --preview 'echo {}'
"

# Ctrl+F: Dateien suchen und bearbeiten
FZF_CTRL_F_OPTS=(
  --border-label='╢ Dateien suchen & bearbeiten ╟'
  --preview 'batcat --color=always --style=numbers --line-range=:500 {} || cat {}'
)

# Global default options for fzf
export FZF_DEFAULT_OPTS="
  --style=full
  --layout=reverse
  --margin 1%
  --border
  --cycle
  --list-border
  --input-label ' Suchbegriff '
  --header-label ' Info '
  --prompt='❯ '
  --pointer='❯'
  $FZF_COLORS
  $FZF_LABEL_BINDS
"

# Keybinding-Variable für Ctrl+F
export FZF_CTRL_F_BINDING='\C-f'

# Ctrl+F: Datei in vim öffnen – OHNE FZF_COMMON_OPTS, sondern explizite Optionen!
fzf-open-file-widget() {
  local selected_file
  local find_files_cmd

  if command -v fd &>/dev/null; then
    find_files_cmd="fd --type f --hidden --follow --exclude .git ."
  elif command -v fdfind &>/dev/null; then
    find_files_cmd="fdfind --type f --hidden --follow --exclude .git ."
  else
    find_files_cmd="find . -type d -name .git -prune -o -type f -print -o -type l -print 2>/dev/null"
  fi

  selected_file=$(eval "$find_files_cmd" | fzf "${FZF_CTRL_F_OPTS[@]}")

  if [[ $? -eq 0 ]] && [[ -n "$selected_file" ]]; then
    if [[ -w "$selected_file" ]]; then
      echo $selected_file | xargs -o vim
    else
      echo "Datei nicht beschreibbar, versuche mit sudo zu öffnen..."
      echo $selected_file | xargs -o sudo vim
    fi
  fi
}

# --- KEYBINDS ---

if $IS_ZSH; then

  # Ctrl+F to open file
  fzf-file-widget-zsh() {
    zle -I
    fzf-open-file-widget
    zle reset-prompt
  }
  zle -N fzf-file-widget-zsh
  bindkey "${FZF_CTRL_F_BINDING}" fzf-file-widget-zsh

else
  bind -x "\"${FZF_CTRL_F_BINDING}\": fzf-open-file-widget"
fi
# -----------------------------------------------
# Ende der Konfiguration
# -----------------------------------------------
