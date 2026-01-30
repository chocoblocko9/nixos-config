{ lib, config, pkgs, ... }:

{
  options = {
    systemSettings.thunar = {
      enable = lib.mkEnableOption "Enable Thunar file manager";
    };
  };

  config = lib.mkIf config.systemSettings.thunar.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-volman thunar-media-tags-plugin thunar-archive-plugin thunar-vcs-plugin ];
    };
  };
}