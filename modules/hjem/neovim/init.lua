-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key
vim.g.mapleader = " "

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.scrolloff = 12
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false

-- Setup plugins
require("lazy").setup({
  -- Colorscheme
  {
    "nvim-mini/mini.nvim",
    config = function()
      require("mini.base16").setup({
        palette = {
          base00 = "#001e26",
          base01 = "#073642",
          base02 = "#586e75",
          base03 = "#657b83",
          base04 = "#839496",
          base05 = "#cac6b8",
          base06 = "#eee8d5",
          base07 = "#fdf6e3",
          base08 = "#dc322f",
          base09 = "#ff5c00",
          base0A = "#cecb00",
          base0B = "#19cb00",
          base0C = "#0dcdcd",
          base0D = "#0d73cc",
          base0E = "#cb1ed1",
          base0F = "#7579bd",
        },
      })
    end,
  },

  -- Icons
  "nvim-tree/nvim-web-devicons",

  -- LSP
  {
  "neovim/nvim-lspconfig",
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Configure servers
    vim.lsp.config.nixd = {
      cmd = { "nixd" },
      filetypes = { "nix" },
      root_markers = { ".git" },
      capabilities = capabilities,
    }

    vim.lsp.config.hls = {
      cmd = { "haskell-language-server", "--lsp" },
      filetypes = { "haskell", "lhaskell" },
      root_markers = { ".git", "cabal.project", "stack.yaml" },
      capabilities = capabilities,
    }

    -- Enable servers
    vim.lsp.enable("nixd")
    vim.lsp.enable("hls")

    -- Keybindings on attach
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local opts = { buffer = args.buf }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>j", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>k", vim.diagnostic.goto_prev, opts)
      end,
    })
  end,
},

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- Treesitter
  {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {},
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath('data') .. '/site',
      highlight = { enable = true },
      indent = { enable = true }, 
      ensure_installed = { -- This lowkey does nothing but like it's a reference of what to :TSInstall
        "nix",
        "lua", 
        "haskell",
        "markdown",
        "bash",
        "rust",
        "python",
      },
      auto_install = true,
      sync_install = false,
    })
  end,
},

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- File tree
  "nvim-tree/nvim-tree.lua",

  -- idk what this does but it's good probably
  "LnL7/vim-nix",

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup()
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      })
    end,
  },
})

-- Keybindings
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<leader>t", ":12split | term<CR>", { silent = true })
vim.keymap.set("i", "<C-;>", "->")
vim.keymap.set("t", "<C-Space>", "<C-\\><C-n>")

-- Treesitter won't auto highlight grrrr
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- NvimTree setup
require("nvim-tree").setup()
