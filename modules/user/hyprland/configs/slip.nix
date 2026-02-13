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

      bindel = [
        "$mod, F2, exec, ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 - 10 # brightness down"
        "$mod, F3, exec, ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 + 10 # brightness up"
      ];

      animation = {
        bezier = "linear,0,0,1,1";
        animation = "borderangle, 1, 100, linear, loop";
      };

      general = lib.mkForce {
        "col.active_border" = "rgb(072242) rgb(2A7B9B) 90deg";
        "col.inactive_border" = "rgba(595959E6) rgba(000000E6) 30deg";
      };

      bind = [
        "$mod, S, togglespecialworkspace, music"
        "$mod SHIFT, S, movetoworkspace, special:music"
      ];

      exec-once = [ 
        "firefox & vesktop & mprisence & soteria & nicotine -s"
        "[workspace special:music silent] lollypop"
        "hyprctl plugin load \"$HYPR_PLUGIN_DIR/lib/libhyprexpo.so\""
      ];
    };

    extraConfig = ''

    '';
  };
}