{ config, pkgs, inputs, ... }:

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

      ".config/hypr/hyprland.lua".text = ''
        host = "${config.networking.hostName}"

        if (host == "subvert") then 
          hl.exec_once("${inputs.hyprlua.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland")
        end

        require("hyprland/functions")

        require("hyprland/animations")
        require("hyprland/autostart")
        require("hyprland/binds")
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
