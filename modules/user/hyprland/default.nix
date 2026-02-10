{ lib, config, pkgs, inputs, ...}:

{
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
        
        # Normal binds
        bind = [
          "$mod, Q, exec, $terminal"
          "$mod, C, exec, bash ~/.files/modules/user/hyprland/minimise.sh"
          "$mod, F, exec, firefox"
          "$mod, M, exec, uwsm stop"
          "$mod, E, exec, $filemanager"
          "$mod, V, togglefloating,"
          "$mod, D, exec, $menu"
          "$mod, P, pseudo,"
          "$mod, J, togglesplit,"

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

          ",XF86Tools, exec, $music"

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
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ];
        bindel = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%-"
        ];
      };
      extraConfig = ''
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

        ### LOOK AND FEEL ### 

        general {
          gaps_in = 5
          gaps_out = 5,10,10,10
  
          border_size = 3
          resize_on_border = true
          hover_icon_on_border = true
          extend_border_grab_area = 25

          allow_tearing = false
          layout = dwindle
        }
  
        decoration {
          rounding = 29
          rounding_power = 1
  
          dim_inactive = true
          dim_strength = 0.35
        } 
  
        ### CURSOR ###
        env = HYPRCURSOR_THEME,phinger-cursors-dark
        env = HYPRCURSOR_SIZE,28
  
        # Screenshots
			  layerrule = match:class selector, no_anim on # fix for weird 1px black border        
      '';
    };
  };
}
