vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.lazy")

--- Formatting ----------------------------------------------------------------

require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = {
            -- To fix auto-fixable lint errors.
            "ruff_fix",
            -- To run the Ruff formatter.
            "ruff_format",
            -- To organize the imports.
            "ruff_organize_imports",
        },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        sh = { "beautysh" },
        zsh = { "beautysh" },
        sql = { "sql_formatter" },
    },

    default_format_opts = {
        lsp_format = "fallback",
    },
})

require("conform").formatters.stylua = {
    append_args = { "--indent-type", "Spaces" },
}

--- LSP & Autocompletion ------------------------------------------------------

local cmp = require("cmp")

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

            -- For `mini.snippets` users:
            -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
            -- insert({ body = args.body }) -- Insert at cursor
            -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
            -- require("cmp.config").set_onetime({ sources = {} })
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        {
            name = "path",
            option = {
                -- pathMappings = {
                --     ["@"] = "${folder}/src",
                --     -- ['/'] = '${folder}/src/public/',
                --     -- ['~@'] = '${folder}/src',
                --     -- ['/images'] = '${folder}/src/images',
                --     -- ['/components'] = '${folder}/src/components',
                -- },
            },
        },
        { name = "vsnip" }, -- For vsnip users.
    }, {
        { name = "buffer" },
    }),
})

cmp.setup.filetype({ "sql" }, {
    sources = {
        { name = "vim-dadbod-completion" },
        { name = "buffer" },
    },
})
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = sql_ft,
--     callback = function()
--         local cmp = require("cmp")
--
--         -- global sources
--         ---@param source cmp.SourceConfig
--         local sources = vim.tbl_map(function(source)
--             return { name = source.name }
--         end, cmp.get_config().sources)
--
--         -- add vim-dadbod-completion source
--         table.insert(sources, { name = "vim-dadbod-completion" })
--
--         -- update sources for the current buffer
--         cmp.setup.buffer({ sources = sources })
--     end,
-- })

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = true,
    float = {
        source = true,
    },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Enable dynamic registration for watched files
capabilities.workspace.didChangeWatchedFiles = {
    dynamicRegistration = true,
}

-- Do nothing if hover fails
local vim_notify = vim.notify
vim.notify = function(msg, level, opts)
    if mgs == "No information available" then
        return
    end

    return vim_notify(msg, level, opts)
    -- Or with `rcarriga/nvim-notify`
    -- return require('notify').notify(msg, level, opts)
end

--- Lua ---

vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath("config")
                and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
            then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using (most

                -- likely LuaJIT in the case of Neovim)

                version = "LuaJIT",
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                    vim.split(package.path, ";"),
                },
            },
            diagnostics = {
                globals = { "vim" }, -- so 'vim' is recognized
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {

                    vim.env.VIMRUNTIME,
                    -- Depending on the usage, you might want to add additional paths

                    -- here.
                    -- '${3rd}/luv/library'
                    -- '${3rd}/busted/library'
                },
                -- Or pull in all of 'runtimepath'.
                -- NOTE: this is a lot slower and will cause issues when working on
                -- your own configuration.
                -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                -- library = {
                --   vim.api.nvim_get_runtime_file('', true),
                -- }
            },
        })
    end,

    settings = {
        Lua = {},
    },
})

--- Shell ---

vim.lsp.enable("bashls")

--- Python ---

require("lspconfig").basedpyright.setup({
    capabilities = capabilities,
    settings = {
        basedpyright = {
            analysis = {
                disableOrganizeImports = true,
                typeCheckingMode = "basic",
            },
        },
        python = {
            analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { "*" },
            },
        },
    },
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
            return
        end
        if client.name == "ruff" then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
        end
    end,
    desc = "LSP: Disable hover capability from Ruff",
})

vim.lsp.config("ruff", {
    init_options = {
        settings = {
            configuration = vim.fn.expand("~/.config/ruff/ruff.toml"),
        },
    },
})

vim.lsp.enable("ruff")

--- Web ---

vim.lsp.enable("ts_ls")
vim.lsp.enable("css_variables")
vim.lsp.enable("cssls")
vim.lsp.enable("cssmodules_ls")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("eslint")

--- SQL ---

-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = {"sql", "mysql", "plsql"},
--     callback = function()
--         cmp.setup.buffer {
--             sources = {
--                 { name = 'vim-dadbod-completion' }
--             }
--         }
--     end,
-- })

-------------------------------------------------------------------------------

require("nvim-treesitter.configs").setup({
    highlight = {
        enable = true,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
})

--- File Management -----------------------------------------------------------

-- require("telescope").load_extension("neoclip")
require("telescope").setup({
    pickers = {
        buffers = {
            mappings = {
                i = {
                    ["<C-d>"] = require("telescope.actions").delete_buffer,
                },
                n = {
                    ["dd"] = require("telescope.actions").delete_buffer,
                },
            },
        },
    },
    defaults = {
        vimgrep_arguments = {
            "grep",
            "--line-number",
            "--column",
            "--no-color",
        },
    },
})

require("oil").setup({
    float = {
        padding = 2,
        max_width = 80,
        max_height = 20,
        border = "single", -- "single", "double", "rounded", "solid", "shadow"
        win_options = {
            winblend = 0,
        },
    },
    delete_to_trash = true,
    watch_for_changes = true,
    view_options = {
        show_hidden = true,
    },
    keymaps = {
        ["q"] = "actions.close",
        ["<ESC><ESC>"] = "actions.close",
    },
})

--- Buffer Management ---------------------------------------------------------

-- require("hbac").setup({
--     autoclose = true, -- set autoclose to false if you want to close manually
--     threshold = 1, -- hbac will start closing unedited buffers once that number is reached
--     close_command = function(bufnr)
--         vim.api.nvim_buf_delete(bufnr, {})
--     end,
--     close_buffers_with_windows = false, -- hbac will close buffers with associated windows if this option is `true`
--     telescope = {
--         -- See #telescope-configuration below
--     },
-- })

--- Better Folds --------------------------------------------------------------

vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}
local language_servers = vim.lsp.get_clients() -- or list servers manually like {'gopls', 'clangd'}
for _, ls in ipairs(language_servers) do
    require("lspconfig")[ls].setup({
        capabilities = capabilities,
        -- you can add other fields for setting up lsp server in this table
    })
end
-- require("ufo").setup()

--- Command Palette -----------------------------------------------------------

require("commander").setup({
    components = {
        "DESC",
        "KEYS",
        "CAT",
    },
    sort_by = {
        "DESC",
        "KEYS",
        "CAT",
        "CMD",
    },
    integration = {
        telescope = {
            enable = true,
        },
        lazy = {
            enable = true,
            set_plugin_name_as_cat = true,
        },
    },
})

require("commander").add({
    {
        desc = "Open commander",
        cmd = require("commander").show,
        keys = { "n", "<Leader>c" },
    },
})

require("commander").add({
    {
        desc = "Explorer",
        cmd = "<CMD>Oil --float<CR>",
        keys = { "n", "<Leader>e" },
    },
})

-- require("commander").add({
--     {
--         desc = "Close current buffer",
--         cmd = Snacks.,
--         keys = { "n", "<C-c>" },
--     },
-- })

require("commander").add({
    {
        keys = { { "n", "v" }, "<leader>db" },
        cmd = "<cmd>DBUI<cr>",
        desc = "DB: UI",
    },
})

--- Formatting
require("commander").add({
    {
        keys = { { "n", "v" }, "<leader>k" },
        cmd = function()
            require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format file or range",
    },
})

--- Git
require("commander").add({
    {
        keys = { "n", "<leader>gp" },
        cmd = ":Gitsigns preview_hunk<CR>",
        desc = "Preview changes (git)",
    },
})

--- LSP Navigation
require("commander").add({
    {
        keys = { "n", "<F2>" },
        cmd = "<CMD>Lspsaga rename<CR>",
        desc = "LSP: Rename",
    },
})
require("commander").add({
    {
        keys = { "n", "gd" },
        cmd = "<CMD>Lspsaga finder def<CR>",
        desc = "LSP: Go to Definition",
    },
})
require("commander").add({
    {
        keys = { "n", "gt" },
        cmd = "<CMD>Lspsaga finder tyd<CR>",
        desc = "LSP: Go to Type Definition",
    },
})
require("commander").add({
    {
        keys = { "n", "gD" },
        cmd = vim.lsp.buf.declaration,
        desc = "LSP: Go to Declaration",
    },
})
require("commander").add({
    {
        keys = { "n", "gi" },
        cmd = "<CMD>Lspsaga finder imp<CR>",
        desc = "LSP: Go to Implementation",
    },
})
require("commander").add({
    {
        keys = { "n", "gr" },
        cmd = "<CMD>Lspsaga finder ref<CR>",
        desc = "LSP: Go to References",
    },
})
require("commander").add({
    {
        desc = "LSP: Code Action",
        cmd = "<CMD>Lspsaga code_action<CR>",
        keys = { "n", "<Leader>a" },
    },
})
require("commander").add({
    {
        desc = "LSP: Hover",
        cmd = "<CMD>Lspsaga hover_doc<CR>",
        -- cmd = vim.lsp.buf.hover,
        keys = { "n", "K" },
    },
})

--- Diagnostic
require("commander").add({
    {
        keys = { "n", "<leader>dd" },
        cmd = vim.diagnostic.open_float,
        desc = "Diagnostic: Show message",
    },
})
-- require("commander").add({
--     {
--         keys = { "n", "<leader>dn" },
--         cmd = function ()
--             vim.diagnostic.jump({ severity = { min = 4, max = 1 }, count = 1 })
--         end,
--         desc = "Diagnostic: Next problem",
--     },
-- })
require("commander").add({
    {
        keys = { "n", "<leader>dn" },
        cmd = "<CMD>Lspsaga diagnostic_jump_next<CR>",
        desc = "Diagnostic: Next problem",
    },
})
-- require("commander").add({
--     {
--         keys = { "n", "<leader>dp" },
--         cmd = function ()
--             vim.diagnostic.jump({ severity = { min = 4, max = 1 }, count = -1 })
--         end,
--         desc = "Diagnostic: Previous problem",
--     },
-- })
require("commander").add({
    {
        keys = { "n", "<leader>dp" },
        cmd = "<CMD>Lspsaga diagnostic_jump_prev<CR>",
        desc = "Diagnostic: Previous problem",
    },
})
require("commander").add({
    {
        keys = { "n", "<leader>do" },
        cmd = "<cmd>Telescope diagnostics<cr>",
        desc = "Telescope: Diagnostic",
    },
})

---  Telescope
require("commander").add({
    {
        keys = { "n", "<leader>ff" },
        cmd = function()
            require("telescope.builtin").find_files({
                find_command = {
                    "fd",
                    "--type",
                    "f",
                    "--type",
                    "l",
                    "--type",
                    "d",
                    "--hidden",
                    "--no-ignore",
                    "--exclude",
                    ".git",
                    "--exclude",
                    "__pycache__",
                    "--exclude",
                    ".mypy_cache",
                    "--exclude",
                    ".venv",
                    "--exclude",
                    "node_modules",
                },
            })
        end,
        desc = "Telescope: Find",
    },
})
require("commander").add({
    {
        keys = { "n", "<C-p>" },
        cmd = function()
            require("telescope.builtin").find_files({
                find_command = {
                    "fd",
                    "--type",
                    "f",
                    "--type",
                    "l",
                    "--type",
                    "d",
                    "--hidden",
                    "--no-ignore",
                    "--exclude",
                    ".git",
                    "--exclude",
                    "__pycache__",
                    "--exclude",
                    ".mypy_cache",
                    "--exclude",
                    ".venv",
                    "--exclude",
                    "node_modules",
                },
            })
        end,
        desc = "Telescope: Find",
    },
})
require("commander").add({
    {
        keys = { "n", "<leader>fg" },
        cmd = require("telescope.builtin").live_grep,
        desc = "Telescope: Grep",
    },
})
require("commander").add({
    {
        keys = { "n", "<leader>fb" },
        cmd = require("telescope.builtin").buffers,
        desc = "Telescope: Buffers",
    },
})
require("commander").add({
    {
        keys = { "n", "<leader>fh" },
        cmd = require("telescope.builtin").help_tags,
        desc = "Telescope: Help",
    },
})
require("commander").add({
    {
        keys = { "n", "<leader>fc" },
        cmd = ":Telescope neoclip<cr>",
        desc = "Telescope: Clipboard history",
    },
})

-- ---  Folds
-- require("commander").add({
--     {
--         keys = { "n", "zR" },
--         cmd = require("ufo").openAllFolds,
--         desc = "Open all folds",
--     },
-- })
--
-- require("commander").add({
--     {
--         keys = { "n", "zM" },
--         cmd = require("ufo").closeAllFolds,
--         desc = "Close all folds",
--     },
-- })

--- SMTH ----------------------------------------------------------------------

vim.cmd([[colorscheme tokyonight]])
vim.cmd([[set termguicolors]])
vim.cmd([[set cursorline]])
vim.cmd([[
  hi NormalFloat guibg=NONE
  hi FloatBorder guibg=NONE
  hi Pmenu guibg=NONE
]])
require("notify").setup({
    background_colour = "#000000",
    timeout = 10000,
})

vim.cmd([[set number]])
vim.cmd([[set relativenumber]])

vim.cmd([[
    let g:clipboard = {
      \   'name': 'win32yank-wsl',
      \   'copy': {
      \      '+': 'win32yank.exe -i --crlf',
      \      '*': 'win32yank.exe -i --crlf',
      \    },
      \   'paste': {
      \      '+': 'win32yank.exe -o --lf',
      \      '*': 'win32yank.exe -o --lf',
      \   },
      \   'cache_enabled': 0,
      \ }
]])

vim.opt.list = true
vim.opt.colorcolumn = { 80 }

vim.opt.listchars = {
    tab = "→ ",
    trail = "·",
    extends = "…",
    precedes = "…",
}

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- SQL-specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "sql",
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

require("mini.pairs").setup()
local cursorline_bg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg
vim.api.nvim_set_hl(0, "MatchParen", { fg = "#D75F87", bg = cursorline_bg })

-- require("mini.surround").setup()
-- require("leap").set_default_mappings()
require("mini.icons").setup()
require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
            refresh_time = 16, -- ~60fps
            events = {
                "WinEnter",
                "BufEnter",
                "BufWritePost",
                "SessionLoadPost",
                "FileChangedShellPost",
                "VimResized",
                "Filetype",
                "CursorMoved",
                "CursorMovedI",
                "ModeChanged",
            },
        },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "line", "fileformat", "filetype", "lsp_status" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {},
})

-- local Popup = require("nui.popup")

-- local popup = Popup({
--     position = "50%",
--     size = {
--         width = 80,
--         height = 40,
--     },
--     enter = true,
--     focusable = true,
--     zindex = 50,
--     relative = "editor",
--     border = {
--         padding = {
--             top = 2,
--             bottom = 2,
--             left = 3,
--             right = 3,
--         },
--         style = "rounded",
--         text = {
--             top = " I am top title ",
--             top_align = "center",
--             bottom = "I am bottom title",
--             bottom_align = "left",
--         },
--     },
--     buf_options = {
--         modifiable = true,
--         readonly = false,
--     },
--     win_options = {
--         winblend = 10,
--         winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
--     },
-- })

-- require("noice").setup({
--     lsp = {
--         -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
--         override = {
--             ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
--             ["vim.lsp.util.stylize_markdown"] = true,
--             ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
--         },
--     },
--     -- you can enable a preset for easier configuration
--     presets = {
--         bottom_search = true, -- use a classic bottom cmdline for search
--         command_palette = true, -- position the cmdline and popupmenu together
--         long_message_to_split = true, -- long messages will be sent to a split
--         inc_rename = false, -- enables an input dialog for inc-rename.nvim
--         lsp_doc_border = false, -- add a border to hover docs and signature help
--     },
-- })

--- Autocentering ---

-- --- Center when inserting
-- vim.api.nvim_create_autocmd("InsertEnter", {
--     callback = function()
--         local debounce = 8
--         if vim.fn.abs(vim.fn.line(".") - math.floor(vim.fn.line("w0") + vim.fn.winheight(0) / 2)) >= debounce then
--             vim.cmd("norm! zz")
--         end
--     end,
-- })
--
-- -- Keep it centered while hitting <CR> if past debounce
-- vim.keymap.set("i", "<CR>", function()
--     local debounce = 8
--     if vim.fn.abs(vim.fn.line(".") - math.floor(vim.fn.line("w0") + vim.fn.winheight(0) / 2)) >= debounce then
--         return "<CR><cmd>norm! zz<CR>"
--     end
--     return "<CR>"
-- end, { expr = true })

vim.api.nvim_create_autocmd("Filetype", {
    pattern = "sql",
    callback = function()
        pcall(vim.keymap.del, "i", "<left>", { buffer = true })
        pcall(vim.keymap.del, "i", "<right>", { buffer = true })
    end,
})

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

--- Tabs ---

-- Leader + number to jump to tab
vim.keymap.set({"n", "x", "v", "i"}, "<leader>1", "1gt", { noremap = true, silent = true })
vim.keymap.set({"n", "x", "v", "i"}, "<leader>2", "2gt", { noremap = true, silent = true })
vim.keymap.set({"n", "x", "v", "i"}, "<leader>3", "3gt", { noremap = true, silent = true })
vim.keymap.set({"n", "x", "v", "i"}, "<leader>4", "4gt", { noremap = true, silent = true })
vim.keymap.set({"n", "x", "v", "i"}, "<leader>5", "5gt", { noremap = true, silent = true })
vim.keymap.set({"n", "x", "v", "i"}, "<leader>6", "6gt", { noremap = true, silent = true })
vim.keymap.set({"n", "x", "v", "i"}, "<leader>7", "7gt", { noremap = true, silent = true })
vim.keymap.set({"n", "x", "v", "i"}, "<leader>8", "8gt", { noremap = true, silent = true })
vim.keymap.set({"n", "x", "v", "i"}, "<leader>9", "9gt", { noremap = true, silent = true })
vim.keymap.set({"n", "x", "v", "i"}, "<leader>0", ":tablast<CR>", { noremap = true, silent = true })

-- Create 9 tabs on start
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        for i = 2, 9 do -- start from 2, because the first tab exists already
            vim.cmd("tabnew")
        end
        vim.cmd("tabn 1")
    end,
})

vim.opt.showtabline = 0

vim.keymap.set({ "n", "v", "i" }, "<C-s><C-s>", "<cmd>w<cr>", { noremap = true, silent = true })

--- Windows Management ---

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { noremap = true, silent = true })

-- Normal mode Alt + hjkl
vim.keymap.set("n", "<A-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<A-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<A-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<A-l>", "<C-w>l", { noremap = true })

-- Insert mode Alt + hjkl (go to normal first, then navigate)
vim.keymap.set("i", "<A-h>", "<C-\\><C-N><C-w>h", { noremap = true })
vim.keymap.set("i", "<A-j>", "<C-\\><C-N><C-w>j", { noremap = true })
vim.keymap.set("i", "<A-k>", "<C-\\><C-N><C-w>k", { noremap = true })
vim.keymap.set("i", "<A-l>", "<C-\\><C-N><C-w>l", { noremap = true })

-- Terminal mode Alt + hjkl (exit terminal mode, then navigate)
vim.keymap.set("t", "<A-h>", "<C-\\><C-N><C-w>h", { noremap = true })
vim.keymap.set("t", "<A-j>", "<C-\\><C-N><C-w>j", { noremap = true })
vim.keymap.set("t", "<A-k>", "<C-\\><C-N><C-w>k", { noremap = true })
vim.keymap.set("t", "<A-l>", "<C-\\><C-N><C-w>l", { noremap = true })
