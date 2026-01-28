{ lib, config, ... }:

{
  options = {
    systemSettings.bluetooth = {
      enable = lib.mkEnableOption "Enable bluetooth";
    };
  };

  config = lib.mkIf config.systemSettings.bluetooth.enable {
    services.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    environment.systemPackages = with pkgs; [
      bluetuith
    ];
  };
}