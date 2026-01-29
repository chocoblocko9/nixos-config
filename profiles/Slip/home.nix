{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "conor";
    homeDirectory = "/home/conor";
    stateVersion = "25.11";
  };

  # The home.packages option allows you to install Nix packages into your environment.
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

  home.sessionVariables = {
    # EDITOR = "emacs";
    NIXOS_OZONE_WL = "1"; 
    XCURSOR_SIZE = "24";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
