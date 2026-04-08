{ pkgs, ... }:

{
  config = {
    hjem.users.conor = {
      packages = [
        pkgs.neovim
        pkgs.nixd
        pkgs.tree-sitter
        pkgs.gcc
      ];

      files.".config/nvim/init.lua".source = ./init.lua;
    };
  };
} 
