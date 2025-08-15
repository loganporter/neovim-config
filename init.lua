-- Set some basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.cursorline = true

-- Set up a leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- A simple keybinding
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })

require("config.lazy")
