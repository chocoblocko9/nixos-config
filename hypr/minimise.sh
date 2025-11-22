#!/bin/bash

if [ "$(hyprctl activewindow -j | jq -r ".class")" = "lollypop" ]; then
    xdotool getactivewindow windowunmap
else
    hyprctl dispatch killactive ""
fi
