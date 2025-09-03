local keymap = vim.keymap

-- Keymaps for BufferLine
-- Cycle through buffers
keymap.set("n", "]t", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap.set("n", "t", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap.set("n", "[t", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
-- Pick a buffer to close
keymap.set("n", "<leader>bcp", "<Cmd>BufferLinePickClose<CR>", { desc = "Pick close buffer" })
-- Close current buffer
keymap.set("n", "<leader>bcc", "<Cmd>:bd<CR>", { desc = "Close current buffer" })
-- Close other buffers
keymap.set("n", "<leader>bco", "<Cmd>BufferLineCloseOthers<CR>", { desc = "Close other buffers" })
-- Close buffers to the left
keymap.set("n", "<leader>bcl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Close buffers to the left" })
-- Close buffers to the right
keymap.set("n", "<leader>bcr", "<Cmd>BufferLineCloseRight<CR>", { desc = "Close buffers to the right" })
-- move between buffer windows
keymap.set("n", "<leader>m", "<C-w>", { desc = "Move between windows" })

--NvimTree keymaps
keymap.set("n", "<leader>e", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus NvimTree" })
keymap.set("n", "<leader>t", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

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

-- Diffview keymaps
keymap.set("n", "<leader>dv", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
keymap.set("n", "<leader>dm", "<cmd>DiffviewOpen main<cr>", { desc = "Open Diffview with main branch" })
keymap.set("n", "<leader>dq", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })

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

-- Toggle comment on a line
keymap.set("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", { desc = "Toggle comment" })

-- Toggle comment on a visual selection
keymap.set("v", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
  { desc = "Toggle comment" })

-- GitGraph keymaps
keymap.set("n", "<leader>gg", function()
  require("gitgraph").draw({}, { all = true, max_count = 5000 })
end, { desc = "Open GitGraph" })

-- CodeCompanion keymaps
keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionChat<CR>", { desc = "Open CodeCompanion" })
keymap.set({ "n", "v" }, "<leader>ct", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "Toggle CodeCompanion" })
keymap.set({ "n", "v" }, "<leader>ci", "<cmd>CodeCompanion<CR>", { desc = "Open inline CodeCompanion" })
keymap.set("v", "<leader>ca", "<cmd>CodeCompanionChat Add<CR>", { desc = "Add visual selection to CodeCompanion" })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

-- Copilot keymaps
keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', { expr = true, silent = true, noremap = true })
keymap.set("i", "<D-Right>", 'copilot#Accept("<Space>")', { expr = true, silent = true, noremap = true })
