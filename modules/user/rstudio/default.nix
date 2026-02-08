{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.rstudio = {
      enable = lib.mkEnableOption "Enable R & RStudio stuff";
    };
  };

  config = lib.mkIf config.userSettings.rstudio.enable {
    home.packages = with pkgs; [
      (rstudioWrapper.override{ packages = with rPackages; [ ggplot2 tidyverse titanic ]; })
    ];
  };
}