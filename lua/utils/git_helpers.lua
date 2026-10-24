local M = {}

-- Yank the branch of nvim's working directory (not the current buffer's file).
-- Written to "+ so it reaches the system clipboard; with clipboard=unnamedplus
-- that's also what a plain `p` pastes.
function M.copy_branch()
  local result = vim.system({ "git", "branch", "--show-current" }, { cwd = vim.fn.getcwd(), text = true }):wait()
  if result.code ~= 0 then
    vim.notify("Not a git repository", vim.log.levels.WARN)
    return
  end
  local branch = vim.trim(result.stdout)
  -- --show-current prints nothing on a detached HEAD
  if branch == "" then
    vim.notify("Detached HEAD, no branch to copy", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", branch)
  vim.notify("Copied branch: " .. branch)
end

-- Open GitGraph as a regular listed buffer. It comes up unlisted and flagged
-- modified, which hides it from the buffer line and trips the "unsaved changes"
-- prompt on quit.
function M.open_gitgraph(args)
  require("gitgraph").draw({}, args)
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buflisted = true
  vim.bo[buf].modified = false
end

return M
