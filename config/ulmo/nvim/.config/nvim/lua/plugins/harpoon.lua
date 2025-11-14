return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>a", function() require("harpoon"):list():add() end,                                    mode = "n", desc = "Open harpoon" },
            { "<C-e>",     function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, mode = "n", desc = "Harpoon menu" },

            { "<C-j>",     function() require("harpoon"):list():select(1) end,                                mode = "n", desc = "Open 1st harpoon file" },
            { "<C-k>",     function() require("harpoon"):list():select(2) end,                                mode = "n", desc = "Open 2nd harpoon file" },
            { "<C-l>",     function() require("harpoon"):list():select(3) end,                                mode = "n", desc = "Open 3rd harpoon file"  },
            { "<C-;>",     function() require("harpoon"):list():select(4) end,                                mode = "n", desc = "Open 4th harpoon file"  },
        },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()
        end
    }
}
