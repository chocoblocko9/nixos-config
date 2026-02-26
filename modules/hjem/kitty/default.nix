{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.kitty = {
      enable = lib.mkEnableOption "Enable kitty";
    };
  };

  config = lib.mkIf config.hjemSettings.kitty.enable {
    hjem.users.${config.userName} = {
      packages = [
        pkgs.kitty 
      ];

      files.".config/kitty/kitty.conf".text = ''
        font_family JetBrainsMono Nerd Font
        font_size 14

        shell_integration no-rc

        background #001e26
        background_blur 32
        background_opacity 0.700000
      '';
    };
  };
}
