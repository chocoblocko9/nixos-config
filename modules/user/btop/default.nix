{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.btop = {
      enable = lib.mkEnableOption "Enable btop";
    };
  };

  config = lib.mkIf config.userSettings.btop.enable {
    programs.btop = {
      enable = true;
      package = pkgs.btop-rocm;
    };
  };
}
