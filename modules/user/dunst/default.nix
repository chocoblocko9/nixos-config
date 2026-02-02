{ lib, config, ... }:

{
  options = {
    userSettings.dunst = {
      enable = lib.mkEnableOption "Enable dunst";
    };
  };

  config = lib.mkIf config.userSettings.dunst.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          width = "(0,400)";
          height = "(0,325)";
          offset = "(40,20)";
          origin = "top-right";
          frame_color = "#073642";
          background = "#000000C0";
          progress_bar = "true";
          #font = "Monospace 12";
        };
        urgency_normal = {};
      };
    };
  };
}
