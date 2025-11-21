{ config, pkgs, ...}:

{
  programs.kitty.enable = true;
  programs.wofi.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Execute on boot
      "exec-once" = [
        "firefox"
        "vesktop"
        # "hyprpaper" don't need this maybe? service should be enabled theoretically
      ];
      
      "dwindle" = {
        "pseudotile" = true; 
        "preserve_split" = true; 
      };

      "input" = {
        "kb_layout" = "de";
        "kb_variant" = "qwerty";
      };

      # Environment Variables
      "env" = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,18"
      ];

      # Look and feel
      "general" = {
        "gaps_in" = "5";
        "gaps_out" = "5,10,10,10";
        
        "border_size" = "3";
        "resize_on_border" = true;
        "hover_icon_on_border" = true;
        "extend_border_grab_area" = "25";
    
        "col.active_border" = "rgb(072242) rgb(2A7B9B) 60deg";
        "col.inactive_border" = "rgba(595959E6) rgba(000000E6) 30deg";

        "allow_tearing" = false;
        "layout" = "dwindle";
      };

      "decoration" = {
        "rounding" = "20";
        "rounding_power" = "1";

        "active_opacity" = "0.95";
        "inactive_opacity" = "0.6";
        "dim_inactive" = true;
        "dim_strength" = "0.35";
      };

      # Set apps
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "Thunar";
      "$menu" = "wofi --show drun";
  
      # Keybinds
      bind = 
        [
          # Standard program binds
          "$mod, F, exec, firefox"
          ", Print, exec, grimblast copy area" 
          "$mod, Q, exec, $terminal"
          "$mod, M, exec, uwsm stop"
          "$mod, C, killactive,"
          "$mod, E, exec, $fileManager"
          "$mod, V, togglefloating,"
          "$mod, D, exec, $menu"
          "$mod, P, pseudo," # dwindle
          "$mod, J, togglesplit," # dwindle

          # Shift focus with arrow keys
          "$mod, left, movefocus, l"
          "$mod, down, movefocus, d"
          "$mod, up, movefocus, u"
          "$mod, right, movefocus, r"

          # Workspace switching with $mod + number
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move focused window to workspace with $mod + SHIFT + number
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Special workspace (from example config currently)
          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"

          # Scroll through workspaces
          "$mod, mouse_up, workspace, e-1"
          "$mod, mouse_down, workspace, e+1"
          
          # Keyboard has a music note button on F1, might as well
          ",XF86Tools, exec, lollypop"

          # Screenshots
          ", Print, exec, grim -g \"$(slurp -d)\" - | wl-copy"
      ];

      # Mouse binds
      bindm = 
        [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
      ];  

      bindel = 
        [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEAFULT_AUDIO_SINK@ toggle"
          "$mod, F4, exec, wpctl set-mute @DEAFULT_AUDIO_SINK@ toggle"
          "$mod, F2, exec, ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 - 10" # brightness down
          "$mod, F3, exec, ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 + 10" # brightness up
        ];
      
     
    };
  };
}
