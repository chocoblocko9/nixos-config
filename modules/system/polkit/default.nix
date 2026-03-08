{ lib, config, pkgs, ... }:

{
  options = {
    systemSettings.polkit = {
      enable = lib.mkEnableOption "Enable polkit with soteria";
    };
  };

  config = lib.mkIf config.systemSettings.polkit.enable {
    security.polkit.enable = true;

    environment.systemPackages = [ pkgs.soteria ];
  };
}
