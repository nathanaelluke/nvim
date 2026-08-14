vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.clipboard = "unnamedplus"

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true

vim.opt.colorcolumn = "80"

vim.opt.cmdheight = 0

vim.opt.ttimeoutlen = 0

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.wrap = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8

vim.api.nvim_create_autocmd("RecordingEnter", {
    callback = function()
        vim.o.cmdheight = 1
    end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = function()
        vim.o.cmdheight = 0
    end,
})
