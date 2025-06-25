if command -v neofetch >/dev/null 2>&1 && \
   command -v ansiweather >/dev/null 2>&1 && \
   command -v cowsay >/dev/null 2>&1; then

    # Detect shell and set color
    if [ -n "$ZSH_VERSION" ]; then
        PINGU_COLOR=$'\033[38;2;255;215;0m'      # Gold for zsh
        PINGU_COLOR=$'\033[38;2;255;146;176m'      # Pink for zsh
    elif [ -n "$BASH_VERSION" ]; then
        PINGU_COLOR=$'\033[1;36m'                # Cyan for bash
    elif [ -n "$ASH_VERSION" ] || [ -n "$SH_VERSION" ] || [ "$(basename "$SHELL")" = "ash" ]; then
        PINGU_COLOR=$'\033[38;2;243;139;168m'    # Pink for ash
    else
        PINGU_COLOR=$'\033[1;37m'                # White for others
    fi
    RESET_COLOR=$'\033[0m'

    temp=$(ansiweather -l 'Solothurn, CH' -u metric | grep -oP '\-?\d+ °C')
    neofetch --ascii "$(
        echo "Solothurn: $temp" | cowsay -f flaming-sheep -W 27 | \
        sed "s/^/${PINGU_COLOR}/; s/$/${RESET_COLOR}/"
    )"

elif command -v neofetch >/dev/null 2>&1; then
    neofetch
fi
