{
  config = {
    userSettings = {

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
    programs.home-manager.enable = false;
  };
}
