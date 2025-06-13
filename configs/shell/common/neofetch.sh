# Display custom neofetch with Solothurn temperature if all dependencies are installed
if command -v neofetch >/dev/null 2>&1 && command -v ansiweather >/dev/null 2>&1 && command -v cowsay >/dev/null 2>&1; then
    temp=$(ansiweather -l 'Solothurn, CH' -u metric | grep -oP '\-?\d+ °C')
    neofetch --ascii "$(echo "Solothurn: $temp" | cowsay -f tux -W 27 | sed '1i\\n')"
elif command -v neofetch >/dev/null 2>&1; then
    # Fallback to regular neofetch if all dependencies aren't available
    neofetch
fi

