{ lib, config, pkgs, ... }:

/*
Hey there! You probably want to comment out lines 23-24 and 35-38 because they make this entire setup impure. 
Alternatively you can put in your own last.fm API keys and change the path or whatever, neither agenix nor 
sops-nix want to work for me so whatever :( Even if you do want to, you have to pass --impure during build
so yeahhh, not the best solution but it works. It's better than committing my API keys to github LOL.
*/

{
  options = {
    userSettings.theming = {
      enable = lib.mkEnableOption "Enable theming stuff";
    };
  };

  config = lib.mkIf config.userSettings.theming.enable {
    qt = {
		  enable = true;
		  style.name = "adwaita-dark";
		  style.package = pkgs.adwaita-qt;
	  };

    home.packages = with pkgs; [
      adw-gtk3  
      numix-icon-theme
      libsForQt5.qt5ct
      nwg-look # GTK themes manager
    ];

    home.file = {
      # This is probably like a comically bad way of doing this but it works okay!! Custom GTK themes are annoying.
      ".config/gtk-3.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk3-dark.css; 
      ".config/gtk-4.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk4-dark.css;      
    };
  };
}