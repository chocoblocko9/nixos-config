{ lib, config, ... }:

{
  options = {
    userSettings.hyprpaper = {
      enable = lib.mkEnableOption "Enable hyprpaper";
    };
  };

  config = lib.mkIf config.userSettings.hyprpaper.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = true;
        splash = false;

        wallpaper = [ 
          {
            monitor = "HDMI-A-2";
            path = "~/.files/modules/user/hyprpaper/wallpapers/wallpaper.jpg";
            fit_mode = "cover";
          }
        ];
      };
    };
  };
}
