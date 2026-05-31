{ config, lib, pkgs, ... }:

{
  options = {
    hjemSettings.theming = {
      enable = lib.mkEnableOption "Enable theming";
    };
  };

  config = lib.mkIf config.hjemSettings.theming.enable {
    hjem.users.conor = {
      packages = [
        pkgs.adw-gtk3
        pkgs.numix-icon-theme
      ];

      files = {
        ".config/gtk-3.0/gtk.css".source = ../../../themes/adw-solarized/gtk3-dark.css;
        ".config/gtk-4.0/gtk.css".source = ../../../themes/adw-solarized/gtk4-dark.css;
        ".config/Kvantum".source = ../../../themes/Kvantum;
      };
    };
  };
}
