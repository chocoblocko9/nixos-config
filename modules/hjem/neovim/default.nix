{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.neovim = {
      enable = lib.mkEnableOption "Enable neovim";
    };
  };

  config = lib.mkIf config.hjemSettings.neovim.enable {
    environment.sessionVariables = {
      NIXD_FLAGS="--inlay-hints=false";
    };

    hjem.users.conor = {
      packages = [ 
        pkgs.neovim
        pkgs.nixd
        pkgs.haskell-language-server
        pkgs.tree-sitter
        pkgs.gcc
        pkgs.vimPlugins.nvim-treesitter-parsers.nix
        pkgs.vimPlugins.nvim-treesitter-parsers.haskell
      ];

      files.".config/nvim/init.lua".source = ./init.lua;
    };
  };
} 
