{ lib, config, ... }:

let 
  cfg = config.userSettings.hyprland.profile;
in {
  config.wayland.windowManager.hyprland = lib.mkIf (cfg == "sleepless") {
    extraConfig = ''
      general {
        col.active_border = rgb(2A7B9B) 
        col.inactive_border = rgba(000000E6)
      }

      monitor = eDP-1, 1920x1080, 0x0, 1.25
    '';

    settings = {
      ### INPUT ###
      input = {
        "kb_layout" = "ie";
        "follow_mouse" = 1;
      };

      gesture = [
        "3, horizontal, workspace"
        "3, down, close"
        "3, swipe, mod: ALT, resize"
      ];
    };
  };
}