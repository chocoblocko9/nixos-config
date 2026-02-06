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
            # monitor = (if cfg.hyprland.profile == "slip" then "HDMI-A-2" else "eDP-1"); # Old logic
            monitor = ""; # abuse fallback (I'm poor and don't have a second monitor rip)
            path = "~/.files/modules/user/hyprpaper/wallpapers/wallpaper14.jpg";
            fit_mode = "cover";
          }
        ];
      };
    };
  };
}
