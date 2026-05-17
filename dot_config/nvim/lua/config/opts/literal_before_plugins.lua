vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.undofile = true
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

vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.diagnostic.config({
    float = {
        source = true,
    },
})

vim.o.winborder = "rounded"

vim.opt.langmap =
"ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"

vim.filetype.add({
    extension = {
        njk = "jinja",
    },
    pattern = {
        [".*%.env%..*"] = "sh",
    },
})
