return {
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "emmet_language_server",
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
                "jsonls",
                "yamlls",
                "taplo",
                "hyprls"
            },
        },
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
    },
    {
        "mason-org/mason.nvim",
        opts = {
            PATH = "append",
        },
    },
}
