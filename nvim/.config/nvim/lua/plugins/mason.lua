return {
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "lua_ls",
                "tinymist",
                "ruff",
                "basedpyright",
                "ts_ls",
                "css_variables",
                "cssls",
                "cssmodules_ls",
                "tailwindcss",
                "eslint",
            },
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },
}
