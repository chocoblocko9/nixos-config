{ lib, config, pkgs, inputs, ...}:

{
  imports = [ inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger ];

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

      jq # minimise steam script depends on this
    ];

    programs.hyprcursor-phinger.enable = true; # hyprcursor
  
    home.sessionVariables.NIXOS_OZONE_WL = "1"; # tells electron apps to use wayland or somthing

    # Hyprland Settings (sorry Nix I love you, you are nice to write but trying to configure Hyprland in it was making me lose it)
    # ^^^ Might start undoing that now
    
    wayland.windowManager.hyprland = {
      enable = true;
      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      systemd.enable = false; # Using UWSM
      settings = {
        ### PROGRAMS ###
        "$terminal" = "kitty";
        "$fileManager" = "thunar";
        "$menu" = "wofi --show drun";
        "$music" = "lollypop";

        ### BINDS ###
        "$mod" = "SUPER";
         
        # Mouse binds
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        # Press and hold binds
        bindel = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
          "$mod, F2, exec, ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 - 10 # brightness down"
          "$mod, F3, exec, ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 + 10 # brightness up"
        ];
      };
      extraConfig = ''
        ### PROGRAMS ###
        # $terminal = kitty
        # $fileManager = thunar
        # $menu = wofi --show drun
        # $music = lollypop
  
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
				  name = Lollypop float
				  float = on
				  size = 1700 900
				  match:class = lollypop
			  }
  
			  windowrule {
			    name = opacityRules
			    opacity = 0.96 0.75
			    match:class = negative:kitty
			  }
  
        ### EXEC ON BOOT/RELOAD ###
       
        exec-once = firefox & vesktop & mprisence & soteria
        execr-once = nicotine -n
  
        ### LAYOUT ###
  
        dwindle {
          pseudotile = true 
          preserve_split = true
          smart_split = true
        }
  
        ### INPUT ###
        input {
          kb_layout = ie
          # kb_variant = qwerty
  
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
  
        ### CURSOR ###
        env = HYPRCURSOR_THEME,phinger-cursors-dark
        env = HYPRCURSOR_SIZE,28

        ### BINDS ###
        # $mod = SUPER 
        
        bind = $mod, Q, exec, $terminal
        bind = $mod, C, exec, bash ~/.files/modules/user/hyprland/minimise.sh
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
        bind = ,XF86Tools, exec, $music # I mean it's literally a music note
  
			  # Lollypop specific binds, I don't want it unpausing my youtube video I was watching lol
        bindl = , XF86AudioNext, exec, playerctl --player=Lollypop next
        bindl = , XF86AudioPlay, exec, playerctl --player=Lollypop play-pause
        bindl = , XF86AudioPrev, exec, playerctl --player=Lollypop previous
        bindl = , XF86AudioStop, exec, playerctl --player=Lollypop stop
        bindl = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  
        # Screenshots
        bind = , Print, exec, grim -g "$(slurp -d)" - | wl-copy
			  layerrule = match:class selector, no_anim on # fix for weird 1px black border
  
        # Mouse binds
        # bindm = $mod, mouse:272, movewindow
        # bindm = $mod, mouse:273, resizewindow
  
        # Press and hold binds
        # bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
        # bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-
        # bindel = $mod, F2, exec, ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 - 10 # brightness down
        # bindel = $mod, F3, exec, ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 + 10 # brightness up            
      '';
    };
  };
}
