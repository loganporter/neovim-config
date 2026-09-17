-- resterm (https://github.com/unkn0wn-root/resterm) in a floating terminal.
--
-- resterm is a standalone Go TUI, not a Neovim plugin, so this is the same
-- shape as the lazygit integration: run the binary in a float, hand it the
-- right context (workspace + current file), and put the editor back the way it
-- was when it exits.
--
-- The one thing lazygit doesn't need: resterm is itself an editor of the
-- .http/.rest files in your tree, so a session is long-lived and worth keeping
-- alive. <leader>rr therefore *hides* the float rather than killing the
-- process, and re-showing it drops you back into the same requests, history
-- and response panes. Use :Resterm! (<leader>rk) to actually restart it.
local M = {}

-- The running instance. `buf` outlives `win` -- hiding closes the window and
-- leaves the terminal buffer (and the resterm process) alone.
local state = {
  buf = nil,
  win = nil,
  job = nil,
  workspace = nil,
  prev_win = nil,
}

-- resterm looks for an environment file in exactly three places: the opened
-- file's directory, the workspace root, and the CWD. It never searches upward,
-- so pointing it at the wrong directory silently loses your {{variables}}.
local ENV_FILES = { "resterm.env.json", "rest-client.env.json" }

-- How far below the project root to look for a requests directory holding its
-- own environment file. Bounded because an unbounded vim.fs.find over a
-- monorepo takes over a second; three levels costs 1-3ms.
local ENV_SEARCH_DEPTH = 3

local REQUEST_EXTENSIONS = { http = true, rest = true }

-- Credentials a request file references as `env:NAME` come from resterm's own
-- environment, and resterm never looks for a dotenv unless told to. Launched
-- from here, that environment is whatever nvim was started with -- so a key
-- kept in the workspace's `.env` would be missing inside the float. These are
-- loaded at start instead, and go only to the resterm job: they are not put on
-- `vim.env`, so no language server or other job ever sees them.
local DOTENV_FILES = { ".env", ".env.local" }

--- Read `KEY=value` pairs from the workspace's dotenv files.
---
--- Deliberately plain: `export` prefixes, `#` comments and surrounding quotes
--- are handled, `${VAR}` interpolation is not. The first file to define a key
--- wins, and an already-exported value beats both -- the precedence every
--- other dotenv loader uses, so a key exported for one session still overrides
--- the file.
---@param dir string workspace root
---@return table<string, string>
local function read_dotenv(dir)
  local vars = {}
  for _, name in ipairs(DOTENV_FILES) do
    local fd = io.open(vim.fs.joinpath(dir, name), "r")
    if fd then
      for line in fd:lines() do
        local key, value = line:gsub("^%s*export%s+", ""):match("^([%a_][%w_]*)%s*=%s*(.-)%s*$")
        if key and vars[key] == nil and os.getenv(key) == nil then
          local quoted = value:match('^"(.*)"$') or value:match("^'(.*)'$")
          vars[key] = quoted or (value:gsub("%s+#.*$", ""))
        end
      end
      fd:close()
    end
  end
  return vars
end

--- Path to the shim handed to resterm as $EDITOR, so its `g e` opens the file
--- back in *this* nvim instead of spawning a nested one inside the float.
local function editor_shim()
  local path = vim.fs.joinpath(vim.fn.stdpath("config"), "resterm", "nvim-editor.sh")
  if vim.fn.executable(path) == 1 then
    return path
  end
  return nil
end

--- The .http/.rest file to open, if the current buffer is one.
---@return string|nil
local function current_request_file()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" or name:find("://") then
    return nil
  end
  if not REQUEST_EXTENSIONS[vim.fn.fnamemodify(name, ":e")] then
    return nil
  end
  return vim.fn.fnamemodify(name, ":p")
end

local function has_env(dir)
  for _, file in ipairs(ENV_FILES) do
    if vim.uv.fs_stat(vim.fs.joinpath(dir, file)) then
      return true
    end
  end
  return false
end

--- Shallowest directory below `root` holding an environment file.
---
--- Nil when there is none, and also when two sit at the same depth: resterm
--- loads one environment file per workspace and warns about the rest, so
--- guessing between them would be worse than leaving the root alone.
---@return string|nil
local function env_dir_below(root)
  local best, best_depth, tied
  for name, type_ in vim.fs.dir(root, {
    depth = ENV_SEARCH_DEPTH,
    skip = function(dir) return dir ~= "node_modules" and dir:sub(1, 1) ~= "." end,
  }) do
    if type_ == "file" and vim.tbl_contains(ENV_FILES, vim.fs.basename(name)) then
      local dir = vim.fs.dirname(vim.fs.joinpath(root, name))
      local depth = select(2, name:gsub("/", ""))
      if best_depth == nil or depth < best_depth then
        best, best_depth, tied = dir, depth, false
      elseif depth == best_depth and dir ~= best then
        tied = true
      end
    end
  end
  return not tied and best or nil
end

--- Workspace root for the current buffer.
---
--- resterm resolves one environment file per workspace, so the root has to be
--- the directory holding it. Nearest ancestor wins; failing that the project
--- root, unless the requests live in a subdirectory below it with their own
--- environment -- the usual monorepo shape, and one no upward walk can find.
local function workspace_root()
  local name = vim.api.nvim_buf_get_name(0)
  local dir = (name ~= "" and not name:find("://")) and vim.fs.dirname(name) or vim.fn.getcwd()

  local env_root = vim.fs.root(dir, ENV_FILES)
  if env_root then
    return env_root
  end

  local root = vim.fs.root(dir, { ".git" }) or vim.fn.getcwd()
  if has_env(root) then
    return root
  end
  return env_dir_below(root) or root
end

local function open_float(buf)
  local width = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines * 0.92)
  return vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " resterm ",
    title_pos = "center",
  })
end

local function is_win_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function is_running()
  return state.buf ~= nil and vim.api.nvim_buf_is_valid(state.buf) and state.job ~= nil
end

--- Return focus to wherever we came from, and if that was a terminal, put it
--- back in normal mode rather than dropping the user into terminal input.
local function restore_focus()
  local prev = state.prev_win
  state.prev_win = nil
  if prev and vim.api.nvim_win_is_valid(prev) then
    vim.api.nvim_set_current_win(prev)
  end
  if vim.bo.buftype == "terminal" then
    vim.schedule(function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
    end)
  end
end

--- Buffer-local keys for the float. Deliberately sparse: resterm is a modal
--- editor that claims nearly every key, so only <C-q> (unused by resterm) is
--- taken from terminal mode.
local function set_keymaps(buf)
  vim.keymap.set("t", "<C-q>", function()
    M.hide()
  end, { buffer = buf, desc = "Hide resterm (keep it running)" })
  vim.keymap.set("n", "q", function()
    M.hide()
  end, { buffer = buf, desc = "Hide resterm (keep it running)" })
end

--- Close the float but leave the resterm process running.
function M.hide()
  if not is_win_open() then
    return
  end
  local win = state.win
  state.win = nil
  vim.api.nvim_win_close(win, true)
  restore_focus()
end

--- Re-show the running instance, or start one if there isn't one.
function M.show()
  if is_win_open() then
    vim.api.nvim_set_current_win(state.win)
    vim.cmd("startinsert")
    return
  end
  if not is_running() then
    return M.open()
  end
  state.prev_win = vim.api.nvim_get_current_win()
  state.win = open_float(state.buf)
  vim.cmd("startinsert")
end

--- Start a fresh resterm process in a float.
---@param opts? { file: string|nil, workspace: string|nil }
local function start(opts)
  opts = opts or {}
  local workspace = opts.workspace or workspace_root()

  state.prev_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  state.buf = buf
  state.workspace = workspace
  state.win = open_float(buf)

  -- --recursive: the workspace scan is flat by default, so requests kept in
  -- subdirectories never reach the sidebar.
  local cmd = { "resterm", "--recursive", "--workspace", workspace }
  if opts.file then
    vim.list_extend(cmd, { "--file", opts.file })
  end

  local env = read_dotenv(workspace)
  local shim = editor_shim()
  if shim then
    env.EDITOR = shim
    env.VISUAL = shim
  end

  state.job = vim.fn.jobstart(cmd, {
    term = true,
    cwd = workspace,
    env = env,
    on_exit = function()
      -- A restart stops this job and starts the next one straight away, so this
      -- callback can land once `state` already describes the new session. Only
      -- tear down the session this closure was created for.
      if state.buf ~= buf then
        vim.cmd("checktime")
        return
      end
      state.job = nil
      if is_win_open() then
        local win = state.win
        state.win = nil
        vim.api.nvim_win_close(win, true)
        restore_focus()
      end
      if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        vim.api.nvim_buf_delete(state.buf, { force = true })
      end
      state.buf = nil
      -- resterm writes the .http files it edits, so pull those changes into
      -- any buffer we already have open on them.
      vim.cmd("checktime")
    end,
  })

  if state.job <= 0 then
    vim.notify("Failed to start resterm", vim.log.levels.ERROR)
    return
  end

  set_keymaps(buf)
  vim.cmd("startinsert")
end

--- Open resterm, reusing the running instance if there is one.
---@param opts? { file: string|nil, workspace: string|nil, restart: boolean|nil }
function M.open(opts)
  opts = opts or {}

  if vim.fn.executable("resterm") == 0 then
    vim.notify("resterm not found on $PATH (brew install resterm)", vim.log.levels.ERROR)
    return
  end

  if opts.restart and is_running() then
    M.kill()
  elseif is_running() then
    -- A live session holds unsaved editor state, history and captured globals;
    -- silently restarting it to honour a new --file would throw that away.
    -- Use resterm's own Ctrl+O file popup to move around inside the workspace.
    return M.show()
  end

  start(opts)
end

--- Quit the running instance and open a clean one in its place. Unlike
--- `hide`/`toggle`, this deliberately drops the session's editor state,
--- history and captured globals -- that is the point of asking for a fresh one.
function M.restart()
  M.open({ restart = true })
end

--- Toggle the float. Hides rather than quits -- see the note at the top.
function M.toggle()
  if is_win_open() then
    return M.hide()
  end
  M.open()
end

--- Open resterm focused on the current buffer's .http/.rest file.
function M.open_current_file()
  local file = current_request_file()
  if not file then
    vim.notify("Current buffer is not a .http/.rest file", vim.log.levels.WARN)
    return M.open()
  end
  M.open({ file = file, restart = true })
end

--- Open `file` in this nvim on behalf of resterm's `g e`, and unblock the
--- shim (by creating `sentinel`) once the user is done with it.
---
--- Neovim doesn't implement `--remote-wait` (E5600), so the "editor blocks
--- until the file is closed" contract resterm expects is rebuilt here: the
--- float is hidden, the file opens in the window resterm was launched from,
--- and closing that buffer writes it, drops the sentinel and brings the float
--- back. Called over RPC -- see resterm/nvim-editor.sh.
---@param file string
---@param sentinel string path the shim is polling for
function M.edit(file, sentinel)
  local target = state.prev_win
  M.hide()
  if target and vim.api.nvim_win_is_valid(target) then
    vim.api.nvim_set_current_win(target)
  end
  vim.cmd("edit " .. vim.fn.fnameescape(file))

  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_create_autocmd({ "BufWinLeave", "BufUnload" }, {
    buffer = buf,
    once = true,
    callback = function()
      -- resterm re-reads the file from disk once the editor returns, so the
      -- write has to happen before the sentinel appears.
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
        pcall(vim.api.nvim_buf_call, buf, function()
          vim.cmd("silent! write")
        end)
      end
      local fd = io.open(sentinel, "w")
      if fd then
        fd:write("done")
        fd:close()
      end
      vim.schedule(function()
        M.show()
      end)
    end,
  })
  return ""
end

--- Terminate the running instance.
function M.kill()
  if state.job then
    vim.fn.jobstop(state.job)
    state.job = nil
  end
  if is_win_open() then
    local win = state.win
    state.win = nil
    pcall(vim.api.nvim_win_close, win, true)
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end
  state.buf = nil
end

-- Keep `state.win` honest when the float is closed by something other than us
-- (:q, :only, a window-closing plugin).
vim.api.nvim_create_autocmd("WinClosed", {
  group = vim.api.nvim_create_augroup("resterm_win", { clear = true }),
  callback = function(args)
    if state.win and tonumber(args.match) == state.win then
      state.win = nil
    end
  end,
})

vim.api.nvim_create_user_command("Resterm", function(args)
  M.open({ workspace = args.args ~= "" and vim.fn.fnamemodify(args.args, ":p") or nil, restart = args.bang })
end, { nargs = "?", bang = true, complete = "dir", desc = "Open resterm (! restarts a running session)" })

vim.api.nvim_create_user_command("RestermFile", function()
  M.open_current_file()
end, { desc = "Open resterm on the current .http/.rest file" })

vim.api.nvim_create_user_command("RestermRestart", function()
  M.restart()
end, { desc = "Quit the running resterm session and start a fresh one" })

vim.api.nvim_create_user_command("RestermToggle", function()
  M.toggle()
end, { desc = "Toggle the resterm float" })

return M
