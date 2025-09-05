return {
	{ "stevearc/conform.nvim" },
	{ "nvim-treesitter/nvim-treesitter" },
	{ "neovim/nvim-lspconfig" },
	{ "rafi/awesome-vim-colorschemes" },
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	----------------------------------------------------------------------------

	{ "VonHeikemen/rubber-themes.vim" },
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
	},
}
