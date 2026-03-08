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
      plugins = [ 
        pkgs.thunar-volman 
        pkgs.thunar-media-tags-plugin 
        pkgs.thunar-archive-plugin 
        pkgs.thunar-vcs-plugin 
      ];
    };
  };
}
