local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

vim.lsp.config("*", {
    capabilities = capabilities,
})

vim.lsp.config["tinymist"] = {
    cmd = { "tinymist" },
    filetypes = { "typst" },
    settings = {
        formatterMode = "typstyle",
        formatterProseWrap = true,
    },
}

vim.lsp.config["lua_ls"] = {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = {
                    vim.api.nvim_get_runtime_file("", true),
                    vim.fn.stdpath("data") .. "/lazy",
                },
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
}

vim.lsp.config["ruff"] = {
    init_options = {
        settings = {
            configuration = vim.fn.expand("~/.config/ruff/ruff.toml"),
            configurationPreference = "filesystemFirst",
        },
    },
}

vim.lsp.config["basedpyright"] = {
    settings = {
        basedpyright = {
            analysis = {
                disableOrganizeImports = true,
                typeCheckingMode = "basic",
            },
        },
        python = {
            analysis = {
                ignore = { "*" },
            },
        },
    },
}

vim.lsp.config["haskell-language-server"] = {
    cmd = { "haskell-language-server" },
    filetypes = { "haskell" },
}
vim.lsp.enable("haskell-language-server")
