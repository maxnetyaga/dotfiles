return {
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        keys = {
            {
                "zR",
                mode = "n",
                function()
                    require(require("ufo").openAllFolds)
                end,
                desc = "Open all folds",
            },
            {
                "zM",
                mode = "n",
                function()
                    require(require("ufo").closeAllFolds())
                end,
                desc = "Close all folds",
            },
        },
        lazy = false,
        opts = {},
    },
}
