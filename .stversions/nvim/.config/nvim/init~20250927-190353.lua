require("config.lazy")

require("config.wsl_opts")

require("config.lsp")

require("config.keymaps")

require("config.autocmds")

local cursorline_bg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg
vim.api.nvim_set_hl(0, "MatchParen", { fg = "#D75F87", bg = cursorline_bg })
vim.cmd([[
  hi NormalFloat guibg=NONE
  hi FloatBorder guibg=NONE
  hi Pmenu guibg=NONE
]])

