return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    vim.opt.fillchars:append { diff = "╱" }
    require("diffview").setup({
      enhanced_diff_hl = true,
    })

    -- Added and deleted files have nothing on one side: diffview fills that
    -- window with its `diffview://null` buffer. A 50/50 split then wastes half
    -- the screen on emptiness, so squash the null side down to a sliver and
    -- give the rest to the side that actually has content.
    --
    -- Columns of diagonal fill to keep visible on the null side. This is text
    -- area only: the number, sign and fold columns are measured per window and
    -- added on top, because a width that fits inside the gutter leaves nothing
    -- for the diagonals to draw in.
    local NULL_SLASHES = 14

    local function is_null_win(winid)
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(winid))
      return name:match("diffview://null$") ~= nil
    end

    local function null_width(winid)
      local info = vim.fn.getwininfo(winid)[1]
      return NULL_SLASHES + (info and info.textoff or 0)
    end

    local function balance_diff_wins()
      local diff_wins = {}

      for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        -- The file panel isn't a diff window, so it drops out here -- and it's
        -- 'winfixwidth' anyway, so resizing can't steal columns from it.
        if vim.wo[winid].diff then
          diff_wins[#diff_wins + 1] = winid
        end
      end

      -- Only the plain two-way layout. The three-way merge tool has its own
      -- arrangement, and a null side there is meaningful.
      if #diff_wins ~= 2 then
        return
      end

      local a, b = diff_wins[1], diff_wins[2]
      local total = vim.api.nvim_win_get_width(a) + vim.api.nvim_win_get_width(b)

      if is_null_win(a) then
        vim.api.nvim_win_set_width(a, null_width(a))
      elseif is_null_win(b) then
        vim.api.nvim_win_set_width(b, null_width(b))
      else
        -- Back on a modified file: undo any squashing left over from the
        -- previous entry, since diffview won't re-equalise on its own.
        vim.api.nvim_win_set_width(a, math.floor(total / 2))
      end
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = { "DiffviewDiffBufWinEnter", "DiffviewViewPostLayout" },
      callback = function()
        vim.schedule(balance_diff_wins)
      end,
    })

    -- Close the Diffview tab automatically when you leave it, so you don't
    -- end up with stale Diffview tabs stacking up.
    vim.api.nvim_create_autocmd("User", {
      pattern = "DiffviewViewLeave",
      callback = function()
        vim.schedule(function()
          require("diffview").close()
        end)
      end,
    })
  end,
}
