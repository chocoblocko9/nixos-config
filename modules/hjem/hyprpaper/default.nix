{ config, pkgs, ... }:

{
  hjem.users.${config.userName} = {
    packages = [ pkgs.hyprpaper ];

    files.".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
  };
}
