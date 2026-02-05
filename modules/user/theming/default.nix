{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.theming = {
      enable = lib.mkEnableOption "Enable theming stuff";
    };
  };

  config = lib.mkIf config.userSettings.theming.enable {
    home.packages = with pkgs; [
      adw-gtk3  
      numix-icon-theme
    ];
  };
}