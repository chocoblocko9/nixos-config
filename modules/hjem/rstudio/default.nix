{ lib, config, inputs, system, ... }:

{
  options = {
    hjemSettings.rstudio = {
      enable = lib.mkEnableOption "Enable rstudio with overrides";
    };
  };

  config = lib.mkIf config.hjemSettings.rstudio.enable {
    hjem.users.${config.userName} = {
      packages = [ # stable because rstudio takes SO long to build
        # (pkgs-stable.rstudioWrapper.override{ packages = with pkgs-stable.rPackages; [ tidyverse titanic ]; })
        (inputs.nixpkgs-2511.legacyPackages.${system}.rstudioWrapper.override{ packages = with inputs.nixpkgs-2511.legacyPackages.${system}.rPackages; [ tidyverse titanic ]; })
      ];
    };
  };
}
