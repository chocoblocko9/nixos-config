{ lib, config, nixpkgs-overlayed, ... }:

{
  options = {
    systemSettings.polkit = {
      enable = lib.mkEnableOption "Enable polkit with soteria";
    };
  };

  config = lib.mkIf config.systemSettings.polkit.enable {
    environment.systemPackages = [ nixpkgs-overlayed.soteria ];

    security = {
      polkit.enable = true;
      # soteria.enable = true; # broken :( 
    };
  };
}