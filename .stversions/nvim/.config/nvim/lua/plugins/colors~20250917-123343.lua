return {
    {
        "rafi/awesome-vim-colorschemes",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme rubber]])
            vim.cmd([[highlight ColorColumn ctermbg=red guibg=red]])
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
