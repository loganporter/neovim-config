-- Send the LSP diagnostic(s) under the cursor to a CodeCompanion chat.
--
-- CodeCompanion's built-ins don't cover this: `#{diagnostics}` shares every
-- diagnostic in the buffer, and the `/lsp` prompt is visual-mode only and
-- always opens a fresh chat. This mirrors `:CodeCompanionChat Add` (see
-- CodeCompanion.add) but with the diagnostics on the cursor line plus the code
-- they point at.
local M = {}

local severity_names = { "ERROR", "WARNING", "INFORMATION", "HINT" }

---Diagnostics on the cursor line, narrowed to the ones under the cursor column
---when there are any (so a line with several errors sends the one you're on).
---@param bufnr number
---@return vim.Diagnostic[]
local function cursor_diagnostics(bufnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local lnum = row - 1
  local on_line = vim.diagnostic.get(bufnr, { lnum = lnum })

  local under_cursor = vim.tbl_filter(function(d)
    local start_col = d.lnum == lnum and d.col or 0
    local end_col = d.end_lnum == lnum and d.end_col or math.huge
    return col >= start_col and col < math.max(end_col, start_col + 1)
  end, on_line)

  return #under_cursor > 0 and under_cursor or on_line
end

---@param bufnr number
---@param d vim.Diagnostic
---@return string
local function format_diagnostic(bufnr, d)
  local markdown = require("codecompanion.utils.markdown")
  local end_lnum = d.end_lnum or d.lnum
  local lines = vim.api.nvim_buf_get_lines(bufnr, d.lnum, end_lnum + 1, false)
  for i, line in ipairs(lines) do
    lines[i] = string.format("%d: %s", d.lnum + i, line)
  end

  local source = d.source and string.format(" (%s%s)", d.source, d.code and " " .. d.code or "") or ""
  return string.format(
    "Line %d [%s]%s: %s\n%s",
    d.lnum + 1,
    severity_names[d.severity] or "UNKNOWN",
    source,
    d.message,
    markdown.form_codeblock(table.concat(lines, "\n"), { ft = vim.bo[bufnr].filetype })
  )
end

---@param opts? { new_chat?: boolean } new_chat forces a fresh chat instead of the last one
function M.send(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = cursor_diagnostics(bufnr)
  if #diagnostics == 0 then
    return vim.notify("No diagnostics on this line", vim.log.levels.INFO)
  end

  local formatted = vim.tbl_map(function(d)
    return format_diagnostic(bufnr, d)
  end, diagnostics)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local path = name ~= "" and vim.fn.fnamemodify(name, ":.") or "[No Name]"
  local content = string.format("Here are LSP diagnostics from %s:\n\n%s\n", path, table.concat(formatted, "\n\n"))

  local codecompanion = require("codecompanion")
  local chat = not opts.new_chat and codecompanion.last_chat() or nil
  if not chat then
    chat = codecompanion.chat({ stop_context_insertion = true })
    if not chat then
      return vim.notify("Could not create CodeCompanion chat", vim.log.levels.WARN)
    end
  end

  chat:add_buf_message({ role = require("codecompanion.config").constants.USER_ROLE, content = content })
  chat.ui:open()
end

return M
