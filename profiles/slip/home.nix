{
  config = {
    userSettings = {
      #      nixcord.enable = true;
      stylix.enable = true;
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
  };
}
