fuzzygrep() {
  local query="$1"
  if [ -z "$query" ]; then
    echo -n "Suchbegriff eingeben: "
    read -r query
  fi

  local file
  file=$(rg --smart-case --hidden --files-with-matches --no-heading --color=never "$query" | \
         fzf --preview "rg --smart-case --hidden --color=always --line-number '$query' {}" \
             --prompt="Datei auswählen: " \
             --preview-window=up:70% \
             --layout=reverse)

  [ -z "$file" ] && return

  local selection
  selection=$(rg --smart-case --hidden --line-number --no-heading --color=never "$query" "$file" | \
              fzf --prompt="Treffer auswählen: " \
                  --preview 'n={1}; low=$((n-7)); [ $low -lt 1 ] && low=1; high=$((n+7)); bat --style=numbers --color=always --highlight-line $n --line-range $low:$high '"\"$file\"" \
                  --preview-window=up:70% \
                  --delimiter=: --with-nth=1,2..)

  [ -z "$selection" ] && return

  local linenr
  linenr=$(echo "$selection" | cut -d: -f1)

  local linecontent
  linecontent=$(sed "${linenr}q;d" "$file")

  local column
  column=$(awk -v IGNORECASE=1 l="$linecontent" -v q="$query" 'BEGIN{print index(l,q)}')

  if [ "$column" -gt 0 ]; then
    ${EDITOR:-vim} +"call cursor($linenr,$column)" "$file"
  else
    ${EDITOR:-vim} +$linenr "$file"
  fi

}
