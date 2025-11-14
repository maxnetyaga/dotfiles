return {
    {
        "stevearc/oil.nvim",
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            float = {
                padding = 2,
                max_width = 80,
                max_height = 20,
                border = "single",
                win_options = {
                    winblend = 0,
                },
            },
            columns = {
                "icon",
                "permissions",
                "size",
            },
            delete_to_trash = true,
            watch_for_changes = true,
            view_options = {
                show_hidden = true,
            },
            keymaps = {
                ["<ESC>"] = { "actions.close", mode = "n" },
                ["<leader>e"] = "actions.close",
            },
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
        keys = {
            {
                "<leader>e",
                mode = "n",
                "<cmd>Oil --float<cr>",
                desc = "Toggle explorer",
            },
        },
    },
}
