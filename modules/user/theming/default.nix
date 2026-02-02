{ lib, config, pkgs, ... }:

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
      catppuccin-cursors.latteBlue
      #nwg-look # GTK themes manager
    ];

    home.file = {
      # This is probably like a comically bad way of doing this but it works okay!! Custom GTK themes are annoying.
      #".config/gtk-3.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk3-dark.css; 
      #".config/gtk-4.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk4-dark.css;      
    };
  };
}