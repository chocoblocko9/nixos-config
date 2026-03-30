{ pkgs, ... }:

{
  hjem.users.conor = {
    packages = [ pkgs.quickshell ];

    files = {
    # ".config/quickshell/shell.qml".source = ./shell.qml;
    };
  };
}
