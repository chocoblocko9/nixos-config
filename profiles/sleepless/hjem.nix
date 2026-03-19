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
    
  hjemSettings = {
    apps.enable = true;
    btop.enable = true;
    dev.enable = true;
    dunst.enable = true;
    fuzzel.enable = true;
    gaming.enable = false;
    git.enable = true;
    kitty.enable = true;
    hyprland = {
      enable = true;
      profile = "sleepless";
    }; 
    hyprpaper.enable = true;
    hyprsunset.enable = true;
    music.enable = true;
    neovim.enable = true;
    quickshell.enable = true;
    rstudio.enable = true;
    theming.enable = true;
    waybar.enable = false;
  }; 
}

