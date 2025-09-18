return {
    {
        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>k",
                mode = "n",
                function()
                    require("conform").format({ async = true, lsp_fallback = true })
                end,
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                javascript = {
                    "prettierd",
                    "prettier",
                    stop_after_first = true,
                },
            },
            formatters = {
                stylua = {
                    append_args = {
                        "--indent-type",
                        "spaces",
                        "--column-width",
                        "79",
                    },
                },
            },
        },
    },
}
