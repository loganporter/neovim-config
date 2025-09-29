local keymap = vim.keymap

-- Save file
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })

-- Keymaps for BufferLine
-- Cycle through buffers
keymap.set("n", "t", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap.set("n", "T", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
-- Pick a buffer to close
keymap.set("n", "<leader>bcp", "<Cmd>BufferLinePickClose<CR>", { desc = "Pick close buffer" })
-- Pick a buffer
keymap.set("n", "<leader>bp", "<Cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
-- Go to first buffer
keymap.set("n", "<leader>bf", "<Cmd>BufferLineGoToBuffer 1<CR>", { desc = "Go to first buffer" })
-- Go to last buffer
keymap.set("n", "<leader>bl", "<Cmd>BufferLineGoToBuffer -1<CR>", { desc = "Go to last buffer" })
-- Close current buffer
keymap.set("n", "<leader>bcc", "<Cmd>:bd<CR>", { desc = "Close current buffer" })
-- Close other buffers
keymap.set("n", "<leader>bco", "<Cmd>BufferLineCloseOthers<CR>", { desc = "Close other buffers" })
-- Close buffers to the left
keymap.set("n", "<leader>bcl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Close buffers to the left" })
-- Close buffers to the right
keymap.set("n", "<leader>bcr", "<Cmd>BufferLineCloseRight<CR>", { desc = "Close buffers to the right" })
-- Sort buffers by directory
keymap.set("n", "<leader>bsd", "<Cmd>BufferLineSortByDirectory<CR>", { desc = "Sort buffers by directory" })
-- Sort buffers by extension
keymap.set("n", "<leader>bse", "<Cmd>BufferLineSortByExtension<CR>", { desc = "Sort buffers by extension" })
-- move between buffer windows
keymap.set("n", "<leader>m", "<C-w>", { desc = "Move between windows" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", silent = true, noremap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", silent = true, noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", silent = true, noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", silent = true, noremap = true })
-- create a new empty buffer
keymap.set({ "n", "v" }, "<leader>bn", ":enew<CR>", { desc = "New empty buffer" })
keymap.set({ "n", "v" }, "<leader>bv", ":vnew<CR>", { desc = "New empty buffer in vertical split" })

--NvimTree keymaps
keymap.set("n", "<leader>e", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus NvimTree" })
keymap.set("n", "<leader>tr", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
keymap.set("n", "<leader>tf", "<Cmd>NvimTreeFindFile<CR>", { desc = "Find file in NvimTree" })
keymap.set("n", "<leader>tc", "<Cmd>NvimTreeCollapse<CR>", { desc = "Collapse NvimTree" })

-- General keymaps
-- toggle line wrap
keymap.set("n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle line wrap" })
-- toggle spell check
keymap.set("n", "<leader>st", ":set spell!<CR>", { desc = "Toggle spell check" })
-- spell suggestions
keymap.set("n", "<leader>ss", "z=", { desc = "Spell suggestions" })
-- no highlight
keymap.set({ "n", "v" }, "<leader>n", ":noh<CR>", { desc = "No highlight", silent = true })
-- select all
keymap.set({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all", noremap = true, silent = true })



-- Open a terminal
keymap.set("n", "<leader>tt", ":terminal<CR>", { desc = "Open terminal" })
-- Open terminal in a horizontal split
keymap.set("n", "<leader>th", ":split | terminal<CR>", { desc = "Open terminal in horizontal split" })
-- Open terminal in a vertical split
keymap.set("n", "<leader>tv", ":vsplit | terminal<CR>", { desc = "Open terminal in vertical split" })
-- Open terminal in a new tab
keymap.set("n", "<leader>tn", ":tabnew | terminal<CR>", { desc = "Open terminal in new tab" })
-- Terminal Mode Escape
keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Diagnostic keymaps
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Set diagnostics to location list" })

-- LSP keymaps
keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, { desc = "Code action" })
keymap.set({ "n", "v" }, "<leader>lr", ":LspRestart<CR>", { desc = "Restart LSP server" })

-- Diffview keymaps
keymap.set("n", "<leader>dv", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
keymap.set("n", "<leader>dm", "<cmd>DiffviewOpen main<cr>", { desc = "Open Diffview with main branch" })
keymap.set("n", "<leader>dq", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
-- Merge operations
keymap.set("n", "<leader>dh", "<cmd>DiffviewFileHistory<cr>", { desc = "View Repo history" })
keymap.set("n", "<leader>dy", "<cmd>DiffviewFileHistory %<cr>", { desc = "View file history" })
keymap.set("n", "<leader>da", "<cmd>DiffviewOpen --all<cr>", { desc = "Open Diffview with all changes" })

-- Gitsigns keymaps
keymap.set("n", "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
keymap.set("n", "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
keymap.set("n", "<leader>hu", ":Gitsigns undo_stage_hunk<CR>", { desc = "Undo stage hunk" })
keymap.set("n", "<leader>hp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })

-- Telescope keymaps
local builtin = require('telescope.builtin')
keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
keymap.set('n', '<leader>fg', builtin.git_files, { desc = "Find git files" })
keymap.set('n', '<leader>fl', builtin.live_grep, { desc = "Live grep" })
keymap.set('n', ';', builtin.buffers, { desc = "Buffers" })
keymap.set('n', '<leader>fb', builtin.current_buffer_fuzzy_find, { desc = "Current buffer fuzzy find" })
keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help tags" })
keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Keymaps" })
keymap.set('n', '<leader>fo', builtin.commands, { desc = "Commands" })
-- LSP related Telescope keymaps
keymap.set('n', '<leader>fe', builtin.diagnostics, { desc = "Diagnostics" })
keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = "LSP references" })
keymap.set('n', '<leader>fi', builtin.lsp_implementations, { desc = "LSP implementations" })
keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = "LSP document symbols" })
keymap.set('n', '<leader>fw', builtin.lsp_workspace_symbols, { desc = "LSP workspace symbols" })
keymap.set('n', '<leader>fd', builtin.lsp_definitions, { desc = "LSP definitions" })
keymap.set('n', '<leader>ft', builtin.lsp_type_definitions, { desc = "LSP Type definitions" })

-- Close quickfix and location list
keymap.set("n", "<leader>cq", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
keymap.set("n", "<leader>cl", "<cmd>lclose<CR>", { desc = "Close location list" })

-- GitGraph keymaps
keymap.set("n", "<leader>gg", function()
  require("gitgraph").draw({}, { all = true, max_count = 5000 })
end, { desc = "Open GitGraph" })
keymap.set("n", "<leader>gb", function()
  require("gitgraph").draw({}, { all = false, max_count = 5000 })
end, { desc = "Open GitGraph for current branch" })

-- CodeCompanion keymaps
keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionChat<CR>", { desc = "Open CodeCompanion" })
keymap.set({ "n", "v" }, "<leader>ct", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "Toggle CodeCompanion" })
keymap.set({ "n", "v" }, "<leader>ci", "<cmd>CodeCompanion<CR>", { desc = "Open inline CodeCompanion" })
keymap.set("v", "<leader>ca", "<cmd>CodeCompanionChat Add<CR>", { desc = "Add visual selection to CodeCompanion" })

-- Copilot keymaps
-- Accept suggestion
keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
-- Accept next word suggestion
keymap.set("i", "<C-l>", '<Plug>(copilot-accept-word)')

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

-- Keymaps for search and replace with visual selection
_G.VisualOperation = function(op)
  vim.cmd('normal! gvy')
  local text = vim.fn.getreg('"')
  if text == '' then
    return
  end
  local escaped_text = vim.fn.escape(text, '/\\')
  if op == 'search' then
    vim.cmd('normal! /' .. escaped_text .. '\r')
  elseif op == 'replace' then -- only replaces the first occurrence
    vim.api.nvim_feedkeys(":%s/" .. escaped_text .. "/", "n", false)
  elseif op == 'replace_all' then
    vim.api.nvim_feedkeys(":%s/" .. escaped_text .. "//g", "n", false)
  end
end

keymap.set("v", "<leader>f", ":<C-u>lua _G.VisualOperation('search')<CR>",
  { desc = "Search for visual selection", noremap = true, silent = true })
keymap.set("v", "<leader>r", ":<C-u>lua _G.VisualOperation('replace_all')<CR>",
  { desc = "Find and replace all for visual selection", noremap = true, silent = true })


-- Lazy keymaps
keymap.set("n", "<leader>lu", "<cmd>Lazy update<CR>", { desc = "Update Lazy" })
keymap.set("n", "<leader>lp", "<cmd>Lazy restore<CR>", { desc = "Restore Lazy" })
