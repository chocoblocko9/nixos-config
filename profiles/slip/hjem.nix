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
    apps.enable = true;
    btop.enable = true;
    fuzzel.enable = true;
    gaming.enable = true;
    git.enable = true;
    hyprland.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    quickshell.enable = true;
    theming.enable = true;
    x11.enable = true;
  };
}

