{
  imports = [ ../../modules/hjem/modules.nix ];

  hjem.users.conor.directory = "/home/conor";
  hjem.users.conor.systemd.enable = false;
    
  hjemSettings = {
    btop.enable = true;
  }; 
}

