-- Workspace-wide spell checking.
--
-- Neovim's 'spell' is per-buffer, so there is no built-in "show me every typo
-- in the project". This walks the files git knows about, extracts the regions
-- treesitter marks as spell-checkable (@spell minus @nospell, i.e. comments and
-- strings -- exactly what gets underlined in a buffer), runs vim.spell.check()
-- over them and drops the results into the quickfix list.
local M = {}

-- Filetypes to spell check. Shared with the BufWinEnter autocmd in init.lua so
-- the in-buffer highlighting and the workspace search stay in sync.
M.filetypes = {
  "markdown",
  "text",
  "gitcommit",
  "tex",
  "rst",
  "pandoc",
  "asciidoc",
  "org",
  "lua",
  "python",
  "javascript",
  "typescript",
  "typescriptreact",
  "javascriptreact",
  "html",
  "css",
  "json",
  "yaml",
  "xml",
  "sh",
  "zsh",
  "bash",
  "fish",
  "vim",
  "rust",
  "go",
}

-- Prose filetypes get every line checked when treesitter has nothing to say.
-- Code filetypes do not: without @spell captures, checking whole lines flags
-- every identifier and the list becomes useless.
local prose = {
  markdown = true,
  text = true,
  gitcommit = true,
  tex = true,
  rst = true,
  pandoc = true,
  asciidoc = true,
  org = true,
}

local MAX_FILE_SIZE = 512 * 1024

-- Ignore misspellings shorter than this. Short "words" in code are almost always
-- abbreviations, units or variable fragments rather than real typos.
local MIN_WORD_LEN = 4

--- Build a per-line byte mask of the spell-checkable regions in `content`.
--- Returns nil when the language has no parser or no @spell captures.
local function spell_mask(content, lines, lang)
  local ok, parser = pcall(vim.treesitter.get_string_parser, content, lang)
  if not ok or not parser then
    return nil
  end
  if not pcall(parser.parse, parser, true) then
    return nil
  end

  local mask, tagged = {}, false

  local function apply(node, value)
    local srow, scol, erow, ecol = node:range()
    for row = srow, math.min(erow, #lines - 1) do
      local line = lines[row + 1]
      local from = (row == srow) and scol or 0
      local to = (row == erow) and ecol or #line
      local m = mask[row + 1]
      if not m then
        m = {}
        mask[row + 1] = m
      end
      for col = from, math.min(to, #line) - 1 do
        m[col] = value
      end
    end
  end

  -- Walk the main tree and every injected tree; captures arrive parent-first,
  -- so a @nospell nested inside a @spell correctly clears the mask after it.
  local function walk(ltree)
    local query = vim.treesitter.query.get(ltree:lang(), "highlights")
    if query then
      for _, tree in ipairs(ltree:trees()) do
        for id, node in query:iter_captures(tree:root(), content) do
          local name = query.captures[id]
          if name == "spell" then
            tagged = true
            apply(node, true)
          elseif name == "nospell" then
            apply(node, false)
          end
        end
      end
    end
    for _, child in pairs(ltree:children()) do
      walk(child)
    end
  end

  local walked = pcall(walk, parser)
  if not walked or not tagged then
    return nil
  end
  return mask
end

--- Split a line into the maximal runs its mask marks as checkable.
--- Each run is { byte offset (0-indexed), text }.
local function masked_runs(line, m)
  local runs, start = {}, nil
  for col = 0, #line - 1 do
    if m[col] then
      start = start or col
    elseif start then
      runs[#runs + 1] = { start, line:sub(start + 1, col) }
      start = nil
    end
  end
  if start then
    runs[#runs + 1] = { start, line:sub(start + 1) }
  end
  return runs
end

local function check_file(path, items)
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= "file" or stat.size > MAX_FILE_SIZE then
    return
  end

  local ft = vim.filetype.match({ filename = path })
  if not ft or not vim.tbl_contains(M.filetypes, ft) then
    return
  end

  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or type(lines) ~= "table" then
    return
  end

  local content = table.concat(lines, "\n")
  local lang = vim.treesitter.language.get_lang(ft) or ft
  local mask = spell_mask(content, lines, lang)
  if not mask and not prose[ft] then
    return
  end

  for lnum, line in ipairs(lines) do
    local runs
    if mask then
      runs = mask[lnum] and masked_runs(line, mask[lnum]) or {}
    else
      runs = { { 0, line } }
    end
    for _, run in ipairs(runs) do
      local offset, text = run[1], run[2]
      for _, bad in ipairs(vim.spell.check(text)) do
        local word, kind, col = bad[1], bad[2], bad[3]
        if kind == "bad" and vim.fn.strcharlen(word) >= MIN_WORD_LEN then
          items[#items + 1] = {
            filename = path,
            lnum = lnum,
            col = offset + col,
            text = word,
            type = "W",
          }
        end
      end
    end
  end
end

local function list_files(root)
  local git = vim.system(
    { "git", "-C", root, "ls-files", "--cached", "--others", "--exclude-standard" },
    { text = true }
  ):wait()
  if git.code == 0 and git.stdout ~= "" then
    return vim.split(vim.trim(git.stdout), "\n", { plain = true })
  end

  if vim.fn.executable("rg") == 1 then
    local rg = vim.system({ "rg", "--files", "--hidden", "--glob", "!.git" }, { cwd = root, text = true }):wait()
    if rg.code == 0 then
      return vim.split(vim.trim(rg.stdout), "\n", { plain = true })
    end
  end

  return nil
end

--- Collect every misspelling under `root` (default: cwd) into the quickfix
--- list and open it with Telescope.
function M.workspace(root)
  root = root or vim.uv.cwd()

  local files = list_files(root)
  if not files then
    vim.notify("Spell check: could not list files (no git repo and no rg)", vim.log.levels.ERROR)
    return
  end

  -- vim.spell.check() reads 'spelllang'/'spelloptions' from the current buffer,
  -- and returns nothing at all while 'spell' is off in the current window.
  local spell = vim.wo.spell
  vim.wo.spell = true

  local items = {}
  local ok, err = pcall(function()
    for _, name in ipairs(files) do
      check_file(vim.fs.joinpath(root, name), items)
    end
  end)

  vim.wo.spell = spell

  if not ok then
    vim.notify("Spell check failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  if #items == 0 then
    vim.notify("Spell check: no misspellings found")
    return
  end

  vim.fn.setqflist({}, " ", { title = "Spelling (" .. #items .. ")", items = items })
  require("telescope.builtin").quickfix()
end

return M
