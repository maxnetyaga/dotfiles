---@diagnostic disable: need-check-nil, undefined-field

local commander = require("commander")

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<M-v>", "<C-v>")

vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
vim.keymap.set("n", "S", "<Plug>(leap-from-window)")

-- Reselect visual block after indenting
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

vim.keymap.set(
    { "n", "v" },
    "<C-h>",
    "<cmd>nohlsearch<CR>",
    { desc = "Clear search highlight" }
)

-- Leader + number to jump to tab
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>1",
    "1gt",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>2",
    "2gt",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>3",
    "3gt",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>4",
    "4gt",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>5",
    "5gt",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>6",
    "6gt",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>7",
    "7gt",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>8",
    "8gt",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>9",
    "9gt",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "n", "x", "v" },
    "<leader>0",
    ":tablast<CR>",
    { noremap = true, silent = true }
)

vim.keymap.set({ "n", "v" }, "<Leader>m", function()
    require("telescope").extensions.macroni.saved_macros()
end)

-------------------------------------------------------------------------------

commander.add({
    {
        desc = "LSP: Go to definition",
        cmd = vim.lsp.buf.definition,
        keys = { "n", "gd" },
    },
    {
        desc = "ESLint: Fix all",
        cmd = "<cmd>:LspEslintFixAll<cr>",
        keys = { "n", "<leader>ko" },
    },
})
