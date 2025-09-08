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

vim.lsp.enable("luals")
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

-------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { noremap = true, silent = true })

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
