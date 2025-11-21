{ config, pkgs, ...}:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = true;
      splash_offset = 2.0;

      preload = [
        "/home/conor/.files/hypr/wallpapers/wallpaper.jpg"
        "/home/conor/.files/hypr/wallpapers/wallpaper2.png"
      ];

      wallpaper = 
        [ ", /home/conor/.files/hypr/wallpapers/wallpaper.jpg" ];
    };
  };
}
