return {
    {
        "lewis6991/gitsigns.nvim",
        lazy = false,
        keys = {

            {
                "<leader>gp",
                mode = "n",
                function()
                    require("gitsigns").preview_hunk()
                end,
                desc = "Preview git hunk",
            },
        },
    },
}
