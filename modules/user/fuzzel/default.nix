{ lib, config, ... }:

{
  options = {
    userSettings.fuzzel = {
      enable = lib.mkEnableOption "Enable fuzzel with runapp integration";
    };
  };

  config = lib.mkIf config.userSettings.fuzzel.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        border.width = 3;
        main.launch-prefix = "runapp";
      };
    };
  };
}
