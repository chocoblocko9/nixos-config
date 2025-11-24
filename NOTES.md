# Installation notes that may be important

This is where I'm going to catalogue weird imperative stuff that I did, that may be important to look at if I have to build this config again, along with a note saying why

## The list

1. I ran "export XCURSOR_SIZE=24" to get grim + slurp screenshots working because environment variables are weird on hyprland with UWSM. HOWEVER, I did set this in my home.nix after so I don't know if this is relevant


2. I ran "chmod +x ./scripts/rmpc/rmpc-notif" to give it execute permissions so that notifications run on song change. Don't think this is avoidable.
