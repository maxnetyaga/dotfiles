return {
    {
        "rafi/awesome-vim-colorschemes",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme rubber]])
            vim.cmd([[highlight ColorColumn ctermbg=#2783f5 guibg=#2783f5]])
        end,
    },
    {
        "VonHeikemen/rubber-themes.vim",
        lazy = false,
        priority = 1000,
        -- config = function()
        --     vim.cmd([[colorscheme rubber]])
        -- end,
    },
}
