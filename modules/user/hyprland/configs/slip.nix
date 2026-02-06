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
  };
}