{ pkgs, inputs, ... }:

let
  source = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = source.hyprland;
    portalPackage = source.xdg-desktop-portal-hyprland;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; 
  };
}
