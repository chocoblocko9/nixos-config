# Script to automatically raise floating windows when hovered over in Hyprland
# This listens to Hyprland's activewindow events and brings the focused window to top

handle() {
  case $1 in
    activewindow*)
      # When the active window changes, bring it to the top
      hyprctl dispatch bringactivetotop
      ;;
  esac
}

# Listen to Hyprland events via socket
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
  handle "$line"
done
