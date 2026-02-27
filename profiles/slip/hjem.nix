{
  imports = [ ../../modules/hjem/modules.nix ];

  hjem.users.conor.directory = "/home/conor";
  hjem.users.conor.systemd.enable = false;
    
  hjemSettings = {
    apps.enable = true;
    btop.enable = true;
    fuzzel.enable = true;
    gaming.enable = true;
    kitty.enable = true;
    music.enable = true;
  }; 
}

