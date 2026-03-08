{ lib, config, pkgs, ... }:

{
  options = {
    systemSettings.niri = {
      enable = lib.mkEnableOption "Enable niri";
    };
  };

  config = lib.mkIf config.systemSettings.niri.enable {
    programs.niri.enable = true;

    environment.systemPackages = [
      pkgs.fuzzel
      pkgs.alacritty
    ];
  };
}
