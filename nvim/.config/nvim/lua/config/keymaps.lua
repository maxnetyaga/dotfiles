-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

require("commander").add({
  {
    desc = "Open commander",
    cmd = require("commander").show,
    keys = { "n", "<Leader>c" },
  },
})

require("commander").add({
  {
    desc = "Explorer",
    cmd = "<CMD>Oil --float<CR>",
    keys = { "n", "<Leader>e" },
  },
})

-- require("commander").add({
--     {
--         desc = "Close current buffer",
--         cmd = Snacks.,
--         keys = { "n", "<C-c>" },
--     },
-- })

require("commander").add({
  {
    keys = { { "n", "v" }, "<leader>db" },
    cmd = "<cmd>DBUI<cr>",
    desc = "DB: UI",
  },
})

--- Formatting
require("commander").add({
  {
    keys = { { "n", "v" }, "<leader>k" },
    cmd = function()
      require("conform").format({ async = true, lsp_fallback = true })
    end,
    desc = "Format file or range",
  },
})

--- Git
require("commander").add({
  {
    keys = { "n", "<leader>gp" },
    cmd = ":Gitsigns preview_hunk<CR>",
    desc = "Preview changes (git)",
  },
})

--- LSP Navigation
require("commander").add({
  {
    keys = { "n", "<F2>" },
    cmd = "<CMD>Lspsaga rename<CR>",
    desc = "LSP: Rename",
  },
})
require("commander").add({
  {
    keys = { "n", "gd" },
    cmd = "<CMD>Lspsaga finder def<CR>",
    desc = "LSP: Go to Definition",
  },
})
require("commander").add({
  {
    keys = { "n", "gt" },
    cmd = "<CMD>Lspsaga finder tyd<CR>",
    desc = "LSP: Go to Type Definition",
  },
})
require("commander").add({
  {
    keys = { "n", "gD" },
    cmd = vim.lsp.buf.declaration,
    desc = "LSP: Go to Declaration",
  },
})
require("commander").add({
  {
    keys = { "n", "gi" },
    cmd = "<CMD>Lspsaga finder imp<CR>",
    desc = "LSP: Go to Implementation",
  },
})
require("commander").add({
  {
    keys = { "n", "gr" },
    cmd = "<CMD>Lspsaga finder ref<CR>",
    desc = "LSP: Go to References",
  },
})
require("commander").add({
  {
    desc = "LSP: Code Action",
    cmd = "<CMD>Lspsaga code_action<CR>",
    keys = { "n", "<Leader>a" },
  },
})
require("commander").add({
  {
    desc = "LSP: Hover",
    cmd = "<CMD>Lspsaga hover_doc<CR>",
    -- cmd = vim.lsp.buf.hover,
    keys = { "n", "K" },
  },
})

--- Diagnostic
require("commander").add({
  {
    keys = { "n", "<leader>dd" },
    cmd = vim.diagnostic.open_float,
    desc = "Diagnostic: Show message",
  },
})
-- require("commander").add({
--     {
--         keys = { "n", "<leader>dn" },
--         cmd = function ()
--             vim.diagnostic.jump({ severity = { min = 4, max = 1 }, count = 1 })
--         end,
--         desc = "Diagnostic: Next problem",
--     },
-- })
require("commander").add({
  {
    keys = { "n", "<leader>dn" },
    cmd = "<CMD>Lspsaga diagnostic_jump_next<CR>",
    desc = "Diagnostic: Next problem",
  },
})
-- require("commander").add({
--     {
--         keys = { "n", "<leader>dp" },
--         cmd = function ()
--             vim.diagnostic.jump({ severity = { min = 4, max = 1 }, count = -1 })
--         end,
--         desc = "Diagnostic: Previous problem",
--     },
-- })
require("commander").add({
  {
    keys = { "n", "<leader>dp" },
    cmd = "<CMD>Lspsaga diagnostic_jump_prev<CR>",
    desc = "Diagnostic: Previous problem",
  },
})
require("commander").add({
  {
    keys = { "n", "<leader>do" },
    cmd = "<cmd>Telescope diagnostics<cr>",
    desc = "Telescope: Diagnostic",
  },
})

---  Telescope
require("commander").add({
  {
    keys = { "n", "<leader>ff" },
    cmd = function()
      require("telescope.builtin").find_files({
        find_command = {
          "fd",
          "--type",
          "f",
          "--type",
          "l",
          "--type",
          "d",
          "--hidden",
          "--no-ignore",
          "--exclude",
          ".git",
          "--exclude",
          "__pycache__",
          "--exclude",
          ".mypy_cache",
          "--exclude",
          ".venv",
          "--exclude",
          "node_modules",
        },
      })
    end,
    desc = "Telescope: Find",
  },
})
require("commander").add({
  {
    keys = { "n", "<C-p>" },
    cmd = function()
      require("telescope.builtin").find_files({
        find_command = {
          "fd",
          "--type",
          "f",
          "--type",
          "l",
          "--type",
          "d",
          "--hidden",
          "--no-ignore",
          "--exclude",
          ".git",
          "--exclude",
          "__pycache__",
          "--exclude",
          ".mypy_cache",
          "--exclude",
          ".venv",
          "--exclude",
          "node_modules",
        },
      })
    end,
    desc = "Telescope: Find",
  },
})
require("commander").add({
  {
    keys = { "n", "<leader>fg" },
    cmd = require("telescope.builtin").live_grep,
    desc = "Telescope: Grep",
  },
})
require("commander").add({
  {
    keys = { "n", "<leader>fb" },
    cmd = require("telescope.builtin").buffers,
    desc = "Telescope: Buffers",
  },
})
require("commander").add({
  {
    keys = { "n", "<leader>fh" },
    cmd = require("telescope.builtin").help_tags,
    desc = "Telescope: Help",
  },
})
require("commander").add({
  {
    keys = { "n", "<leader>fc" },
    cmd = ":Telescope neoclip<cr>",
    desc = "Telescope: Clipboard history",
  },
})
