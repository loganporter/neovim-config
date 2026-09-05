-- Desktop notifications for CodeCompanion chats.
--
-- Fires at every point where a chat hands control back to us: the end of a turn
-- (`CodeCompanionChatDone`) and whenever a tool blocks on an approval or a
-- question. Notifications are skipped when we're demonstrably already looking
-- at that chat, i.e. Neovim has terminal focus and the chat is the current
-- buffer.
--
-- Delivery prefers OSC 777, an escape sequence the terminal itself turns into a
-- native notification (so it also works over SSH). Ghostty, WezTerm and foot
-- speak it; anything else falls back to `terminal-notifier`, `osascript`
-- (macOS) or `notify-send` (Linux).

local M = {}

local opts = {
  enabled = true,
  -- Notify even when the chat buffer is focused in front of us.
  always = false,
  title = "CodeCompanion",
}

local focused = true

---Neovim's stderr is wired to the terminal, so it's where escape sequences go
---@param seq string
local function write_term(seq)
  vim.fn.chansend(vim.v.stderr, seq)
end

---OSC 777 is `;`-delimited and can't carry control characters
---@param s string
---@return string
local function sanitize(s)
  return (s:gsub("%c", " "):gsub(";", ","))
end

local function osc777_terminal()
  local term = (vim.env.TERM_PROGRAM or ""):lower() .. " " .. (vim.env.TERM or ""):lower()
  return term:find("ghostty", 1, true) ~= nil
    or term:find("wezterm", 1, true) ~= nil
    or term:find("foot", 1, true) ~= nil
end

---Resolve the delivery backend once, on first use
---@type fun(title: string, body: string)|nil
local backend

local function resolve_backend()
  if osc777_terminal() then
    return function(title, body)
      write_term(("\027]777;notify;%s;%s\007"):format(sanitize(title), sanitize(body)))
    end
  end

  if vim.fn.executable("terminal-notifier") == 1 then
    return function(title, body)
      vim.system({ "terminal-notifier", "-title", title, "-message", body })
    end
  end

  if vim.fn.has("mac") == 1 then
    return function(title, body)
      local function quote(s)
        return '"' .. s:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
      end
      vim.system({
        "osascript",
        "-e",
        ("display notification %s with title %s"):format(quote(body), quote(title)),
      })
    end
  end

  if vim.fn.executable("notify-send") == 1 then
    return function(title, body)
      vim.system({ "notify-send", title, body })
    end
  end

  return function(_, body)
    vim.notify(body, vim.log.levels.INFO, { title = opts.title })
  end
end

---@param bufnr number|nil the chat buffer the event came from
---@return boolean
local function watching(bufnr)
  return focused and bufnr ~= nil and vim.api.nvim_get_current_buf() == bufnr
end

---@param body string
---@param bufnr number|nil
local function notify(body, bufnr)
  if not opts.enabled or (watching(bufnr) and not opts.always) then
    return
  end

  backend = backend or resolve_backend()

  local project = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  backend(("%s (%s)"):format(opts.title, project), body)
end

---@param user_opts table|nil
function M.setup(user_opts)
  opts = vim.tbl_extend("force", opts, user_opts or {})

  local group = vim.api.nvim_create_augroup("CodeCompanionDesktopNotify", { clear = true })

  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      focused = true
    end,
  })
  vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = function()
      focused = false
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeCompanionChatDone",
    callback = function(args)
      notify("Response ready", (args.data or {}).bufnr)
    end,
    desc = "Desktop notification when a CodeCompanion chat finishes its turn",
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeCompanionToolApprovalRequested",
    callback = function(args)
      local data = args.data or {}
      notify(data.name and ("Approval needed: " .. data.name) or "Approval needed", data.bufnr)
    end,
    desc = "Desktop notification when a CodeCompanion tool needs approval",
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeCompanionToolQuestionAsked",
    callback = function(args)
      local data = args.data or {}
      notify(data.header and ("Question: " .. data.header) or "Question asked", data.bufnr)
    end,
    desc = "Desktop notification when a CodeCompanion tool asks a question",
  })
end

return M
