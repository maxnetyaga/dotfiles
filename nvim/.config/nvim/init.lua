vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.lazy")

-------------------------------------------------------------------------------

require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier", stop_after_first = true },
        sh = { "beautysh" },
        zsh = { "beautysh" },
        sql = { "pg_format" },
    },
})

require("conform").formatters.pg_format = {
    args = { "-B" },
}

require("conform").formatters.stylua = {
    append_args = { "--indent-type", "Spaces" },
}

vim.keymap.set({ "n", "v" }, "<leader>fr", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file or range" })

--- LSP -----------------------------------------------------------------------

vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "gr", vim.lsp.buf.references)

vim.keymap.set("i", "<C-h>", "<C-x><C-o>")

vim.diagnostic.config({
        virtual_text = true,
        signs = false,
        underline = true,
        update_in_insert = true,
})

vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.keymap.set("n", "<leader>dn", function()
        vim.diagnostic.jump({ severity = { min = 4, max = 1 }, count = 1 })
end, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>dp", function()
        vim.diagnostic.jump({ severity = { min = 4, max = 1 }, count = -1 })
end, { desc = "Go to prev diagnostic" })


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
                },
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

vim.lsp.enable("bashls")
vim.lsp.enable("basedpyright")

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

-------------------------------------------------------------------------------

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>c", builtin.commands, { desc = "Commands" })

-------------------------------------------------------------------------------

-- local function my_on_attach(bufnr)
--     local api = require("nvim-tree.api")
--
--     local function opts(desc)
--         return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
--     end
--
--     -- default mappings
--     api.config.mappings.default_on_attach(bufnr)
--
--     -- custom mappings
--     vim.keymap.set("n", "<leader>e", api.node.open.tab, opts("Up"))
--     vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
-- end

require("nvim-tree").setup({
    on_attach = my_on_attach,
    sort = {
        sorter = "case_sensitive",
    },
    view = {
        side = "right",
        width = 30,
    },
    renderer = {
        group_empty = true,
    },
    -- filters = {
    --   dotfiles = true,
    -- },
})

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-------------------------------------------------------------------------------

vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
        ["+"] = "/mnt/c/Windows/System32/clip.exe",
        ["*"] = "/mnt/c/Windows/System32/clip.exe",
    },
    paste = {
        ["+"] = "",
        ["*"] = "",
    },
    cache_enabled = 0,
}

--- Git -----------------------------------------------------------------------

vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { noremap = true, silent = true })

--- SMTH ---------------------------------------------------------------

vim.cmd([[colorscheme rubber]])
vim.cmd([[set termguicolors]])

vim.cmd([[set number]])
vim.cmd([[set relativenumber]])

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
