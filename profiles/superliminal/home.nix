{ config, lib, pkgs, inputs, ... }:

{
	config = {
		userSettings = {
			apps.enable = true;
      git.enable = true;
      music.enable = true;
			theming.enable = true;
		};

  # Home Manager needs a bit of information about you and the paths it should manage.
  home = {
   	username = "ezra";
   	homeDirectory = "/home/ezra";
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
