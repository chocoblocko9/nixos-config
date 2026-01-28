{ lib, config, ... }:

{
  options = {
    systemSettings.bluetooth = {
      enable = lib.mkEnableOption "Enable bluetooth";
    };
  };

  config = lib.mkIf config.systemSettings.bluetooth.enable {
    security.soteria.enable = true;
  };
}