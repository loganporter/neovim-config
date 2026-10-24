-- Search / replace using the visual selection as a literal string.
-- Called from `:<C-u>lua` keymaps, which leave visual mode first -- hence `gv`.
local M = {}

function M.operation(op)
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

return M
