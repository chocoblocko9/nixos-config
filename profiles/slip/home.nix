{
  config = {
    userSettings = {
      ashell.enable = false;
      bash.enable = true;
      dunst.enable = true;
      git.enable = true;
      haskell.enable = false;
      hyprland = { 
        enable = true;
        profile = "slip";
      };
      hyprpaper.enable = true;
      hyprsunset.enable = true;
      nixcord.enable = true;
      nixvim.enable = true;
      rstudio.enable = true;
      stylix.enable = true;
      theming.enable = false;
      vscode.enable = false;
      waybar.enable = true;
      wofi.enable = true;
    };

    home = {
      username = "conor";
      homeDirectory = "/home/conor";
      stateVersion = "25.11";

      sessionVariables = {
        NIXOS_OZONE_WL = "1"; 
        XCURSOR_SIZE   = "24";
      };
    };
    
    nixpkgs.config.allowUnfree = true;
    programs.home-manager.enable = true;
  };
}
