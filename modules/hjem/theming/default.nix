{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.theming = {
      enable = lib.mkEnableOption "Enable theming related stuff";
    };
  };

  config = lib.mkIf config.hjemSettings.theming.enable {
    hjem.users.${config.userName} = {
      packages = with pkgs; [ # stable because theming takes SO long to build
        adw-gtk3
        numix-icon-theme
      ];
      files = {  
        ".config/gtk-3.0/gtk.css".source = ../../../themes/adw-colors/adw-solarized/gtk3-dark.css;
        ".config/gtk-4.0/gtk.css".source = ../../../themes/adw-colors/adw-solarized/gtk4-dark.css;
      };
    };
  };
}
