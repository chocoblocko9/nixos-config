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
    };
  };
}
