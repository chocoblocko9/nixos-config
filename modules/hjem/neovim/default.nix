{ pkgs, ... }:

{
  config = {
    hjem.users.conor = {
      packages = [ 
        pkgs.neovim
        pkgs.nixd
        pkgs.haskell-language-server
        pkgs.tree-sitter
        pkgs.gcc
        pkgs.ghc
      ];

      files.".config/nvim/init.lua".source = ./init.lua;
    };
  };
} 
