{ lib, config, ... }:

{
  options = {
    userSettings.wofi = {
      enable = lib.mkEnableOption "Enable wofi";
    };
  };

  config = lib.mkIf config.userSettings.wofi.enable {
    programs.wofi = { 
      enable = true;
      settings = {
        width = "62%";
        height = "50%";
      };
      style = ''
        * {
            font-size: 22px;
        }
      '';
    };
  };
}
