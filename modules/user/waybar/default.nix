{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.waybar = {
      enable = lib.mkEnableOption "Enable Waybar";
    };
  };

  config = lib.mkIf config.userSettings.waybar.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [ "tray" "clock" ];
        };
      };
    };
  };
}
