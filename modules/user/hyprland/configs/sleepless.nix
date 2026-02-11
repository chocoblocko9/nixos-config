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
        "3, horizontal, workspace"
        "3, up, close"
        "3, swipe, mod: ALT, resize"
      ];

      bindel = [
        ",XF86MonBrightnessUp, exec, brightnessctl -q -n s +10%"
        ",XF86MonBrightnessDown, exec, brightnessctl -q -n s 10%-"
      ];

      general = lib.mkForce {
        "col.active_border" = "rgb(2A7B9B)";
        "col.inactive_border" = "rgba(000000E6)";
      };

      monitor = "eDP-1, 1920x1080, 0x0, 1.3";

      exec-once = "firefox & vesktop & soteria";
    };

    extraConfig = ''

    '';
  };
}