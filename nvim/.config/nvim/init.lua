require("config.lazy")
require("config.keymaps")
require("config.lsp")

local cursorline_bg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg
vim.api.nvim_set_hl(0, "MatchParen", { fg = "#D75F87", bg = cursorline_bg })
