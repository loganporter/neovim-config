-- Set some basic options
vim.opt.wrap = false
vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.guifont = "Menlo Regular for Powerlines:h14"
vim.opt.spell = true

-- Hello my name is Tim

-- Disable the how to disable mouse option in right click menu
vim.cmd([[
    aunmenu PopUp.How-to\ disable\ mouse
    aunmenu PopUp.-2-
]])

-- Set up a leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.lazy")
require("config.keymaps")
require("config.autocmds")
