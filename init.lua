-- Set some basic options
vim.opt.wrap = false
vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.guifont = "Menlo Regular for Powerlines:h14"
-- Persist undo history across sessions (~/.local/state/nvim/undo).
vim.opt.undofile = true
-- Case-insensitive search unless the pattern contains a capital.
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Keep some context visible above/below the cursor.
vim.opt.scrolloff = 4
-- Always reserve the sign column so diagnostics/gitsigns appearing don't
-- shift the text sideways.
vim.opt.signcolumn = "yes"
-- Fold settings
vim.o.foldcolumn = 'auto:9'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.opt.fillchars = {
  fold = ' ', -- character to use in the fold column for a closed fold
  foldopen = '', -- character for an open fold (downward arrow)
  foldsep = ' ', -- character for the vertical separator line
  foldclose = '', -- character for a closed fold (rightward arrow)
}
-- Spell checking settings. `spell` itself defaults off and is switched on
-- per-window by the filetype autocmd below.
vim.opt.spell = false
vim.opt.spelllang = 'en_nz'
vim.opt.spellfile = vim.fn.stdpath('config') ..
    '/spell/en.utf-8.add,' .. vim.fn.stdpath('config') .. '/spell/en.utf-8.local.add'
vim.opt.spellcapcheck = ''
vim.opt.spellsuggest = 'best,6'
vim.cmd("set spelloptions=camel")
-- enable spell by syntax filetype
--
-- `spell` is window-local, so this uses vim.opt_local: assigning through
-- vim.opt would also write the global default, which then leaks into every
-- newly opened window (a split of a code file inheriting spell from whichever
-- markdown buffer happened to be entered last).
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost" }, {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    local spell_filetypes = require('config.spellcheck').filetypes
    vim.opt_local.spell = vim.bo.buftype ~= "terminal" and vim.tbl_contains(spell_filetypes, ft)
  end,
})

-- Disable the how to disable mouse option in right click menu
vim.cmd([[
    aunmenu PopUp.How-to\ disable\ mouse
    aunmenu PopUp.-2-
]])

-- Neovim detects .http out of the box but not .rest; resterm treats them
-- identically, so give .rest the same filetype (and so the same treesitter
-- highlighting and spell handling).
vim.filetype.add({ extension = { rest = "http" } })

-- Set up a leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.lazy")
require("config.keymaps")
require("config.autocmds")
