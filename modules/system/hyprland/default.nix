{ lib, config, pkgs, inputs, ... }:

{
  options = {
    systemSettings.hyprland = {
      enable = lib.mkEnableOption "Enable hyprland";
    };
  };

  config = lib.mkIf config.systemSettings.hyprland.enable {
    /*
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    */

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.overrideAttrs {
        patches = [ ./../../../overlays/temp_fix_hyprland.patch ];
      };
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
  };
}