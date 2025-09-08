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
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    { "nvim-tree/nvim-tree.lua" },
    { "lewis6991/gitsigns.nvim" },

    ----------------------------------------------------------------------------

    { "VonHeikemen/rubber-themes.vim" },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
    },
}
