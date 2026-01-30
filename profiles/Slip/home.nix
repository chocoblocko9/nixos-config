{ config, lib, pkgs, pkgs-stable, inputs, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "conor";
    homeDirectory = "/home/conor";
    stateVersion = "25.11";
  };

  userSettings = {
    apps.enable = true;
    bash.enable = true;
    btop.enable = true;
    dunst.enable = true;
    gaming.enable = true;
    git.enable = true;
    haskell.enable = true;
    hyprland.enable = true;
    music.enable = true;
    nixcord.enable = true;
    theming.enable = true;
    vscode.enable = true;
  };

  # The home.packages option allows you to install Nix packages into your environment.
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    # EDITOR = "emacs";
    NIXOS_OZONE_WL = "1"; 
    XCURSOR_SIZE = "24";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
