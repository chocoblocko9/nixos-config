{ config, pkgs, ...}:

{

  programs = {
    wofi.enable = true;
    kitty = {
      enable = true;
      enableGitIntegration = true;
      settings = {
        background = "#001e26";
        background_opacity = "0.4";
        background_blur = 32;
      };
      font = { 
        size = 12;
        name = "monospace";
      };
    };
  };

  # Hyprland Settings (sorry Nix I love you, you are nice to write but trying to configure Hyprland in it was making me lose it)
  wayland.windowManager.hyprland.extraConfig = ''
      ### PROGRAMS ###
      $terminal = kitty
      $fileManager = Thunar
      $menu = wofi --show drun

      ### WINDOW RULES ###
      windowrule = float, class:org.pulseaudio.pavucontrol
      windowrule = size 1200 800, class:org.pulseaudio.pavucontrol 

      windowrule = opacity 0.96 0.75, class:negative:kitty

      windowrule = float, class:nwg-look
      windowrule = size 1200 800, class:nwg-look

      ### EXEC ON BOOT/RELOAD ###
     
      exec-once = firefox & vesktop
#      exec-once = mpd-discord-rpc 
      exec = bash /home/conor/.files/scripts/hypr/randomwallpaper.sh

      ### LAYOUT ###

      dwindle {
        pseudotile = true 
        preserve_split = true
        smart_split = true
      }

      ### INPUT ###
      input {
        kb_layout = de
        kb_variant = qwerty
 
        follow_mouse = 1
      }

      ### LOOK AND FEEL ### 
      general {
        gaps_in = 5
        gaps_out = 5,10,10,10

        border_size = 3
        resize_on_border = true
        hover_icon_on_border = true
        extend_border_grab_area = 25
 
        col.active_border = rgb(072242) rgb(2A7B9B) 90deg
        col.inactive_border = rgba(595959E6) rgba(000000E6) 30deg

        allow_tearing = false
        layout = dwindle
      }

      decoration {
        rounding = 29
        rounding_power = 1

        dim_inactive = true
        dim_strength = 0.35
      } 

      animation {
        bezier = linear,0,0,1,1
        animation = borderangle, 1, 100, linear, loop
      }

      ### BINDS ###
      $mod = SUPER 
      
      bind = $mod, Q, exec, $terminal
      bind = $mod, C, exec, bash ~/.files/scripts/hypr/minimise.sh
      bind = $mod, F, exec, firefox
      bind = $mod, M, exec, uwsm stop
      bind = $mod, E, exec, $filemanager
      bind = $mod, V, togglefloating,
      bind = $mod, D, exec, $menu
      bind = $mod, P, pseudo,
      bind = $mod, J, togglesplit,

      bind = $mod, left, movefocus, l
      bind = $mod, down, movefocus, d
      bind = $mod, up, movefocus, u
      bind = $mod, right, movefocus, r

      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9
      bind = $mod, 0, workspace, 10
    
      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5
      bind = $mod SHIFT, 6, movetoworkspace, 6
      bind = $mod SHIFT, 7, movetoworkspace, 7
      bind = $mod SHIFT, 8, movetoworkspace, 8
      bind = $mod SHIFT, 9, movetoworkspace, 9
      bind = $mod SHIFT, 0, movetoworkspace, 10
          
      # bind = $mod, S, togglespecialworkspace, magic
      bind = $mod SHIFT, S, movetoworkspace, special:magic

      bind = $mod, S, togglespecialworkspace, magic
      bind = $mod, S, movetoworkspace, +0
      bind = $mod, S, togglespecialworkspace, magic
      bind = $mod, S, movetoworkspace, special:magic
      bind = $mod, S, togglespecialworkspace, magic

   
      bind = $mod, mouse_up, workspace, e-1
      bind = $mod, mouse_down, workspace, e+1
          
      # Top row normal binds
      bind = ,XF86Tools, exec, [float; size 1200 800] kitty rmpc # I mean it's literally a music note

      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPause, exec, playerctl play-pause
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous
      bind = ,XF86AudioMute, exec, wpctl set-mute @DEAFULT_AUDIO_SINK@ toggle

      # Screenshots
      bind = , Print, exec, grim -g "$(slurp -d)" - | wl-copy

      # Mouse binds
      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

      # Press and hold binds
      bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
      bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-
      bindel = $mod, F2, exec, ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 - 10 # brightness down
      bindel = $mod, F3, exec, ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 + 10 # brightness up            
    '';
}
