vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

vim.opt.number = true
vim.opt.relativenumber = true

-- vim.opt.colorcolumn = { 80, 121 }

vim.opt.list = true
vim.opt.listchars = {
    tab = "→ ",
    space = "·",
    trail = "·",
    extends = "…",
    precedes = "…",
}

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
