#!/usr/bin/env bash

STATE_FILE="${XDG_RUNTIME_DIR}/theme-mode"

DARK_WALLPAPER="$HOME/Pictures/Wallpapers/michael.jpg"
LIGHT_WALLPAPER="$HOME/Pictures/Wallpapers/womanlauds.png"

if [[ "$(cat "$STATE_FILE" 2>/dev/null)" == "light" ]]; then
    MODE="dark"
else
    MODE="light"
fi

echo "$MODE" > "$STATE_FILE"

# 1. Set wallpaper first — Noctalia derives colors from it if using wallpaper mode
if [[ "$MODE" == "dark" ]]; then
    noctalia-shell ipc call wallpaper set "$DARK_WALLPAPER" all
else
    noctalia-shell ipc call wallpaper set "$LIGHT_WALLPAPER" all
fi

# 2. Noctalia dark mode — regenerates all templates using the new wallpaper
if [[ "$MODE" == "dark" ]]; then
    noctalia-shell ipc call darkMode setDark
else
    noctalia-shell ipc call darkMode setLight
fi

sleep 0.5

# 3. gsettings — live GTK4/libadwaita
if [[ "$MODE" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
fi

# 4. Kitty
if [[ "$MODE" == "dark" ]]; then
    cp "$HOME/.config/kitty/themes/dark.conf" "$HOME/.config/kitty/themes/active.conf"
else
    cp "$HOME/.config/kitty/themes/light.conf" "$HOME/.config/kitty/themes/active.conf"
fi
kill -SIGUSR1 $(pgrep -a kitty | awk '{print $1}') 2>/dev/null

# 5. Emacs
if [[ "$MODE" == "dark" ]]; then
    emacsclient --no-wait --eval "(my/set-theme \"dark\")" 2>/dev/null
else
    emacsclient --no-wait --eval "(my/set-theme \"light\")" 2>/dev/null
fi
