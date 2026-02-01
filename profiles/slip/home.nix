{ config, lib, pkgs, pkgs-stable, inputs, ... }:

{
	config = {
		userSettings = {
    	bash.enable = true;
      btop.enable = true;
      dunst.enable = true;
     	gaming.enable = true;
      git.enable = true;
      haskell.enable = true;
			hyprland.enable = true;
			hyprpaper.enable = true;
			hyprsunset.enable = true;
      music.enable = true;
			nixcord.enable = true;
			theming.enable = true;
      vscode.enable = true;
		};

  # Home Manager needs a bit of information about you and the paths it should manage.
  home = {
   	username = "conor";
   	homeDirectory = "/home/conor";
 	  stateVersion = "25.11";
	 };

	stylix = {
		enable = false;
		base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
	};
  
  # The home.packages option allows you to install Nix packages into your environment.
  nixpkgs.config.allowUnfree = true;
  home.packages = 
  	(with pkgs; [
	    # Programs
	    python315
	    jdk21_headless
	    vlc

	    # Tools
	    fastfetch
	    zip
	    unzip
	    feh # GUI image viewer
	    xarchiver # GUI archive manager
	    ncdu 
	    wev 
	    unipicker
  	])

		++

  	(with pkgs-stable; [
			parallel-launcher
  	]);


  # vscode
  programs.vscode = {
    enable = true;
#    profiles.conor.extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
  };

  home.file = {
		".config/gtk-3.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk3-dark.css; 
    ".config/gtk-4.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk4-dark.css;   
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; 
    XCURSOR_SIZE   = "24";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
};
}
