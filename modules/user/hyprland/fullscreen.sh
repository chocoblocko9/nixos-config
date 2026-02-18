handle() {
  case $1 in
    fullscreen*)
      # Extract the fullscreen status
      # Format is: fullscreen>>(0/1)
      fullscreen_status=$(echo "$1" | cut -d'>' -f3)
      
      # Yes, this moves firefox when ANYTHING unfullscreens, whatever I don't fullscreen much else
      if [[ "$fullscreen_status" == "0" ]]; then
        hyprctl dispatch 'movewindowpixel exact 444 44,class:firefox'
      fi
      ;;
  esac
}

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
  handle "$line"
done