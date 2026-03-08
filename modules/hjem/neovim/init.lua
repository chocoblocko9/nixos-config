-- Stolen straight from nixvim, will eventually get overhauled probably but it needs to work

-- Set up globals {{{
do
    local nixvim_globals = { mapleader = " " }

    for k, v in pairs(nixvim_globals) do
        vim.g[k] = v
    end
end
-- }}}

-- Set up options {{{
do
    local nixvim_options = {
        backup = false,
        expandtab = true,
        number = true,
        relativenumber = true,
        scrolloff = 12,
        shiftwidth = 2,
        signcolumn = "yes",
        smartindent = true,
        swapfile = false,
        tabstop = 2,
        termguicolors = true,
        wrap = false,
    }

    for k, v in pairs(nixvim_options) do
        vim.opt[k] = v
    end
end
-- }}}

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

require("nvim-web-devicons").setup({})

local cmp = require("cmp")
cmp.setup({
    mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
    },
    sources = { { name = "nvim_lsp" }, { name = "path" }, { name = "buffer" } },
})

-- Create autogroup for treesitter autocmds
local augroup = vim.api.nvim_create_augroup("nixvim_treesitter", { clear = true })

-- Detect nvim-treesitter API
local has_configs_module = pcall(require, "nvim-treesitter.configs")

if has_configs_module then
    require("nvim-treesitter.configs").setup({ highlight = { enable = true }, indent = { enable = true } })
else
    require("nvim-treesitter").setup({ highlight = { enable = true }, indent = { enable = true } })

    -- Enable features via autocommands for modern nvim-treesitter
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "*",
        callback = function()
            pcall(vim.treesitter.start)
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end

require("telescope").setup({})

local __telescopeExtensions = {}
for i, extension in ipairs(__telescopeExtensions) do
    require("telescope").load_extension(extension)
end

local function open_nvim_tree(data)
    ------------------------------------------------------------------------------------------

    -- buffer is a directory
    local directory = vim.fn.isdirectory(data.file) == 1

    -- buffer is a [No Name]
    local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

    -- Will automatically open the tree when running setup if startup buffer is a directory,
    -- is empty or is unnamed. nvim-tree window will be focused.
    local open_on_setup = true

    if (directory or no_name) and open_on_setup then
        -- change to the directory
        if directory then
            vim.cmd.cd(data.file)
        end

        -- open the tree
        require("nvim-tree.api").tree.open()
        return
    end

    ------------------------------------------------------------------------------------------

    -- Will automatically open the tree when running setup if startup buffer is a file.
    -- File window will be focused.
    -- File will be found if updateFocusedFile is enabled.
    local open_on_setup_file = false

    -- buffer is a real file on the disk
    local real_file = vim.fn.filereadable(data.file) == 1

    if (real_file or no_name) and open_on_setup_file then
        -- skip ignored filetypes
        local filetype = vim.bo[data.buf].ft
        local ignored_filetypes = {}

        if not vim.tbl_contains(ignored_filetypes, filetype) then
            -- open the tree but don't focus it
            require("nvim-tree.api").tree.toggle({ focus = false })
            return
        end
    end

    ------------------------------------------------------------------------------------------

    -- Will ignore the buffer, when deciding to open the tree on setup.
    local ignore_buffer_on_setup = false
    if ignore_buffer_on_setup then
        require("nvim-tree.api").tree.open()
    end
end

require("nvim-tree").setup({})

require("lualine").setup({})

require("gitsigns").setup({
    current_line_blame = true,
    signs = {
        add = { text = "+" },
        change = { text = "~" },
        changedelete = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
    },
})

-- Set up keybinds {{{
do
    local __nixvim_binds = {
        { action = "<cmd>Telescope buffers<cr>", key = "<leader>fb", mode = "n" },
        { action = "<cmd>Telescope find_files<cr>", key = "<leader>ff", mode = "n" },
        { action = "<cmd>Telescope live_grep<cr>", key = "<leader>fg", mode = "n" },
        { action = "<cmd>Telescope help_tags<cr>", key = "<leader>fh", mode = "n" },
        { action = ":NvimTreeToggle<CR>", key = "<leader>e", mode = "n", options = { silent = true } },
        { action = ":w<CR>", key = "<leader>w", mode = "n" },
        { action = ":q<CR>", key = "<leader>q", mode = "n" },
        { action = "<C-w>h", key = "<C-h>", mode = "n" },
        { action = "<C-w>j", key = "<C-j>", mode = "n" },
        { action = "<C-w>k", key = "<C-k>", mode = "n" },
        { action = "<C-w>l", key = "<C-l>", mode = "n" },
        { action = ":14split | term<CR>", key = "<leader>t", mode = "n", options = { silent = true } },
        { action = "->", key = "<C-;>", mode = "i" },
        { action = "<C-\\><C-n>", key = "<C-Space>", mode = "t" },
    }
    for i, map in ipairs(__nixvim_binds) do
        vim.keymap.set(map.mode, map.key, map.action, map.options)
    end
end
-- }}}

-- LSP {{{
do
    local __lspCapabilities = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()

        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        return capabilities
    end

    local __setup = { capabilities = __lspCapabilities() }

    local __wrapConfig = function(cfg)
        if cfg == nil then
            cfg = __setup
        else
            cfg = vim.tbl_extend("keep", cfg, __setup)
        end
        return cfg
    end

    vim.lsp.config("hls", __wrapConfig({}))
    vim.lsp.enable("hls")
    vim.lsp.config("nixd", __wrapConfig({}))
    vim.lsp.enable("nixd")
end
-- }}}

-- Set up autogroups {{
do
    local __nixvim_autogroups = { nixvim_binds_LspAttach = { clear = true }, nixvim_lsp_on_attach = { clear = false } }

    for group_name, options in pairs(__nixvim_autogroups) do
        vim.api.nvim_create_augroup(group_name, options)
    end
end
-- }}
-- Set up autocommands {{
do
    local __nixvim_autocommands = {
        { callback = open_nvim_tree, event = "VimEnter" },
        {
            callback = function(event)
                do
                    -- client and bufnr are supplied to the builtin `on_attach` callback,
                    -- so make them available in scope for our global `onAttach` impl
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    local bufnr = event.buf
                end
            end,
            desc = "Run LSP onAttach",
            event = "LspAttach",
            group = "nixvim_lsp_on_attach",
        },
        {
            callback = function(args)
                do
                    local __nixvim_binds = {
                        {
                            action = vim.diagnostic.goto_next,
                            key = "<leader>j",
                            mode = "n",
                            options = { desc = "Lsp diagnostic goto_next", silent = false },
                        },
                        {
                            action = vim.diagnostic.goto_prev,
                            key = "<leader>k",
                            mode = "n",
                            options = { desc = "Lsp diagnostic goto_prev", silent = false },
                        },
                        {
                            action = vim.lsp.buf.code_action,
                            key = "<leader>ca",
                            mode = "n",
                            options = { desc = "Lsp buf code_action", silent = false },
                        },
                        {
                            action = vim.lsp.buf.rename,
                            key = "<leader>rn",
                            mode = "n",
                            options = { desc = "Lsp buf rename", silent = false },
                        },
                        {
                            action = vim.lsp.buf.hover,
                            key = "K",
                            mode = "n",
                            options = { desc = "Lsp buf hover", silent = false },
                        },
                        {
                            action = vim.lsp.buf.declaration,
                            key = "gD",
                            mode = "n",
                            options = { desc = "Lsp buf declaration", silent = false },
                        },
                        {
                            action = vim.lsp.buf.definition,
                            key = "gd",
                            mode = "n",
                            options = { desc = "Lsp buf definition", silent = false },
                        },
                        {
                            action = vim.lsp.buf.implementation,
                            key = "gi",
                            mode = "n",
                            options = { desc = "Lsp buf implementation", silent = false },
                        },
                        {
                            action = vim.lsp.buf.references,
                            key = "gr",
                            mode = "n",
                            options = { desc = "Lsp buf references", silent = false },
                        },
                    }

                    for i, map in ipairs(__nixvim_binds) do
                        local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
                        vim.keymap.set(map.mode, map.key, map.action, options)
                    end
                end
            end,
            desc = "Load keymaps for LspAttach",
            event = "LspAttach",
            group = "nixvim_binds_LspAttach",
        },
    }

    for _, autocmd in ipairs(__nixvim_autocommands) do
        vim.api.nvim_create_autocmd(autocmd.event, {
            group = autocmd.group,
            pattern = autocmd.pattern,
            buffer = autocmd.buffer,
            desc = autocmd.desc,
            callback = autocmd.callback,
            command = autocmd.command,
            once = autocmd.once,
            nested = autocmd.nested,
        })
    end
end
-- }}
