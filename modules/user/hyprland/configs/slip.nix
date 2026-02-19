{ lib, config, ... }:

let 
  cfg = config.userSettings.hyprland.profile;
in {
  config.wayland.windowManager.hyprland = lib.mkIf (cfg == "slip") {
    settings = {
      ### INPUT ###
      input = {
        "kb_layout" = "eu";
        "kb_variant" = "";
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

      general = {
        "col.active_border" = "rgb(072242) rgb(2A7B9B) 90deg";
        "col.inactive_border" = "rgba(595959E6) rgba(000000E6) 30deg";
      };

      windowrule = [
        {
			    name = "opacityRules";
		      opacity = "0.96 0.75";
		      "match:class" = "negative:kitty";
		    }

        {
          name = "firefox behaviour";
          float = "on";
          size = "1463 1023";
          move = "444 44";
          workspace = 1;
          "match:class" = "firefox";
        }
        
        {
          name = "vesktop behaviour";
          float = "on";
          size = "1463 1023";
          move = "12 44";
          workspace = 1;
          "match:class" = "vesktop";
        }
      ];

      bind = [
        "$mod, S, togglespecialworkspace, music"
        "$mod SHIFT, S, movetoworkspace, special:music"
      ];

      exec-once = [ 
        "mprisence & vesktop & nicotine -s"
        "[workspace special:music silent] lollypop"
      ];
    };

    extraConfig = ''

    '';
  };
}