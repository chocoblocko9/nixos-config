{
  config = {
    userSettings = {
      bash.enable = true;
      dunst.enable = true;
      haskell.enable = false;
      hyprland = {
        enable = true;
        profile = "sleepless";
      };
      hyprsunset.enable = true;
      nixcord.enable = true;
      nixvim.enable = true;
      #rstudio.enable = true;
      stylix.enable = true;
      theming.enable = true;
      waybar.enable = true;
    };

    home = {
      username = "conor";
      homeDirectory = "/home/conor";
      stateVersion = "25.11";

      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XCURSOR_SIZE = "24";
      };
    };

    nixpkgs.config.allowUnfree = true;
    programs.home-manager.enable = true;
  };
}
