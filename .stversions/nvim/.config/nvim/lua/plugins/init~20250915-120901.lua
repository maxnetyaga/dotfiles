return {
    { "stevearc/conform.nvim" },

    ---------------------------------------------------------------------------

    { "nvim-treesitter/nvim-treesitter" },
    -- { "nvim-treesitter/nvim-treesitter-context" },

    ---------------------------------------------------------------------------

    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            { "tpope/vim-dadbod", lazy = true },
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        init = function()
            -- Your DBUI configuration
            vim.g.db_ui_use_nerd_fonts = 1
        end,
    },

    ---------------------------------------------------------------------------

    { "neovim/nvim-lspconfig" },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
    },
    { "hrsh7th/vim-vsnip" },

    -- {
    --     "saghen/blink.cmp",
    --     opts = {
    --         keymap = {
    --             preset = "enter",
    --             -- ["<C-h>"] = { "show", "show_documentation", "hide_documentation" },
    --         },
    --         sources = {
    --             default = { "lsp", "dadbod", "path", "snippets", "buffer" },
    --             per_filetype = {
    --                 sql = { "snippets", "dadbod", "lsp", "path", "buffer" },
    --             },
    --             providers = {
    --                 dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
    --             },
    --         },
    --     },
    -- },

    ---------------------------------------------------------------------------

    {
        "mfussenegger/nvim-lint",
        opts = {
            -- Event to trigger linters
            events = { "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged", "TextChangedI" },
            linters_by_ft = {
                fish = { "fish" },

                -- Add eslint for JavaScript
                javascript = { "eslint" },
                javascriptreact = { "eslint" }, -- if you use JSX/React
                typescript = { "eslint" }, -- if you want TS handled by eslint
                typescriptreact = { "eslint" }, -- for TSX/React

                -- Use the "*" filetype to run linters on all filetypes.
                -- ['*'] = { 'global linter' },
                -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
                -- ['_'] = { 'fallback linter' },
                -- ["*"] = { "typos" },
            },
            -- LazyVim extension to easily override linter options
            -- or add custom linters.
            ---@type table<string,table>
            linters = {
                -- -- Example: eslint only when config file is present
                -- eslint = {
                --     condition = function(ctx)
                --         return vim.fs.find(
                --             { ".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.cjs" },
                --             { path = ctx.filename, upward = true }
                --         )[1]
                --     end,
                -- },
            },
        },
        config = function(_, opts)
            local M = {}

            local lint = require("lint")
            for name, linter in pairs(opts.linters) do
                if type(linter) == "table" and type(lint.linters[name]) == "table" then
                    lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
                    if type(linter.prepend_args) == "table" then
                        lint.linters[name].args = lint.linters[name].args or {}
                        vim.list_extend(lint.linters[name].args, linter.prepend_args)
                    end
                else
                    lint.linters[name] = linter
                end
            end
            lint.linters_by_ft = opts.linters_by_ft

            function M.debounce(ms, fn)
                local timer = vim.uv.new_timer()
                return function(...)
                    local argv = { ... }
                    timer:start(ms, 0, function()
                        timer:stop()
                        vim.schedule_wrap(fn)(unpack(argv))
                    end)
                end
            end

            function M.lint()
                -- Use nvim-lint's logic first:
                -- * checks if linters exist for the full filetype first
                -- * otherwise will split filetype by "." and add all those linters
                -- * this differs from conform.nvim which only uses the first filetype that has a formatter
                local names = lint._resolve_linter_by_ft(vim.bo.filetype)

                -- Create a copy of the names table to avoid modifying the original.
                names = vim.list_extend({}, names)

                -- Add fallback linters.
                if #names == 0 then
                    vim.list_extend(names, lint.linters_by_ft["_"] or {})
                end

                -- Add global linters.
                vim.list_extend(names, lint.linters_by_ft["*"] or {})

                -- Filter out linters that don't exist or don't match the condition.
                local ctx = { filename = vim.api.nvim_buf_get_name(0) }
                ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
                names = vim.tbl_filter(function(name)
                    local linter = lint.linters[name]
                    -- if not linter then
                    --     LazyVim.warn("Linter not found: " .. name, { title = "nvim-lint" })
                    -- end
                    return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
                end, names)

                -- Run linters.
                if #names > 0 then
                    lint.try_lint(names)
                end
            end

            vim.api.nvim_create_autocmd(opts.events, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = M.debounce(100, M.lint),
            })
        end,
    },

    ---------------------------------------------------------------------------

    { "nvim-mini/mini.pairs", version = "*" },
    -- { "nvim-mini/mini.surround", version = "*" },

    --- File Management -------------------------------------------------------

    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
        "stevearc/oil.nvim",
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {},
        -- Optional dependencies
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
        -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
    },

    --- Buffer Management -----------------------------------------------------

    -- {
    --     "axkirillov/hbac.nvim",
    --     config = true,
    -- },

    --- Project File Actions --------------------------------------------------

    {
        "MagicDuck/grug-far.nvim",
        -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
        -- additional lazy config to defer loading is not really needed...
        config = function()
            -- optional setup call to override plugin options
            -- alternatively you can set options with vim.g.grug_far = { ... }
            require("grug-far").setup({
                keymaps = {
                    -- Normal mode
                    close = "q", -- close window
                    replace = "<leader>r", -- start replace
                    replace_all = "<leader>R", -- replace all
                    preview = "gp", -- preview changes
                    -- Insert mode
                    edit_pattern = "<C-p>", -- edit pattern
                    edit_replacement = "<C-r>", -- edit replacement
                },
            })
        end,
        cmd = "GrugFar",
        keys = {
            {
                "<leader>r",
                function()
                    local grug = require("grug-far")
                    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                    grug.open({
                        transient = true,
                        prefills = {},
                    })
                end,
                mode = { "n", "v" },
                desc = "Search & Replace",
            },
        },
    },

    --- Git -------------------------------------------------------------------

    { "lewis6991/gitsigns.nvim" },
    -- {
    --     "benomahony/oil-git.nvim",
    --     dependencies = { "stevearc/oil.nvim" },
    -- },

    --- Navigation ------------------------------------------------------------

    { "mg979/vim-visual-multi" },
    { "ggandor/leap.nvim" },

    ---------------------------------------------------------------------------

    -- {
    --     "AckslD/nvim-neoclip.lua",
    --     dependencies = {
    --         { "nvim-telescope/telescope.nvim" },
    --     },
    --     config = function()
    --         require("neoclip").setup()
    --     end,
    -- },

    ---------------------------------------------------------------------------

    { "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" } },

    ---------------------------------------------------------------------------

    {
        "FeiyouG/commander.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
    },

    ---------------------------------------------------------------------------

    {
        "folke/which-key.nvim",
        event = "VeryLazy",

        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },

    ---------------------------------------------------------------------------

    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,

        opts = {
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            bufdelete = { enabled = true },
            indent = { enabled = true },
            input = { enabled = true },
            picker = { enabled = true },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            scope = { enabled = true },
            scroll = { enabled = false },
            statuscolumn = { enabled = true },
            words = { enabled = true },
            colorschemes = {
                enabled = true,
                win_options = {
                    winblend = 0,
                },
            },
        },
        keys = {
            {
                "<leader>C",
                function()
                    Snacks.picker.colorschemes()
                end,
                desc = "Colorsheme Picker",
            },
            {
                "<leader>fp",
                function()
                    Snacks.picker.projects()
                end,
                desc = "Projects",
            },
            {
                "<leader>fr",
                function()
                    Snacks.picker.recent()
                end,
                desc = "Recent Files",
            },
            {
                "<leader>.",
                function()
                    Snacks.scratch()
                end,
                desc = "Toggle Scratch Buffer",
            },
            {
                "<leader>S",
                function()
                    Snacks.scratch.select()
                end,
                desc = "Select Scratch Buffer",
            },
            {
                "<leader>m",
                function()
                    Snacks.notifier.show_history()
                end,
                desc = "Notification History",
            },
            {
                "<C-c>",
                function()
                    Snacks.bufdelete()
                end,
                desc = "Delete Buffer",
            },
            -- {
            --     "<leader>gB",
            --     function()
            --         Snacks.gitbrowse()
            --     end,
            --     desc = "Git Browse",
            --     mode = { "n", "v" },
            -- },
            -- {
            --     "<leader>gg",
            --     function()
            --         Snacks.lazygit()
            --     end,
            --     desc = "Lazygit",
            -- },
            {
                "<leader>un",
                function()
                    Snacks.notifier.hide()
                end,
                desc = "Dismiss All Notifications",
            },
            {
                "<leader>,",
                "<cmd>:Lspsaga term_toggle<cr>",
                desc = "Toggle Terminal",
            },
        },
    },

    ---------------------------------------------------------------------------

    {
        "chrisgrieser/nvim-recorder",
        dependencies = "rcarriga/nvim-notify", -- optional
        opts = {}, -- required even with default settings, since it calls `setup()`
    },

    ---------------------------------------------------------------------------

    { "dstein64/nvim-scrollview" },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "nvimdev/lspsaga.nvim",
        config = function()
            require("lspsaga").setup({
                definition = {
                    keys = {
                        edit = "<C-s>o",
                        vsplit = "<C-s>v",
                        split = "<C-s>i",
                        tabe = "<C-s>t",
                        close = "<C-s>",
                    },
                },
                symbol_in_winbar = { enable = false },
                lightbulb = { enable = false },
                finder = {
                    methods = {
                        tyd = "textDocument/typeDefinition",
                    },
                },
            })
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter", -- optional
            "nvim-tree/nvim-web-devicons", -- optional
        },
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {},
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
        extensions = { "neo-tree", "lazy", "fzf" },
    },
    { "rafi/awesome-vim-colorschemes" },
    { "VonHeikemen/rubber-themes.vim" },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    { "rebelot/kanagawa.nvim" },
    { "nvim-mini/mini.icons", version = "*" },
    -- { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" },
}
