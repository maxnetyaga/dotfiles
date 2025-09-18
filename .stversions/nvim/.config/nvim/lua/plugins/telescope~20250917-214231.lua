local cmd = "Telescope"
local keys = {
    {
        "<leader>ff",
        function()
            require("telescope.builtin").find_files()
        end,
        desc = "Find files",
    },
    {
        "<leader>fg",
        function()
            require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
    },
    {
        "<leader>fb",
        function()
            require("telescope.builtin").buffers()
        end,
        desc = "Buffers",
    },
    {
        "<leader>fh",
        function()
            require("telescope.builtin").help_tags()
        end,
        desc = "Help tags",
    },
    {
        "<leader>fs",
        function()
            require("telescope.builtin").treesitter()
        end,
        desc = "Help tags",
    },
    {
        "<leader>fc",
        function()
            require("telescope.builtin").git_commits()
        end,
        desc = "Help tags",
    },
}

return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
        },
        lazy = true,
        cmd = cmd,
        keys = keys,
        config = function()
            require("telescope").setup({
                extensions = {
                    fzf = {
                        fuzzy = true, -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true, -- override the file sorter
                        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    },
                },
            })

            require("telescope").load_extension("fzf")
        end,
    },
}
