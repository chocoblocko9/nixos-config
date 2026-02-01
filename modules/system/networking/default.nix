{ lib, config, ... }:

{
  options = {
    systemSettings.networking = {
      enable = lib.mkEnableOption "Enable networking related settings";
    };
  };

  config = lib.mkIf config.systemSettings.networking.enable {
    services.openssh.enable = true;
    networking = {
      networkmanager.enable = true;
      firewall = {
        allowedTCPPorts = [ 2234 ];
        allowedUDPPorts = [ 2234 ];
      };
    };
  };
}