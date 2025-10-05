return {
  "Mofiqul/vscode.nvim",
  priority = 1000,           -- Ensure this colorscheme is loaded first
  lazy = false,              -- Load this colorscheme immediately
  opts = {
    terminal_colors = false, -- Disable terminal colours
    group_overrides = {
      -- Override specific highlight groups
      NormalFloat = { bg = "#000000" },
      Pmenu = { bg = "#000000" },
      -- Spell check overrides
      SpellBad = { undercurl = true, sp = "#5c82bf" },
      -- Override here is for git graph
      DiffDelete = { fg = "#444444", bg = "NONE" },
      DiffRemoved = { fg = "#444444", bg = "NONE" },
      -- GitGraph highlight groups
      GitGraphHash = { fg = "#6c757d" },
      GitGraphTimestamp = { fg = "#adb5bd" },
      GitGraphAuthor = { fg = "#82aaff" },
      GitGraphBranchName = { fg = "#93f88d" },
      GitGraphBranchTag = { fg = "#00aaff" },
      GitGraphBranchMsg = { fg = "#f2d994" },
      GitGraphBranch1 = { fg = "#66c2a5" },
      GitGraphBranch2 = { fg = "#fc8d62" },
      GitGraphBranch3 = { fg = "#b39ddb" },
      GitGraphBranch4 = { fg = "#64b5f6" },
      GitGraphBranch5 = { fg = "#e5c07b" },
    },
  }
}
