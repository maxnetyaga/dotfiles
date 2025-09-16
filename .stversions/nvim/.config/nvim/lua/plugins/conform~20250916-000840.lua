return {
    {

        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>k",
                mode = "n",
                function()
                    require("conform").format({ async = true })
                end,
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            formatters = {
                stylua = {
                    append_args = { "--indent-type", "spaces" },
                },
            },
        },
    },
}
