-- Per-buffer detection of which JS/TS toolchain a project uses.
--
-- This used to be done with a single `vim.fn.getcwd()` check at startup in
-- conform, nvim-lint and lsp, which meant the whole session was locked to
-- whatever directory nvim happened to launch from: open nvim at a monorepo
-- root (or from ~) and every buffer got the wrong formatter, linter and
-- language server, with no way to correct it short of restarting.
--
-- Instead we search upward from each *buffer's own file* for the marker files,
-- so a Biome package and an ESLint package in the same session each get the
-- right tools. Results are memoised per directory because these run on every
-- format and on every InsertLeave.
local M = {}

M.biome_markers = { "biome.json", "biome.jsonc" }

M.eslint_markers = {
  ".eslintrc",
  ".eslintrc.json",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
}

-- cache[marker_key][dir] = root path or false (false = searched, not found)
local cache = {}

--- Directory to start the upward search from for `bufnr`.
--- Falls back to the cwd for unnamed buffers, which have no path to walk up.
local function buf_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  if name == "" or name:find("://") then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(name)
end

--- Nearest ancestor directory of `bufnr`'s file containing one of `markers`.
---@return string|nil
local function find_root(bufnr, key, markers)
  local dir = buf_dir(bufnr)
  local by_dir = cache[key]
  if not by_dir then
    by_dir = {}
    cache[key] = by_dir
  end
  local hit = by_dir[dir]
  if hit ~= nil then
    return hit or nil
  end
  local root = vim.fs.root(dir, markers)
  by_dir[dir] = root or false
  return root
end

---@return string|nil root directory of the nearest Biome project
function M.biome_root(bufnr)
  return find_root(bufnr, "biome", M.biome_markers)
end

---@return string|nil root directory of the nearest ESLint project
function M.eslint_root(bufnr)
  return find_root(bufnr, "eslint", M.eslint_markers)
end

function M.uses_biome(bufnr)
  return M.biome_root(bufnr) ~= nil
end

function M.uses_eslint(bufnr)
  return M.eslint_root(bufnr) ~= nil
end

--- Locate an executable for `name`, preferring the copy installed in the
--- nearest `node_modules/.bin` above this buffer's file and falling back to
--- $PATH. Returns nil when neither exists.
---
--- nvim-lint's own resolution does `./node_modules/.bin/<name>` relative to the
--- *cwd*, so in a monorepo (or any time nvim wasn't started in the package
--- directory) it misses the local install and falls back to a bare `eslint`,
--- which usually isn't on $PATH at all -- raising ENOENT on every lint pass.
---@return string|nil
function M.node_bin(bufnr, name)
  local dir = buf_dir(bufnr)
  for _, d in ipairs(vim.list_extend({ dir }, vim.iter(vim.fs.parents(dir)):totable())) do
    local candidate = vim.fs.joinpath(d, "node_modules", ".bin", name)
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  if vim.fn.executable(name) == 1 then
    return name
  end
  return nil
end

--- Drop memoised results. Config files can be added/removed while nvim is
--- running (branch switch, fresh `npm init`), so give ourselves an escape hatch.
function M.clear_cache()
  cache = {}
end

vim.api.nvim_create_user_command("ProjectToolsRefresh", function()
  M.clear_cache()
  vim.notify("Project tool detection cache cleared", vim.log.levels.INFO)
end, { desc = "Re-detect Biome/ESLint config files" })

return M
