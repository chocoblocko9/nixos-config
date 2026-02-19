{ lib, config, pkgs, inputs, ... }:

{
  imports = [ inputs.stylix.nixosModules.stylix ];

  options = {
    systemSettings.stylix = {
      enable = lib.mkEnableOption "Enable system level stylix theming";
    };
  };

  config = lib.mkIf config.systemSettings.stylix.enable {
    stylix = {
		  enable = true;
      autoEnable = false;
      base16Scheme = ../../../themes/solarized/solarized.yaml;
      #image = ../hyprpaper/wallpapers/wallpaper.jpg;
      polarity = "dark";
      targets = { 
        console.enable = true;
      };
	  };
  };
}
