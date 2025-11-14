local file_ignore_patterns = { 'node_modules' }
local cmd = "Telescope"
local keys = {
    {
        "grt",
        function()
            require("telescope.builtin").lsp_type_definitions()
        end,
        desc = "Telescope: LSP Type definitions",
    },
    {
        "gd",
        function()
            require("telescope.builtin").lsp_definitions()
        end,
        desc = "Telescope: LSP Definitions",
    },
    {
        "gi",
        function()
            require("telescope.builtin").lsp_implementations()
        end,
        desc = "Telescope: LSP Implementations",
    },
    {
        "grr",
        function()
            require("telescope.builtin").lsp_references()
        end,
        desc = "Telescope: LSP References",
    },
    {
        "<leader>fs",
        function()
            require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "Telescope: LSP Symbols",
    },
    {
        "<leader>ff",
        function()
            require("telescope.builtin").find_files()
        end,
        desc = "Telescope: Find files",
    },
    {
        "<leader>fr",
        function()
            require("telescope.builtin").oldfiles()
        end,
        desc = "Telescope: Old files",
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
        "<leader>fm",
        function()
            require("telescope.builtin").man_pages({ sections = { "ALL" } })
        end,
        desc = "Telescope: Man pages",
    },
    {
        "<leader>d",
        function()
            require("telescope.builtin").diagnostics({ bufnr = 0 })
        end,
        desc = "Telescope: Diagnostics",
    },
    {
        "<leader>fc",
        function()
            require("telescope.builtin").git_commits({
                initial_mode = "normal",
            })
        end,
        desc = "Telescope: Git commits",
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
                        fuzzy = true,                   -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true,    -- override the file sorter
                        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                    },
                    live_grep = {
                        hidden = true,
                    },
                },
            })

            require("telescope").load_extension("fzf")
        end,
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },
}
