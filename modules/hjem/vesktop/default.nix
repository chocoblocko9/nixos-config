{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.vesktop = {
      enable = lib.mkEnableOption "Enable vesktop related stuff";
    };
  };

  config = lib.mkIf config.hjemSettings.vesktop.enable {
    hjem.users.${config.userName} = {
      packages = [ pkgs.vesktop ];
    };
  };
}
