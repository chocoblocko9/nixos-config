{
  imports = [ ../../modules/btop/default.nix ];

  hjem.users.conor.directory = "/home/conor";
  hjem.users.conor.systemd.enable = false;
    
  hjemSettings = {
    btop.enable = true;
  }; 
}

