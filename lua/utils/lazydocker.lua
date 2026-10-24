-- lazydocker (https://github.com/jesseduffield/lazydocker) in a floating terminal.
--
-- The same shape as the lazygit integration, minus the plugin: run the binary
-- in a float, close it when lazydocker exits, and put focus back where it was.
-- Unlike resterm there is no session worth keeping alive -- lazydocker reads
-- all its state from the Docker daemon -- so quitting it just closes the float.
local M = {}

function M.open()
  if vim.fn.executable("lazydocker") == 0 then
    vim.notify("lazydocker not found on $PATH (brew install lazydocker)", vim.log.levels.ERROR)
    return
  end

  local prev_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " lazydocker ",
    title_pos = "center",
  })

  local job = vim.fn.jobstart({ "lazydocker" }, {
    term = true,
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      if vim.api.nvim_win_is_valid(prev_win) then
        vim.api.nvim_set_current_win(prev_win)
      end
      -- Same as lazygit's exit callback: if we were launched from a terminal
      -- buffer, land back in normal mode rather than terminal input.
      if vim.bo.buftype == "terminal" then
        vim.schedule(function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
        end)
      end
    end,
  })

  if job <= 0 then
    vim.notify("Failed to start lazydocker", vim.log.levels.ERROR)
    pcall(vim.api.nvim_win_close, win, true)
    return
  end

  vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("LazyDocker", function()
  M.open()
end, { desc = "Open lazydocker in a float" })

return M
