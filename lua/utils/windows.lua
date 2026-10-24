-- Split resizing helpers for the window keymaps in config.keymaps.
local M = {}

-- always move the divider left/right regardless of which pane is focused
function M.move_divider(dir, amount)
  local has_right = vim.fn.winnr("l") ~= vim.fn.winnr()
  -- moving right: grow current if it has a right neighbor, else shrink it (moves its left divider right)
  -- moving left: mirror of the above
  local sign = (dir == "right") == has_right and "+" or "-"
  vim.cmd("vertical resize " .. sign .. amount)
end

-- Maximize the current window's width, leaving the sidebars at their own width.
-- Bare <C-w>| takes its space from every other window, which squashes NvimTree
-- (and the symbols-outline / diffview panels) down to a sliver. Those windows
-- all set 'winfixwidth' -- which <C-w>= honours but an explicit resize does not
-- -- so restoring exactly those to the width they had gives their space back and
-- takes it out of the maximized window instead.
-- Deliberately under NvimTree's 30 columns: enough of the neighbouring split to
-- read a line's worth of context, still clearly the subordinate pane.
local MAXIMIZE_MIN_WIDTH = 20
function M.maximize_width()
  local current = vim.api.nvim_get_current_win()
  -- Maximizing a sidebar is a one-way trip: <leader>= honours 'winfixwidth', so
  -- it won't shrink the pane back afterwards and you're left with a 150-column
  -- file tree. The keymap is for code splits.
  if vim.wo[current].winfixwidth then
    vim.notify("Not maximizing a fixed-width sidebar", vim.log.levels.INFO)
    return
  end
  local sidebars = {}
  -- the columns <C-w>| actually redistributes, and how many windows besides the
  -- current one are competing for them
  local budget, others = 0, 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- floats sit outside the split layout, so they neither lose width to
    -- <C-w>| nor should be resized here
    local floating = vim.api.nvim_win_get_config(win).relative ~= ""
    if not floating then
      if win ~= current and vim.wo[win].winfixwidth then
        sidebars[#sidebars + 1] = { win = win, width = vim.api.nvim_win_get_width(win) }
      else
        budget = budget + vim.api.nvim_win_get_width(win)
        others = others + (win ~= current and 1 or 0)
      end
    end
  end

  -- A narrow terminal may not have room to give every other split the full
  -- minimum -- vim then prints E36 and leaves the layout half-resized. Capping
  -- at an equal share keeps it satisfiable, and is no loss: an equal share is
  -- what <leader>= would hand out anyway.
  local min_width = MAXIMIZE_MIN_WIDTH
  if others > 0 then
    min_width = math.max(1, math.min(min_width, math.floor(budget / (others + 1))))
  end

  -- 'winminwidth' is a hard floor for every window that isn't the current one,
  -- so <C-w>| stops short of squashing the others to a single column. Set only
  -- for the resize -- left on, it would also block <A-h>/<A-l> from dragging a
  -- divider past that point. 'winwidth' has to move with it: vim rejects a
  -- 'winminwidth' above it (E592).
  local saved_min, saved_win = vim.o.winminwidth, vim.o.winwidth
  vim.o.winwidth = math.max(saved_win, min_width)
  vim.o.winminwidth = min_width
  local ok = pcall(vim.cmd, "wincmd |")
  vim.o.winminwidth = saved_min
  vim.o.winwidth = saved_win
  if not ok then
    vim.cmd("wincmd |")
  end

  for _, sidebar in ipairs(sidebars) do
    if vim.api.nvim_win_is_valid(sidebar.win) then
      vim.api.nvim_win_set_width(sidebar.win, sidebar.width)
    end
  end
end

return M
