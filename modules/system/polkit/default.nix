{ lib, config, pkgs, nixpkgs-overlayed, ... }:

{
  options = {
    systemSettings.polkit = {
      enable = lib.mkEnableOption "Enable polkit with soteria";
    };
  };

  config = lib.mkIf config.systemSettings.polkit.enable {
    environment.systemPackages = [ pkgs.soteria ];

    security = {
      polkit.enable = true;
      # soteria.enable = true; # broken :( 
    };
  };
}