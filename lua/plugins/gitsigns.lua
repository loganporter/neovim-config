return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      current_line_blame = true,
      -- Gitsigns runs its own CursorMoved timer for blame rather than using
      -- 'updatetime'/CursorHold, so this is the knob that controls how long
      -- after the cursor settles the blame text appears. Pinned rather than
      -- left to gitsigns' default (currently also 1000) so the intent is
      -- explicit here.
      current_line_blame_opts = {
        delay = 1000,
      },
      preview_config = {
        border = { " ", " ", " ", " ", " ", " ", " ", " " },
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    })
  end
}
