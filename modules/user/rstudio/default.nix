{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.rstudio = {
      enable = lib.mkEnableOption "Enable R & RStudio stuff";
    };
  };

  config = lib.mkIf config.userSettings.rstudio.enable {
    home.packages = with pkgs; [
      RStudio-with-my-packages = rstudioWrapper.override{ packages = with rPackages; [ ggplot2 dplyr xts ]; };
    ];
  };
}