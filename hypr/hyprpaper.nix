{ config, pkgs, ...}:

services.hyprpaper = {
  enable = true;
  settings = {
    ipc = "on";
    splash = true;
    splash_offset = 2.0;

    preload =
      [ "/home/conor/.files/hypr/wallpapers/example.png" ];

    wallpaper = [
      ", /home/conor/.files/hypr/wallpapers/example.png"
    ];
  };
}