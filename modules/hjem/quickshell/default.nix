{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.quickshell = {
      enable = lib.mkEnableOption "Enable quickshell related stuff";
    };
  };

  config = lib.mkIf config.hjemSettings.quickshell.enable {
    hjem.users.${config.userName} = {
      packages = with pkgs; [ 
        quickshell 
      ];
      files = {  
      # ".config/quickshell/shell.qml".source = ./shell.qml;
      };

      systemd.services.quickshell = {
        enable = false;
        wantedBy = [ "graphical-session.target" ];

        unitConfig = {
          Description = "Flexible toolkit for making desktop shells with QtQuick, for Wayland and X11";
          Documentation = "https://quickshell.org/docs/v0.2.1/guide/install-setup/";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.quickshell}/bin/quickshell";
          Restart = "on-failure";
        };
      };
    };
  };
}
