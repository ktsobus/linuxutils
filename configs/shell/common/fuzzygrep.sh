fuzzygrep() {
  local query="$1"
  if [ -z "$query" ]; then
    echo -n "Suchbegriff eingeben: "
    read -r query
  fi

  local file
  file=$(rg --smart-case --hidden --files-with-matches --no-heading --color=never "$query" |
    fzf --preview "rg --smart-case --hidden --color=always --line-number '$query' {}" \
      --prompt="Datei auswählen: " \
      --preview-window=up:70% \
      --layout=reverse)

  [ -z "$file" ] && return

  local selection
  selection=$(rg --smart-case --hidden --line-number --no-heading --color=never "$query" "$file" |
    fzf --prompt="Treffer auswählen: " \
      --preview 'n={1}; low=$((n-7)); [ $low -lt 1 ] && low=1; high=$((n+7)); batcat --style=numbers --color=always --highlight-line $n --line-range $low:$high '"\"$file\"" \
      --preview-window=up:70% \
      --delimiter=: --with-nth=1,2..)

  [ -z "$selection" ] && return

  local linenr
  linenr=$(echo "$selection" | cut -d: -f1)

  local linecontent
  linecontent=$(sed "${linenr}q;d" "$file")

  local column
  column=$(awk -v IGNORECASE=1 -v l="$linecontent" -v q="$query" 'BEGIN{print index(l,q)}')

  # Use nvim if available, otherwise fallback to vim or $EDITOR
  local editor_cmd="${EDITOR}"
  if [ -z "$editor_cmd" ]; then
    if command -v nvim &>/dev/null; then
      editor_cmd="nvim"
    else
      editor_cmd="vim"
    fi
  fi

  if [ "$column" -gt 0 ]; then
    "$editor_cmd" +"call cursor($linenr,$column)" "$file"
  else
    "$editor_cmd" +$linenr "$file"
  fi

}
