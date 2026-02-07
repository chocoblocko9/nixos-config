{ lib, config, ... }:

let 
  cfg = config.userSettings.hyprland.profile;
in {
  config.wayland.windowManager.hyprland = lib.mkIf (cfg == "sleepless") {
    settings = {
      ### INPUT ###
      input = {
        "kb_layout" = "ie";
        "follow_mouse" = 1;
      };

      gesture = [
        "2, horizontal, workspace"
      ];
    };
  };
}