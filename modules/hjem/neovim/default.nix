{ lib, config, pkgs, inputs, ... }:

{
  imports = [ inputs.mnw.nixosModules.default ];

  options = {
    hjemSettings.neovim = {
      enable = lib.mkEnableOption "Enable neovim";
    };
  };

  config = lib.mkIf config.hjemSettings.neovim.enable {
    environment.systemPackages = [
      pkgs.haskell-language-server
      pkgs.nixd
    ];

    programs.mnw = {
      enable = true;
      initLua = (builtins.readFile (./init.lua));

      plugins = {
        start = with pkgs.vimPlugins; [
          mini-nvim
          nvim-web-devicons
          nvim-cmp
          cmp-nvim-lsp
          cmp-path
          cmp-buffer
          nvim-treesitter
          telescope-nvim
          nvim-tree-lua
          lualine-nvim
          gitsigns-nvim
          plenary-nvim
        ];

        dev.myconfig = {
          pure = ./init.lua;
        };
      };
    };
  };
} 
