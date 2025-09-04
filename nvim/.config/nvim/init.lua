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
	},
})

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
})

--------------------------------------------------------------------------------

vim.cmd([[colorscheme rubber]])
vim.cmd([[set termguicolors]])

vim.cmd([[set number]])
vim.cmd([[set relativenumber]])
