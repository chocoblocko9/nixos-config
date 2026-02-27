{
  imports = [ ../../modules/hjem/modules.nix ];

  hjem.users.conor.directory = "/home/conor";
    
  hjemSettings = {
    apps.enable = true;
    btop.enable = true;
    fuzzel.enable = true;
    gaming.enable = false;
    git.enable = true;
    hyprpaper.enable = true;
    kitty.enable = true;
    music.enable = false; 
  }; 
}

