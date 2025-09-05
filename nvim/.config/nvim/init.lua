-- Set <Space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.lazy")

--------------------------------------------------------------------------------

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

vim.keymap.set({ "n", "v" }, "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file or range" })

--- LSP -------------------------------------------------------------------------

vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })

vim.lsp.enable("luals")
vim.lsp.enable("bashls")
vim.lsp.enable("basedpyright")

--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------

vim.cmd([[colorscheme rubber]])
vim.cmd([[set termguicolors]])

vim.cmd([[set number]])
vim.cmd([[set relativenumber]])

vim.opt.list = true

vim.opt.listchars = {
    tab = "» ",
    trail = "·",
    extends = "…",
    precedes = "…",
}

-- local modes = { 'i', 'v', 's', 'o' }
-- local keys = { 'jk', 'kj' }
--
-- for _, mode in ipairs(modes) do
--   for _, key in ipairs(keys) do
--     vim.api.nvim_set_keymap(mode, key, '<Esc>', { noremap = true, silent = true })
--   end
-- end
