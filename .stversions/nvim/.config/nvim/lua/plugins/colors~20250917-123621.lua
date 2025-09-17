return {
    {
        "rafi/awesome-vim-colorschemes",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme rubber]])
            vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2783f5" })
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
