return {
    {
        "smjonas/inc-rename.nvim",
        opts = {},
        keys = {
            {
                "grn",
                mode = "n",
                function()
                    return (":IncRename " .. vim.fn.expand("<cword>"))
                end,
                expr = true,
                desc = "LSP: Rename",
            },
        }
    }
}
