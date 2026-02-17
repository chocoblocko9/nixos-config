{ lib, config, ... }:

{
  options = {
    userSettings.kitty = {
      enable = lib.mkEnableOption "Enable kitty";
    };
  };

  config = lib.mkIf config.userSettings.kitty.enable {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      settings = {
        #background = "#001e26";
        #background_opacity = "0.6";
        background_blur = 32;
      };
    };
  };
}
