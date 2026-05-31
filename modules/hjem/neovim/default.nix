{ config, lib, pkgs, ... }:

{
  options.hjemSettings.neovim.enable = lib.mkEnableOption "Enable neovim";

  config = lib.mkIf config.hjemSettings.neovim.enable {
    hjem.users.conor = {
      packages = [
        pkgs.neovim
        pkgs.nixd
        pkgs.tree-sitter
        pkgs.gcc
        pkgs.lua-language-server
        # TODO: no.
      ];

      files.".config/nvim/init.lua".source = ./init.lua;
    };
  };
} 
