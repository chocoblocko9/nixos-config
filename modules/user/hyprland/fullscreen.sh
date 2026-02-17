handle() {
  case $1 in
    fullscreen*)
      # Extract the window class from the event
      # Format is: activewindow>>CLASS,TITLE
      fullscreen_status=$(echo "$1" | cut -d'>' -f3)
      
      # Only raise window if it's Firefox or Vesktop
      if [[ "$fullscreen_status" == "0" ]] then
        hyprctl dispatch movewindowpixel exact 444 44,class:firefox
      fi
      ;;
  esac
}

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
  handle "$line"
done