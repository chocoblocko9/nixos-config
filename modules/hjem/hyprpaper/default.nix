{ pkgs, ... }:

{
  hjem.users.conor = {
    packages = [ pkgs.hyprpaper ];

    files.".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
  };
}
