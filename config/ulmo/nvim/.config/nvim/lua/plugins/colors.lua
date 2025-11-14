return {
    -- {
    --     "VonHeikemen/rubber-themes.vim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         vim.cmd([[colorscheme rubber]])
    --     end,
    -- },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                on_highlights = function(hl, c)
                    hl.Comment = { fg = "#D92C54", italic = true }
                end,
            })
            vim.cmd([[colorscheme tokyonight-storm]])
        end,
    }
}
