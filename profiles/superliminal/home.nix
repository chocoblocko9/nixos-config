{ config, lib, pkgs, inputs, ... }:

{
	config = {
		userSettings = {
			apps.enable = true;
      git.enable = true;
      music.enable = true;
			theming.enable = true;
		};

		home.packages = with pkgs; [
			hello
    ];

  	home = {
   		username = "ezra";
   		homeDirectory = "/home/ezra";
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
