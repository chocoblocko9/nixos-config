{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.apps = {
      enable = lib.mkEnableOption "Enable applications that are useful and don't fit elsewhere";
    };
  };

  config = lib.mkIf config.userSettings.apps.enable {
    nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs; [
      # Programs
      vlc

      # Tools
      fastfetch
      zip
      unzip
      feh # GUI image viewer
      xarchiver # GUI archive manager
      ncdu 
      wev 
      unipicker
    ];
  };
}