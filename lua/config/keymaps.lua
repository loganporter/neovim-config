local keymap = vim.keymap

-- Keymaps for BufferLine
-- Cycle through buffers
keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
-- Pick a buffer
keymap.set("n", "<leader>bp", "<Cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
keymap.set("n", "<leader>bc", "<Cmd>BufferLinePickClose<CR>", { desc = "Pick close buffer" })
-- Close current buffer
keymap.set("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete buffer" })

--NvimTree keymaps
keymap.set("n", "<leader>e", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus NvimTree" })
keymap.set("n", "<leader>t", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

-- Terminal Mode Escape
keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })