{ lib, config, ... }:

{
  options = {
    systemSettings.polkit= {
      enable = lib.mkEnableOption "Enable polkit with soteria";
    };
  };

  config = lib.mkIf config.systemSettings.polkit.enable {
    security.soteria.enable = true;
  };
}