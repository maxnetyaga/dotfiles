return {
    {
        "rafi/awesome-vim-colorschemes",
        lazy = false,
        priority = 1000,
    },
    {
        "VonHeikemen/rubber-themes.vim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme rubber]])
        end,
    },
}
