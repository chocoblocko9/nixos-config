{ lib, config, inputs, ... }:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  options = {
    userSettings.nixvim = {
      enable = lib.mkEnableOption "Enable Neovim with Nixvim";
    };
  };

  config = lib.mkIf config.userSettings.nixvim.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
    };
  };
}