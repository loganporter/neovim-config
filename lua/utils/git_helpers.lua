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

return M
