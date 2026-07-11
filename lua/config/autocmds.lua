-- Auto-save modified buffers when leaving a buffer or losing focus.
-- Skips special buffers (help, terminal, etc.) and gitgraph buffers,
-- which would otherwise get written as files in the working directory.
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].modified and vim.bo[buf].filetype ~= "gitgraph" and vim.bo[buf].buftype == "" then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent! write")
        end)
      end
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitgraph",
  callback = function(event)
    vim.bo[event.buf].modified = false
    vim.bo[event.buf].bufhidden = "wipe"
  end,
})

-- On startup with no file arguments, open a terminal instead of the empty buffer.
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    -- Only when nvim was launched bare: no file args, a single unnamed empty
    -- buffer, and not reading from stdin (e.g. `git commit`, piped input).
    if vim.fn.argc() == 0
        and vim.api.nvim_buf_get_name(0) == ""
        and vim.bo.buftype == ""
        and vim.api.nvim_buf_line_count(0) == 1
        and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == ""
    then
      -- Open the terminal after startup finishes. Opening it inline during
      -- VimEnter makes it inherit the global `number` option; deferring lets
      -- Neovim apply its usual terminal number suppression (which self-restores
      -- for normal buffers, so it won't leak line numbers into files opened
      -- later in this window), matching a terminal opened via <leader>tt.
      vim.schedule(function()
        vim.cmd("terminal")
        local term_win = vim.api.nvim_get_current_win()
        require("nvim-tree.api").tree.open({ focus = false })
        -- nvim-tree can still grab focus on open, so restore it on the next tick.
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(term_win) then
            vim.api.nvim_set_current_win(term_win)
          end
        end)
      end)
    end
  end,
})

-- Give terminal windows a pure black background instead of the colorscheme's
-- default dark grey. Done via a window-local `winhighlight` that remaps Normal
-- to a black group, applied only while a terminal buffer is displayed and
-- cleared when a normal buffer takes over the window (e.g. nvim-tree reusing
-- the startup terminal window), so files keep their usual grey background.
local TERM_WINHL = "Normal:TerminalNormal,NormalNC:TerminalNormal"
local function set_terminal_hl()
  vim.api.nvim_set_hl(0, "TerminalNormal", { bg = "#000000" })
end
set_terminal_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_terminal_hl })
vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter" }, {
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.wo.winhighlight = TERM_WINHL
    elseif vim.wo.winhighlight == TERM_WINHL then
      vim.wo.winhighlight = ""
    end
  end,
})

local filepathname = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
vim.opt.titlestring = "nvim - " .. filepathname:gsub("^~/code/", "")
vim.opt.title = true
