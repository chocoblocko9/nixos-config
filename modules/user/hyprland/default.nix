{ lib, config, pkgs, inputs, ...}:

let 
  plugin-source = inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [ 
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
    ./configs/slip.nix
    ./configs/sleepless.nix
  ];

  options = {
    userSettings.hyprland = {
      enable = lib.mkEnableOption "Enable hyprland in home-manager";
      profile = lib.mkOption { 
        default = "slip";  
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.userSettings.hyprland.enable {
    home.packages = with pkgs; [
      hyprpicker
	    grim
	    slurp
	    wl-clipboard

      runapp

      # script stuff
      socat
      jq 
    ];

    programs.hyprcursor-phinger.enable = true; # hyprcursor

    home.sessionVariables = { 
      NIXOS_OZONE_WL = "1"; # tells electron apps to use wayland or something
      HYPRCURSOR_THEME = "phinger-cursors-dark";
      HYPRCURSOR_SIZE = "28";
    };  

    wayland.windowManager.hyprland = {
      enable = true;
      # uses packages defined in modules/system/hyprland/default.nix
      package = null;
      portalPackage = null;
      systemd.enable = false; # Using UWSM
      plugins = with plugin-source; [
        hyprexpo
      ];
      settings = {
        ### PROGRAMS ###
        "$terminal" = "kitty";
        "$fileManager" = "thunar";
        "$menu" = "fuzzel";
        "$music" = "lollypop";

        ### BINDS ###
        "$mod" = "SUPER";
        
        # Normal binds
        bind = [
          "$mod, Q, exec, runapp $terminal"
          "$mod, C, exec, bash ~/.files/modules/user/hyprland/minimisesteam.sh"
          "$mod, F, exec, runapp firefox"
          "$mod, M, exec, uwsm stop"
          "$mod, E, exec, runapp $fileManager"
          "$mod, V, togglefloating,"
          "$mod, D, exec, $menu"
          "$mod, P, pseudo,"
          "$mod, J, togglesplit,"
          "$mod, G, hyprexpo:expo, toggle"
          "$mod, R, exec, bash ~/.files/modules/user/hyprland/reset.sh"
          "$mod, S, togglespecialworkspace, magic"
          "$mod, B, exec, bash ~/.files/modules/user/hyprland/minimisetospecial.sh"

          "$mod, left, movefocus, l"
          "$mod, down, movefocus, d"
          "$mod, up, movefocus, u"
          "$mod, right, movefocus, r"

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

          "$mod, mouse_up, workspace, e-1"
          "$mod, mouse_down, workspace, e+1"

          "$mod, mouse_right, layoutmsg, cyclenext"
          "$mod, mouse_left, layoutmsg, cycleprev"

          # Open music app
          ",XF86Tools, exec, $music"

          # Screenshot bind
          ", Print, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        ];
        
        # Mouse binds
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        # Top row media keys binds
        bindl = [
          ", XF86AudioNext, exec, playerctl --player=Lollypop next"
          ", XF86AudioPlay, exec, playerctl --player=Lollypop play-pause"
          ", XF86AudioPrev, exec, playerctl --player=Lollypop previous"
          ", XF86AudioStop, exec, playerctl --player=Lollypop stop"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          # Zoom
          "$mod, Z, exec,hyprctl keyword cursor:zoom_factor 2.5"
        ];

        bindrl = [ 
          "$mod, Z, exec,hyprctl keyword cursor:zoom_factor 1"
        ];

        bindel = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%-"
        ];

        ### EXECUTE ON BOOT ###

        exec-once = [ 
          "vesktop & soteria"
          "[workspace 2 silent] code"
          "hyprctl plugin load \"$HYPR_PLUGIN_DIR/lib/libhyprexpo.so\""
          "bash ~/.files/modules/user/hyprland/raiseonhover.sh"
          "bash ~/.files/modules/user/hyprland/fullscreen.sh"
        ];

        ### WINDOW RULES ###

        windowrule = [ 
          "tag +defFloat, match:class org.pulseaudio.pavucontrol"
			    "tag +defFloat, match:class nwg-look"
			    "tag +defFloat, match:title File Operation Progress"

          {
            name = "Default Float Behaviour";
			      float = "on";
			      size = "(monitor_w*0.75) (monitor_h*0.75)";
			      "match:tag" = "defFloat";
          }

          {
				    name = "Lollypop float";
				    float = "on";
            size = "(monitor_w*0.9) (monitor_h*0.9)";
				    "match:class" = "lollypop";
			    }
        ];

        ### WORKSPACE RULES ###
        workspace = [
          "3, persistent:true"
          "4, persistent:true, layout:monocle"
          "5, persistent:true, layout:scrolling"
        ];

        ### LAYER RULES ###
			  layerrule = [
          "match:class selector, no_anim on" # fix for weird 1px black border on screenshots
        ];

        ### LAYOUT ###

        dwindle = {
          pseudotile = "true";
          preserve_split = "true";
          smart_split = "true";
        };

        ### LOOK AND FEEL ### 

        general = {
          gaps_in = "5";
          gaps_out = "5,10,10,10";

          border_size = "3";
          resize_on_border = "true";
          hover_icon_on_border = "true";
          extend_border_grab_area = "25";

          allow_tearing = "false";
          layout = "dwindle";        
        };

        decoration = {
          rounding = 29;
          rounding_power = 1;
  
          dim_inactive = true;
          dim_strength = 0.35;

          blur = {
            special = true;
          };
        };

        ### ANIMATIONS ###
        animations = {
          enabled = true;
          workspace_wraparound = true;

          bezier = [
            "easeInOutBack, 0.68, -0.6, 0.32, 1.6"
            "easeInOutSine, 0.37, 0, 0.63, 1"

            "easeInExpo, 0.7, 0, 0.84, 0"

            "easeOutQuart, 0.25, 1, 0.5, 1"        
            "easeOutExpo, 0.16, 1, 0.3, 1"
            "easeOutExpoOvershoot, 0.16, 1, 0.3, 1.05"
            "easeOutCirc, 0.85, 0, 0.15, 1"

            "bouncyThing, 0.15, 0.60, 0.66, -0.61"
          ];

          animation = [
            "windowsIn, 1, 2.5, easeOutExpo, popin"
            "windowsOut, 1, 4, easeOutExpo, popin 10%"

            "workspaces, 1, 0.8, easeInOutSine, slidefade 50%"
            "specialWorkspaceIn, 1, 2.8, easeOutExpoOvershoot, slide top"
            "specialWorkspaceOut, 1, 5, easeInOutBack, slide bottom"
          ];
        };
        

        ### PLUGINS ###
        plugin = {
          hyprexpo = {
            columns = 3;
            gap_size = 5;
            bg_col = "rgb(111111)";
            workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1
            skip_empty = true;

            gesture_distance = 300; # how far is the "max" for the gesture
          };
        };
      };
      extraConfig = '' 

      '';
    };

    # XDPH settings
    home.file.".config/hypr/xdph.conf".text = ''
      screencopy {
        max_fps = 60
        allow_token_by_default = true # BANGER option right here
      }
    '';
  };
}
