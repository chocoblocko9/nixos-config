{ lib, config, pkgs, ... }:

{
  options = {
    systemSettings.bluetooth = {
      enable = lib.mkEnableOption "Enable bluetooth";
    };
  };

  config = lib.mkIf config.systemSettings.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    environment.systemPackages = [ pkgs.bluetuith ];
  };
}
