return {
    {
        "nvim-orgmode/orgmode",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-orgmode/telescope-orgmode.nvim",
            "nvim-orgmode/org-bullets.nvim",
            "Saghen/blink.cmp",
        },
        event = "VeryLazy",
        ft = { "org" },
        config = function()
            require("orgmode").setup({
                org_agenda_files = "~/Nextcloud/Files/orgfiles/**/*",
                org_default_notes_file = "~/Nextcloud/Files/orgfiles/refile.org",
                org_startup_folded = "showeverything",
            })
            -- require('org-bullets').setup()
            require("blink.cmp").setup({
                sources = {
                    per_filetype = {
                        org = { "orgmode" },
                    },
                    providers = {
                        orgmode = {
                            name = "Orgmode",
                            module = "orgmode.org.autocompletion.blink",
                            fallbacks = { "buffer" },
                        },
                    },
                },
            })

            require("telescope").setup()
            require("telescope").load_extension("orgmode")
            vim.keymap.set(
                "n",
                "<leader>r",
                require("telescope").extensions.orgmode.refile_heading
            )
            vim.keymap.set(
                "n",
                "<leader>foh",
                require("telescope").extensions.orgmode.search_headings
            )
            vim.keymap.set(
                "n",
                "<leader>li",
                require("telescope").extensions.orgmode.insert_link
            )
        end,
    },
}
