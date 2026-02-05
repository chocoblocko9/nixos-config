{ config, lib, pkgs, inputs, ... }:

{
	config = {
		userSettings = {
			ashell.enable = true;
			apps.enable = true;
    	bash.enable = true;
      btop.enable = true;
      dunst.enable = true;
     	gaming.enable = true;
      git.enable = true;
      haskell.enable = true;
			hyprland.enable = true;
			hyprpaper.enable = true;
			hyprsunset.enable = true;
      kitty.enable = true;
      music.enable = true;
			nixcord.enable = true;
			stylix.enable = true;
			theming.enable = true;
      vscode.enable = true;
      wofi.enable = true;
		};

    # Home Manager needs a bit of information about you and the paths it should manage.
    home = {
   	  username = "conor";
   	  homeDirectory = "/home/conor";
 	    stateVersion = "25.11";
	  };
    
    nixpkgs.config.allowUnfree = true;
  
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1"; 
      XCURSOR_SIZE   = "24";
    };
  
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
