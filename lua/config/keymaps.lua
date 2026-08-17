local keymap = vim.keymap

-- Save file
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })

-- Keymaps for BufferLine
-- Cycle through buffers. Shift is held down and l/h tapped repeatedly, so
-- this keeps the "hold a modifier and tap" feel the old t/T bindings had.
-- Those shadowed the `t`/`T` till-motions, which cost `dt,`, `ct)` and the
-- rest of the operator+till family; H/L (jump to top/bottom of the visible
-- window) are the much cheaper thing to give up.
keymap.set("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap.set("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
-- The screen-position motions H/L displaced above, kept within reach.
keymap.set({ "n", "v" }, "<leader>H", "H", { desc = "Top of window" })
keymap.set({ "n", "v" }, "<leader>L", "L", { desc = "Bottom of window" })
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
-- always move the divider left/right regardless of which pane is focused
local function move_divider(dir, amount)
  local has_right = vim.fn.winnr("l") ~= vim.fn.winnr()
  -- moving right: grow current if it has a right neighbor, else shrink it (moves its left divider right)
  -- moving left: mirror of the above
  local sign = (dir == "right") == has_right and "+" or "-"
  vim.cmd("vertical resize " .. sign .. amount)
end
-- resize splits
vim.keymap.set("n", "<leader><Left>", function() move_divider("left", 12) end,
  { desc = "Move split divider left", silent = true })
vim.keymap.set("n", "<leader><Right>", function() move_divider("right", 12) end,
  { desc = "Move split divider right", silent = true })
vim.keymap.set("n", "<leader><Up>", "<Cmd>resize +2<CR>", { desc = "Grow split height", silent = true })
vim.keymap.set("n", "<leader><Down>", "<Cmd>resize -2<CR>", { desc = "Shrink split height", silent = true })
-- hold to resize continuously
vim.keymap.set("n", "<A-h>", function() move_divider("left", 3) end,
  { desc = "Move split divider left (hold)", silent = true })
vim.keymap.set("n", "<A-l>", function() move_divider("right", 3) end,
  { desc = "Move split divider right (hold)", silent = true })
vim.keymap.set("n", "<A-j>", "<Cmd>resize +2<CR>", { desc = "Grow split height (hold)", silent = true })
vim.keymap.set("n", "<A-k>", "<Cmd>resize -2<CR>", { desc = "Shrink split height (hold)", silent = true })
-- create a new empty buffer
keymap.set({ "n", "v" }, "<leader>bn", ":enew<CR>", { desc = "New empty buffer" })
keymap.set({ "n", "v" }, "<leader>bv", ":vnew<CR>", { desc = "New empty buffer in vertical split" })

--NvimTree keymaps
keymap.set("n", "<leader>e", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus NvimTree" })
keymap.set("n", "<leader>tr", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
keymap.set("n", "<leader>tf", "<Cmd>NvimTreeFindFile<CR>", { desc = "Find file in NvimTree" })
keymap.set("n", "<leader>tc", "<Cmd>NvimTreeCollapse<CR>", { desc = "Collapse NvimTree" })
keymap.set("n", "<leader>tx", function() require("nvim-tree.api").fs.clear_clipboard() end,
  { desc = "Clear NvimTree clipboard" })

-- General keymaps
-- toggle line wrap
keymap.set("n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle line wrap" })
-- toggle spell check
keymap.set("n", "<leader>st", ":set spell!<CR>", { desc = "Toggle spell check" })
-- Toggle Markview
keymap.set("n", "<leader>mt", ":Markview Toggle<CR>", { desc = "Toggle Markview" })
-- spell suggestions
keymap.set("n", "<leader>ss", "z=", { desc = "Spell suggestions" })
-- add word to git tracked spell file
keymap.set("n", "<leader>sa", "zg", { desc = "Add word to git spell file" })
-- add word to local spell file
keymap.set("n", "<leader>sl", function()
  local original_spellfile_str = vim.o.spellfile
  local files = vim.split(original_spellfile_str, ",")
  if #files > 1 then
    local swapped_spellfile_str = files[2] .. "," .. files[1]
    vim.o.spellfile = swapped_spellfile_str
    vim.cmd("normal! zg")
    vim.o.spellfile = original_spellfile_str
    print("Added word to local spell file")
  else
    print("Local spell file not configured")
  end
end, { desc = "Add word to local spell file" })
-- Jump between misspellings. Remapped onto the capital-S variants, which stop
-- only on SpellBad. Bare `]s`/`[s` also stop on SpellRare/SpellLocal/SpellCap,
-- and lua/plugins/colorscheme.lua clears those three groups deliberately -- so
-- they were landing on words with no visible underline.
keymap.set({ "n", "v" }, "]s", "]S", { desc = "Next misspelling", remap = false })
keymap.set({ "n", "v" }, "[s", "[S", { desc = "Prev misspelling", remap = false })
-- no highlight
keymap.set({ "n", "v" }, "<leader>n", ":noh<CR>", { desc = "No highlight", silent = true })
-- select all -- on <leader>a rather than <C-a>, which is vim's increment-number
-- operator (and its <C-x> decrement counterpart).
keymap.set({ "n", "v" }, "<leader>a", "ggVG", { desc = "Select all", noremap = true, silent = true })



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
-- Pass Option+Arrow keys to terminal for word navigation
keymap.set("t", "<A-Right>", "<A-Right>", { desc = "Word forward in terminal", noremap = true })
keymap.set("t", "<A-Left>", "<A-Left>", { desc = "Word backward in terminal", noremap = true })

-- Diagnostic keymaps (goto_prev/goto_next are deprecated in favour of jump)
keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
  { desc = "Go to previous diagnostic" })
keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,
  { desc = "Go to next diagnostic" })
keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Set diagnostics to location list" })

-- LSP keymaps
keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, { desc = "Code action" })
keymap.set({ "n", "v" }, "<leader>lr", "<cmd>lsp restart<cr>", { desc = "Restart LSP server" })

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
keymap.set("n", "<leader>hi", ":Gitsigns preview_hunk_inline<CR>", { desc = "Preview hunk inline" })
keymap.set("n", "]h", ":Gitsigns next_hunk<CR>", { desc = "Next hunk" })
keymap.set("n", "[h", ":Gitsigns prev_hunk<CR>", { desc = "Prev hunk" })

-- Telescope keymaps
-- Each picker is wrapped in a closure rather than resolved from a top-level
-- `require('telescope.builtin')`: that require ran during init.lua, which both
-- pulled all of telescope into startup and made the entire config fail to load
-- if telescope wasn't installed yet. Deferring it lets lazy.nvim load telescope
-- on first use.
local function pick(name)
  return function()
    require('telescope.builtin')[name]()
  end
end

keymap.set('n', '<leader>ff', pick('find_files'), { desc = "Find files" })
keymap.set('n', '<leader>fg', pick('git_files'), { desc = "Find git files" })
keymap.set('n', '<leader>fl', pick('live_grep'), { desc = "Live grep" })
keymap.set('n', ';', pick('buffers'), { desc = "Buffers" })
keymap.set('n', '<leader>fb', pick('current_buffer_fuzzy_find'), { desc = "Current buffer fuzzy find" })
keymap.set('n', '<leader>fh', pick('help_tags'), { desc = "Help tags" })
keymap.set('n', '<leader>fk', pick('keymaps'), { desc = "Keymaps" })
keymap.set('n', '<leader>fo', pick('commands'), { desc = "Commands" })
-- LSP related Telescope keymaps
keymap.set('n', '<leader>fe', pick('diagnostics'), { desc = "Diagnostics" })
keymap.set('n', '<leader>fs', function()
  require("config.spellcheck").workspace()
end, { desc = "Spelling errors (workspace)" })
keymap.set('n', '<leader>fr', pick('lsp_references'), { desc = "LSP references" })
keymap.set('n', '<leader>fi', pick('lsp_implementations'), { desc = "LSP implementations" })
keymap.set('n', '<leader>fm', pick('lsp_document_symbols'), { desc = "LSP document symbols" })
keymap.set('n', '<leader>fw', pick('lsp_workspace_symbols'), { desc = "LSP workspace symbols" })
keymap.set('n', '<leader>fd', pick('lsp_definitions'), { desc = "LSP definitions" })
keymap.set('n', '<leader>ft', pick('lsp_type_definitions'), { desc = "LSP Type definitions" })

-- Close quickfix and location list
keymap.set("n", "<leader>cq", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
keymap.set("n", "<leader>cl", "<cmd>lclose<CR>", { desc = "Close location list" })

-- GitGraph keymaps
local function open_gitgraph(args)
  require("gitgraph").draw({}, args)
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buflisted = true
  vim.bo[buf].modified = false
end

keymap.set("n", "<leader>gg", function()
  open_gitgraph({ all = true, max_count = 5000 })
end, { desc = "Open GitGraph" })
keymap.set("n", "<leader>gb", function()
  open_gitgraph({ all = false, max_count = 5000 })
end, { desc = "Open GitGraph for current branch" })

-- Lazygit keymap
keymap.set("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "Open lazygit" })

-- CodeCompanion keymaps
keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionActions<CR>", { desc = "CodeCompanion actions" })
keymap.set({ "n", "v" }, "<leader>cn", "<cmd>CodeCompanionChat<CR>", { desc = "Open CodeCompanion" })
keymap.set({ "n", "v" }, "<leader>ci", "<cmd>CodeCompanionCLI agent=claude<CR>", { desc = "Open Claude Code (CLI)" })
keymap.set({ "n", "v" }, "<leader>ct", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "Toggle CodeCompanion" })
keymap.set({ "n", "v" }, "<leader>ch", "<cmd>CodeCompanion<CR>", { desc = "Open inline CodeCompanion" })
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
  -- Yanking to grab the selection clobbers the unnamed register, so stash and
  -- restore it -- otherwise searching for a selection silently destroys
  -- whatever you last yanked.
  local saved = vim.fn.getreginfo('"')
  vim.cmd('normal! gvy')
  local text = vim.fn.getreg('"')
  vim.fn.setreg('"', saved)
  if text == '' then
    return
  end
  -- `\V` (very-nomagic) makes everything after it literal except `\` itself, so
  -- only the backslash and the `/` delimiter need escaping. Without it the
  -- selection was interpreted as a regex: selecting `foo.bar[1]` searched for
  -- the pattern `foo.bar[1]`, matching `fooxbar1` and not the literal text.
  local escaped_text = '\\V' .. vim.fn.escape(text, '/\\')
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

-- UFO keymaps (deferred require, as with telescope above)
keymap.set("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
keymap.set("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })
keymap.set("n", "zr", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
keymap.set("n", "zm", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })

-- Grug-far keymaps
keymap.set("n", "<leader>sr", "<cmd>GrugFar<CR>", { desc = "Search and replace (grug-far)" })
keymap.set("v", "<leader>sr", ":<C-u>lua require('grug-far').with_visual_selection()<CR>",
  { desc = "Search and replace visual selection (grug-far)", noremap = true, silent = true })

-- Lazy keymaps
keymap.set("n", "<leader>lu", "<cmd>Lazy update<CR>", { desc = "Update Lazy" })
keymap.set("n", "<leader>lp", "<cmd>Lazy restore<CR>", { desc = "Restore Lazy" })
