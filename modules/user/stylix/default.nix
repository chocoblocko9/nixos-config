{ lib, config, inputs, ... }:

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
        qt = {
          enable = true;
          standardDialogs = "gtk3";
        };
      };
    };
  };
}
