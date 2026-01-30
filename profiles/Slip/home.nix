{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "conor";
    homeDirectory = "/home/conor";
    stateVersion = "25.11";
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
    NIXOS_OZONE_WL = "1"; 
    XCURSOR_SIZE = "24";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
