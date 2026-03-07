{ lib, config, pkgs, ... }:

{
  options = {
    systemSettings.theming = {
      enable = lib.mkEnableOption "Enable theming";
    };
  };

  config = lib.mkIf config.systemSettings.theming.enable {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only 
      ];
      fontconfig = {
        defaultFonts.monospace = [
          "JetBrainsMono Nerd Font"
        ];
      };
    };
  };
}
