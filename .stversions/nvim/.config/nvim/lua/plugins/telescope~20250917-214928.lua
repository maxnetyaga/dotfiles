local cmd = "Telescope"
local keys = {
    {
        "<leader>ff",
        function()
            require("telescope.builtin").find_files()
        end,
        desc = "Telescope: Find files",
    },
    {
        "<leader>fg",
        function()
            require("telescope.builtin").live_grep()
        end,
        desc = "Telescope: Live grep",
    },
    {
        "<leader>fb",
        function()
            require("telescope.builtin").buffers()
        end,
        desc = "Telescope: Buffers",
    },
    {
        "<leader>fh",
        function()
            require("telescope.builtin").help_tags()
        end,
        desc = "Telescope: Help tags",
    },
    {
        "<leader>fs",
        function()
            require("telescope.builtin").lsp_workspace_symbols()
        end,
        desc = "Telescope: Symbols",
    },
    {
        "<leader>fc",
        function()
            require("telescope.builtin").git_commits()
        end,
        desc = "Tlescope: Git commits",
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
