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
            # This is a little ugly but it works perfectly for 2 profiles
            monitor = (if "$HOSTNAME" == "slip" then "HDMI-A-2" else "eDP-1");
            path = "~/.files/modules/user/hyprpaper/wallpapers/wallpaper.jpg";
            fit_mode = "cover";
          }
        ];
      };
    };
  };
}
