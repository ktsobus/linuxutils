# Display custom neofetch with Solothurn temperature if all dependencies are installed
if command -v neofetch &> /dev/null && command -v ansiweather &> /dev/null && command -v cowsay &> /dev/null; then
    neofetch --ascii "$(echo "Solothurn: $(ansiweather -l 'Solothurn, CH' -u metric | grep -oP '\-?\d+ °C')" | cowsay -f tux -W 27 | sed '1i\\n')"
elif command -v neofetch &> /dev/null; then
    # Fallback to regular neofetch if all dependencies aren't available
    neofetch
fi
