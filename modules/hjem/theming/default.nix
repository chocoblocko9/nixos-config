{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.theming = {
      enable = lib.mkEnableOption "Enable theming related stuff";
    };
  };

  config = lib.mkIf config.hjemSettings.theming.enable {
    hjem.users.${config.userName} = {
      packages = with pkgs; [ # stable because theming takes SO long to build
        adw-gtk3
        numix-icon-theme
     ];
    };
  };
}
