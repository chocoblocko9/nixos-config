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
        nerd-fonts._0xproto
        nerd-fonts.hack
        nerd-fonts.symbols-only 
        noto-fonts
        font-awesome
      ];
      fontconfig = {
        defaultFonts.monospace = [
          "JetBrainsMono Nerd Font"
        ];
      };
    };
  };
}
