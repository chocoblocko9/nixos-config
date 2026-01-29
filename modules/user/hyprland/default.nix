{ lib, config, pkgs, ... }: 

{
  options = {
    userSettings.hyprland = {
      enable = lib.mkEnableOption "Enable hyprland in home-manager";
    };
  };

  config = lib.mkIf config.userSettings.hyprland.enable {
    home.packages = with pkgs; [
      hyprpicker
      grim
      slurp
      wl-clipboard
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      systemd.enable = false;
      extraConfig = ''
        ### PROGRAMS ###
        $terminal = kitty
        $fileManager = Thunar
        $menu = wofi --show drun

        ### WINDOW RULES ###
			  windowrule = tag +defFloat, match:class org.pulseaudio.pavucontrol
			  windowrule = tag +defFloat, match:class nwg-look
			  windowrule = tag +defFloat, match:title File Operation Progress

			  windowrule {
  			  name = Default Float Behaviour
			    float = on
			    size = 1200 800
			    match:tag = defFloat
			  }


			  windowrule {
			    name = opacityRules
			    opacity = 0.96 0.75
			    match:class = negative:kitty
			  }
  
        ### EXEC ON BOOT/RELOAD ###

        exec-once = firefox & vesktop & soteria 

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

			  # mpd specific binds, might still change these but as it stands I use mpd a lot more than playerctl stuff
        bindl = , XF86AudioNext, exec, rmpc next
        bindl = , XF86AudioPlay, exec, rmpc togglepause
        bindl = , XF86AudioPrev, exec, rmpc prev

        bind = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

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
    };

    services = {
      hyprsunset = {
        enable = true;
        settings = {
          max-gamma = 150;

          profile = [
            # Morning
            {
              time = "08:00";
              temperature = 4786;
              gamma = 0.87;
            }
            {
              time = "08:30";
              temperature = 5072;
              gamma = 0.89;
            }
            {
              time = "09:00";
              temperature = 5358;
              gamma = 0.91;
            }
            {
              time = "09:30";
              temperature = 5644;
              gamma = 0.93;
            }
            {
              time = "10:00";
              temperature = 5930;
              gamma = 0.95;
            }
            {
              time = "10:30";
              temperature = 6216;
              gamma = 0.97;
            }
            {
              time = "11:00";
              temperature = 6500;
              gamma = 1.0;
            }

            # Night
            {
              time = "21:00";
              temperature = 6300;
            }
            {
              time = "21:30";
              temperature = 6150;
            }
            {
              time = "22:00";
              temperature = 6000;
              gamma = 0.96;
            }
            {
              time = "22:30";
              temperature = 5850;
              gamma = 0.94;
            }
            {
              time = "23:00";
              temperature = 5700;
              gamma = 0.92;
            }
            {
              time = "23:30";
              temperature = 5550;
              gamma = 0.9;
            }
            {
              time = "00:00";
              temperature = 5400;
            }
            {
              time = "00:30";
              temperature = 5250;
              gamma = 0.88;
            }
            {
              time = "01:00";
              temperature = 5100;
            }
            {
              time = "01:30";
              temperature = 5000;
              gamma = 0.86;
            }
            {
              time = "02:00";
              temperature = 4800;
            }
            {
              time = "02:30";
              temperature = 4600;
              gamma = 0.85;
            }
            {
              time = "03:00";
              temperature = 4500;
            }
          ];
        };
      };

      hyprpaper = {
        enable = true;
        settings = {
          ipc = true;
          splash = false;

          wallpaper = [ 
            {
              monitor = "HDMI-A-2";
              path = "./wallpapers/wallpaper.jpg";
            }
          ];
        };
      };
    };
  };
}
