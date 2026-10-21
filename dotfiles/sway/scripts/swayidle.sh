#!/usr/bin/env bash
pkill swayidle
exec swayidle -w \
    timeout 300 'noctalia msg session lock' \
    timeout 600 'swaymsg "output * power off"' \
    resume       'swaymsg "output * power on"' \
    before-sleep 'noctalia msg session lock'
