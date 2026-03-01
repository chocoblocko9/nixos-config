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

      globals.mapleader = " ";

      # Basic vim options
      opts = {
        number = true;
        relativenumber = true;   # Relative line numbers for jumping
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;        # Spaces instead of tabs
        smartindent = true;
        wrap = false;
        swapfile = false;
        backup = false;
        termguicolors = true;
        scrolloff = 12;          # Keep 8 lines visible above/below cursor
        signcolumn = "yes";      # Always show sign column (for git/lsp)
      };

      # Treesitter for syntax highlighting
      plugins.treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      # LSP stuff
      plugins.lsp = {
        enable = true;
        servers = {
          # Nix
          nixd.enable = true;

          # Haskell
          hls = {
            enable = true;
            installGhc = true;
          };
        };

        keymaps = {
          diagnostic = {
            "<leader>j" = "goto_next";
            "<leader>k" = "goto_prev";
          };
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gr" = "references";
            "gi" = "implementation";
            "K" = "hover";
            "<leader>ca" = "code_action";
            "<leader>rn" = "rename";
          };
        };
      };

      # Autocompletion
      plugins.cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-e>" = "cmp.mapping.close()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          };
        };
      };

      plugins.visual-whitespace = {
        enabled = true;
        match_types = {
          lead = true;
          nbsp = true;
          space = true;
          tab = true;
          trail = true;
        };
      };

      # File tree
      plugins.nvim-tree = {
        enable = true;
        openOnSetup = true;
      };

      plugins.telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };
      };

      # Git integration
      plugins.gitsigns = {
        enable = true;
        settings = {
          current_line_blame = true;  # Show blame on current line
          signs = {
            add.text = "+";
            change.text = "~";
            delete.text = "_";
            topdelete.text = "‾";
            changedelete.text = "~";
          };
        };
      };

      plugins.web-devicons.enable = true;

      colorschemes.mini-base16 = {
        enable = true;
        settings.palette = {
          base00 = "#001e26";
          base01 = "#073642";
          base02 = "#586e75";
          base03 = "#657b83";
          base04 = "#839496";
          base05 = "#cac6b8";
          base06 = "#eee8d5";
          base07 = "#fdf6e3";
          base08 = "#dc322f";
          base09 = "#ff5c00";
          base0A = "#cecb00";
          base0B = "#19cb00";
          base0C = "#0dcdcd";
          base0D = "#0d73cc";
          base0E = "#cb1ed1";
          base0F = "#7579bd";
        };
      };

      # Status line
      plugins.lualine = {
        enable = true;
      };

      # Better syntax for many languages
      plugins.vim-nix.enable = true;

      # Key mappings
      keymaps = [
        # File tree toggle
        {
          mode = "n";
          key = "<leader>e";
          action = ":NvimTreeToggle<CR>";
          options.silent = true;
        }

        # Save file
        {
          mode = "n";
          key = "<leader>w";
          action = ":w<CR>";
        }

        # Quit
        {
          mode = "n";
          key = "<leader>q";
          action = ":q<CR>";
        }

        # Navigate splits
        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w>h";
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w>j";
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w>k";
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w>l";
        }
        {
          mode = "n";
          key = "<leader>t";
          action = ":14split | term<CR>";  # 14 lines tall
          options.silent = true;
        }
        {
          mode = "i";
          key = "<C-;>";
          action = "->";
        }
        {
          mode = "t";
          key = "<C-Space>";
          action = "<C-\\><C-n>";
        }
      ];
    };
  };
}
