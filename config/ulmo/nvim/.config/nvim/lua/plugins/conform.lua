return {
    {
        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>kk",
                mode = "n",
                function()
                    require("conform").format({
                        async = true,
                    })
                end,
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                c = { "clang-format" },
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
                astro = { "prettierd", lsp_format = "never" },
                json = { "prettierd" },
                jsonc = { "prettierd" },
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
