{
  imports = [ ../../modules/hjem/modules.nix ];

  hjem.users.conor = {
    directory = "/home/conor";
    # systemd.enable = true;
    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  hjemSettings = {
    apps.enable = false;
    btop.enable = true;
    fuzzel.enable = true;
    gaming.enable = false;
    git.enable = true;
    hyprland.enable = true;
    kitty.enable = false;
    neovim.enable = false;
    quickshell.enable = true;
    theming.enable = true;
  };
}

