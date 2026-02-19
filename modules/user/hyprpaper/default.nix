{ lib, config, ... }:

let
  cfg = config.userSettings;
in {
  options = {
    userSettings.hyprpaper = {
      enable = lib.mkEnableOption "Enable hyprpaper";
    };
  };

  config = lib.mkIf cfg.hyprpaper.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = true;
        splash = false;

        wallpaper = [ 
          {
            monitor = "";
            path = "~/.files/modules/user/hyprpaper/wallpapers/wallpaper14.jpg";
            fit_mode = "cover";
          }
        ];
      };
    };
  };
}
