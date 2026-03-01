{ lib, config, nixpkgs-stable, ... }:

{
  options = {
    hjemSettings.rstudio = {
      enable = lib.mkEnableOption "Enable rstudio with overrides";
    };
  };

  config = lib.mkIf config.hjemSettings.rstudio.enable {
    hjem.users.${config.userName} = {
      packages = with nixpkgs-stable; [ # stable because rstudio takes SO long to build
        (rstudioWrapper.override{ packages = with rPackages; [ tidyverse titanic ]; })
      ];
    };
  };
}
