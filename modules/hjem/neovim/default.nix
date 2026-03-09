{ lib, config, pkgs, inputs, ... }:

{
  imports = [ inputs.mnw.nixosModules.default ];

  options = {
    hjemSettings.neovim = {
      enable = lib.mkEnableOption "Enable neovim";
    };
  };

  config = lib.mkIf config.hjemSettings.neovim.enable {
    hjem.users.conor = {
      packages = [ 
        pkgs.neovim
        pkgs.nixd
        pkgs.haskell-language-server
      ];

      files.".config/nvim/init.lua".source = ./init.lua;
    };
  };
} 
