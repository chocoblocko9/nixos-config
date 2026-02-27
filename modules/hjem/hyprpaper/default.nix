{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.hyprpaper = {
      enable = lib.mkEnableOption "Enable hyprpaper";
    };
  };

  config = lib.mkIf config.hjemSettings.hyprpaper.enable {
    hjem.users.${config.userName} = {
      packages = [ pkgs.hyprpaper ];

      systemd.services.hyprpaper = {
        enable = true;
        wantedBy = [ "graphical-session.target" ];

        unitConfig = {
          Description = "Fast, IPC-controlled wallpaper utility for Hyprland.";
          Documentation = "https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper/";
          PartOf = [ "graphical-session.target" ];
          Requires = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "WAYLAND_DISPLAY"; 
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
          Restart = "on-failure";
        };
     };
      
      files.".config/hypr/hyprpaper.conf".text = ''
        wallpaper {                                                                                                                                                              
          monitor=                                                                                                                                                               
          fit_mode=cover                                                                                                                                                         
          path=~/.files/modules/hjem/hyprpaper/wallpapers/wallpaper14.jpg                                                                                                        
        }                                                                                                                                                                        
        ipc=true                                                                                                                                                                 
        splash=false
      '';
    };
  };
}
