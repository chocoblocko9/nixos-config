{ lib, config, pkgs, inputs, ... }:

{
  imports = [ inputs.stylix.homeModules.stylix ];

  options = {
    userSettings.stylix = {
      enable = lib.mkEnableOption "Enable stylix theming";
    };
  };

  config = lib.mkIf config.userSettings.stylix.enable {
    stylix = {
		  enable = true;
      autoEnable = false;
      base16Scheme = ../../../themes/solarized/solarized.yaml;
      #image = ../hyprpaper/wallpapers/wallpaper.jpg;
      polarity = "dark";
      targets = { 
        nixcord.enable = false;
        waybar.enable = true;
        gtk.enable = true;
        cava.enable = true;
        fuzzel.enable = true;
        hyprland.enable = false;
        dunst = {
          enable = false;
          fonts.enable = true;
          fonts.override = {
            sansSerif = config.stylix.fonts.monospace;
          };
          colors = {
            enable = true;
            override = {
              withHashtag = { 
                base0D = "#073642";
                # base0D = config.lib.stylix.colors.base00; # Why doesn't this work??
                base05 = config.lib.stylix.colors.base06;
              }; 
            };
          };
        };
        qt = {
          enable = true;
          standardDialogs = "gtk3";
        };
      };
      
      opacity = {
        popups = 0.6;
        terminal = 0.6;
      };

      fonts = {
        monospace = {
          name = "JetBrainsMono Nerd Font";
          package = pkgs.nerd-fonts.jetbrains-mono;
        };
        sizes = {
          popups = 12;
          terminal = 13;
        };
      };

      cursor = {
        name = "Phinger Cursors";
        package = pkgs.phinger-cursors;
        size = 24;
      };

      icons = {
        enable = true;
        package = pkgs.numix-icon-theme;
        dark = "Numix";
        light = "Numix-Light";
      };
	  };
  };
}
