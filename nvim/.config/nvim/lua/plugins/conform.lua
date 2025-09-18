return {
    {
        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>k",
                mode = "n",
                function()
                    require("conform").format({
                        async = true,
                        lsp_fallback = true,
                    })
                end,
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = {
                    "ruff_fix",
                    "ruff_format",
                    "ruff_organize_imports",
                },
                rust = { "rustfmt", lsp_format = "fallback" },
                javascript = {
                    "prettierd",
                },
                typescript = {
                    "prettierd",
                },
                javascriptreact = {
                    "prettierd",
                },
                typescriptreact = {
                    "prettierd",
                },
                json = { "prettierd", stop_after_first = true },
                sh = { "beautysh" },
                zsh = { "beautysh" },
                sql = { "sql_formatter" },
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
