{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.hyprpaper = {
      enable = lib.mkEnableOption "Enable hyprpaper";
    };
  };

  config = lib.mkIf config.hjemSettings.hyprpaper.enable {
    hjem.users.${config.userName} = {
      packages = [ pkgs.hyprpaper ];

      files.".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
    };
  };
}
