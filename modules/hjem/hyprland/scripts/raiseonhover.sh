#!/usr/bin/env bash 

# Script to automatically raise specific floating windows when hovered over in Hyprland
# Only applies to Firefox and Vesktop

handle() {
  case $1 in
    activewindow*)
      # Extract the window class from the event
      # Format is: activewindow>>CLASS,TITLE
      window_class=$(echo "$1" | cut -d'>' -f3 | cut -d',' -f1)
      
      # Only raise window if it's Firefox or Vesktop
      if [[ "$window_class" == "firefox" ]] then
        hyprctl dispatch alterzorder top,class:firefox
      elif [[ "$window_class" == "vesktop" ]] then
        hyprctl dispatch alterzorder top,class:vesktop
      fi
      ;;
  esac
}

# Listen to Hyprland events from socket (Claude did this idek what's happening)
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
  handle "$line"
done
