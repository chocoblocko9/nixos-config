{ lib, config, pkgs, inputs, ... }:

let
  #source = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
  source = inputs.hyprland-layouts-rethonked.packages.${pkgs.stdenv.hostPlatform.system};
  cfg = config.systemSettings.hyprland;
in {
  options = {
    systemSettings.hyprland = {
      enable = lib.mkEnableOption "Enable hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package = source.hyprland;
      portalPackage = source.xdg-desktop-portal-hyprland;
    };

    environment.sessionVariables = {
  	  NIXOS_OZONE_WL = "1"; 
    };
  };
}