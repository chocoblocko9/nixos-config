{ lib, config, ... }:

let 
  cfg = config.userSettings.hyprland.profile;
in {
  config.wayland.windowManager.hyprland = lib.mkIf (cfg == "slip") {
    settings = {
      ### INPUT ###
      input = {
        "kb_layout" = "de";
        "kb_variant" = "qwerty";
        "follow_mouse" = 1;
      };
    };
    extraConfig = ''
      animation {
        bezier = linear,0,0,1,1
        animation = borderangle, 1, 100, linear, loop
      }

      general {
        col.active_border = rgb(072242) rgb(2A7B9B) 90deg
        col.inactive_border = rgba(595959E6) rgba(000000E6) 30deg
      }
    '';
  };
}