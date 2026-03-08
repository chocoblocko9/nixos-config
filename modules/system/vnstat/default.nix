{lib, config, ...}: 

{
  options = {
    systemSettings.vnstat = {
      enable = lib.mkEnableOption "Enable vnstat";
    };
  };

  config = lib.mkIf config.systemSettings.vnstat.enable {
    services.vnstat.enable = true;
  };
}
