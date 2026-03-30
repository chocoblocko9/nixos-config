{
  imports = [ ../../modules/hjem/modules.nix ];

  hjem.users.conor = {
    directory = "/home/conor";
    systemd.enable = true;
    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  hjemSettings.gaming.enable = true;
}

