{ lib, config, nixpkgs-stable, ... }:

{
  options = {
    userSettings.rstudio = {
      enable = lib.mkEnableOption "Enable R & RStudio stuff";
    };
  };

  config = lib.mkIf config.userSettings.rstudio.enable {
    home.packages = with nixpkgs-stable; [
      (rstudioWrapper.override{ packages = with rPackages; [ tidyverse titanic ]; })
    ];
  };
}
