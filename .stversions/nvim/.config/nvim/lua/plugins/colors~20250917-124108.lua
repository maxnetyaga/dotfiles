return {
    {
        "rafi/awesome-vim-colorschemes",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme rubber]])
            vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#90bdff" })
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
