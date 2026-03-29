{ config, pkgs, ... }:

{
  hjem.users.${config.userName} = {
    packages = [ pkgs.quickshell ];

    files = {
    # ".config/quickshell/shell.qml".source = ./shell.qml;
    };
  };
}
