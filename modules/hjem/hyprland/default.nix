{ config, pkgs, ... }:

{
  hjem.users.conor = {
    packages = with pkgs; [ 
      hyprpicker
      hyprshutdown
      grim
      slurp
      wl-clipboard

      runapp

      # Script stuff
      xdotool
      socat
      jq
    ];

    files = {
      #".config/hypr/hyprland".source = ./hyprland;

      /*  
      It would be nice to do this in lua and in fact I can but this is cleaner cus 
      os.getenv("HOST") doesn't work for unknown reasons, subject to change
      */
      ".config/hypr/hyprland.lua".text =
        let 
          hostConfig = if config.networking.hostName == "slip" 
                       then "host = \"slip\""
                       else "host = \"sleepless\"";
        in ''
          ${hostConfig}

          require("hyprland/animations")
          require("hyprland/autostart")
          require("hyprland/binds")
          require("hyprland/functions")
          require("hyprland/general")
          require("hyprland/input")
          require("hyprland/rules")
          require("hyprland/workspaces")
        '';

      ".config/hypr/xdph.conf".text = ''
        screencopy {
          max_fps = 60
          allow_token_by_default = true
        }
      '';
    };
  };
}
