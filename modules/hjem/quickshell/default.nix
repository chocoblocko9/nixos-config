{ config, lib, pkgs, ... }:

{
  options = {
    hjemSettings.quickshell = {
      enable = lib.mkEnableOption "Enable quickshell";
    };
  };

  config = lib.mkIf config.hjemSettings.quickshell.enable {
    hjem.users.conor = {
      packages = [ pkgs.quickshell ];

      files = {
      # ".config/quickshell/shell.qml".source = ./shell.qml;
      };
    };
  };
}
