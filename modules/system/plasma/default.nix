{ lib, config, ... }:

{
  options = {
    systemSettings.plasma = {
      enable = lib.mkEnableOption "Enable KDE Plasma 6";
    };
  };

  config = lib.mkIf config.systemSettings.plasma.enable {
    services = {
      xserver.enable = true;
      desktopManager.plasma6.enable = true;
    };

    environment.sessionVariables = {
  	  NIXOS_OZONE_WL = "1"; 
    };
  };
}
