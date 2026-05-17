return {
    {
        "FeiyouG/commander.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        keys = {
            { "<leader>c", "<CMD>Telescope commander<CR>", mode = "n", desc = "Open commander" },
        },
        opts = {

            components = {
                "DESC",
                "KEYS",
                "CAT",
            },
            sort_by = {
                "DESC",
                "KEYS",
                "CAT",
                "CMD",
            },
            integration = {
                telescope = {
                    enable = true,
                },
                lazy = {
                    enable = true,
                    set_plugin_name_as_cat = true,
                },
            },
        },
    },
}
