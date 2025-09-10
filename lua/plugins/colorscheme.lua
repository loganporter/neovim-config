return {
  "Mofiqul/vscode.nvim",
  priority = 1000,           -- Ensure this colorscheme is loaded first
  lazy = false,              -- Load this colorscheme immediately
  opts = {
    terminal_colors = false, -- Disable terminal colors
    group_overrides = {
      -- Override specific highlight groups
      NormalFloat = { bg = "#000000" },
      Pmenu = { bg = "#000000" },
      -- Override here is for git graph
      DiffDelete = { fg = "#444444", bg = "NONE" },
      DiffRemoved = { fg = "#444444", bg = "NONE" },
    },
  }
}
