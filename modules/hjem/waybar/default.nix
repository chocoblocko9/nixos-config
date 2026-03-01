{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.waybar = {
      enable = lib.mkEnableOption "Enable waybar";
    };
  };

  config = lib.mkIf config.hjemSettings.waybar.enable {
    hjem.users.${config.userName} = {
      packages = [ pkgs.waybar ];

      systemd.services.waybar = {
        enable = true;
        wantedBy = [ "graphical-session.target" ];

        unitConfig = {
          Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors";
          Documentation = "https://github.com/Alexays/Waybar/wiki/";
          PartOf = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "WAYLAND_DISPLAY"; 
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.waybar}/bin/waybar";
          Restart = "on-failure";
        };
     };
      
      files.".config/hypr/waybar.conf".text = ''
        wallpaper {                                                                                                                                                              
          monitor=                                                                                                                                                               
          fit_mode=cover                                                                                                                                                         
          path=~/.files/modules/hjem/waybar/wallpapers/wallpaper14.jpg                                                                                                        
        }                                                                                                                                                                        
        ipc=true                                                                                                                                                                 
        splash=false
      '';
    };
  };
}
