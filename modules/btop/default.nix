{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.btop = {
      enable = lib.mkEnableOption "Enable btop";
    };
  };

  config = lib.mkIf config.hjemSettings.btop.enable {
    hjem.users.${config.userName} = {
      packages = [
        pkgs.btop-rocm 
      ];

      files.".config/btop/btop.conf".text = ''
        color_theme = "solarized_dark"
        theme_background = false
        vim_keys = true
        true_color = true
      '';
    };
  };
}
