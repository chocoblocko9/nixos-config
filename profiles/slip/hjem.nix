{
  imports = [ ../../modules/hjem/modules.nix ];

  hjem.users.conor.directory = "/home/conor";
  # hjem.users.conor.systemd.enable = false;
    
  hjemSettings = {
    apps.enable = true;
    btop.enable = true;
    dunst.enable = true;
    fuzzel.enable = true;
    gaming.enable = true;
    git.enable = true;
    kitty.enable = true;
    music.enable = true;
    hyprpaper.enable = true;
  }; 
}

