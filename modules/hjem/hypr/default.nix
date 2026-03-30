{ config, pkgs, ... }:

{
  hjem.users.conor = {
    packages = [ 
      pkgs.hyprsunset
      pkgs.hyprpaper
      pkgs.hyprpicker
      pkgs.hyprshutdown

      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard
    ];

    files = {
      #".config/hypr/hyprland".source = ./hyprland;
      ".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
      ".config/hypr/hyprsunset.conf".source = ./hyprsunset.conf;

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
