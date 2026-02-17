{ config, lib, pkgs, inputs, ... }:

{
	config = {
		userSettings = {
			apps.enable = true;
    	bash.enable = true;
      btop.enable = true;
      dunst.enable = true;
      fuzzel.enable = true;
      git.enable = true;
      haskell.enable = true;
			hyprland = {
        enable = true;
        profile = "sleepless";
      };
			hyprpaper.enable = true;
			hyprsunset.enable = true;
      kitty.enable = true;
      music.enable = true;
			nixcord.enable = true;
#      rstudio.enable = true;
			stylix.enable = true;
			theming.enable = true;
      vscode.enable = true;
      waybar.enable = true;
      wofi.enable = true;
		};

    home = {
   	  username = "conor";
   	  homeDirectory = "/home/conor";
 	    stateVersion = "25.11";

      sessionVariables = {
        NIXOS_OZONE_WL = "1"; 
        XCURSOR_SIZE   = "24";
      };
	  };
    
    nixpkgs.config.allowUnfree = true;
    programs.home-manager.enable = true;
  };
}
