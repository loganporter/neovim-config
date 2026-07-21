return {
  "Mofiqul/vscode.nvim",
  priority = 1000,           -- Ensure this colorscheme is loaded first
  lazy = false,              -- Load this colorscheme immediately
  opts = {
    terminal_colors = false, -- Disable terminal colours
    -- Darken the theme's grey backgrounds. These override the base palette
    -- (vscode.nvim's dark defaults are in the ~#1F–#2D range) so the shift
    -- cascades to every derived group: editor, tabs, nvim-tree sidebar,
    -- popups and the cursorline. The terminal stays pure black via the
    -- separate `TerminalNormal` group in lua/config/autocmds.lua.
    color_overrides = {
      vscBack = "#141414",          -- main editor background
      vscTabCurrent = "#141414",    -- active buffer/tab
      vscTabOther = "#242424",      -- inactive buffers/tabs
      vscTabOutside = "#1a1a1a",    -- bufferline background
      vscLeftDark = "#1a1a1a",      -- nvim-tree / sidebar background
      vscPopupBack = "#161616",     -- completion / popup menu background
      vscCursorDarkDark = "#1a1a1a", -- cursorline
    },
    group_overrides = {
      -- Override specific highlight groups
      NormalFloat = { bg = "#000000" },
      Pmenu = { bg = "#000000" },
      -- Terminal windows get a pure black background. The definition lives
      -- here alongside the other background colours; lua/config/autocmds.lua
      -- applies it per-window via `winhighlight` when a terminal is shown.
      TerminalNormal = { bg = "#000000" },
      -- Spell check overrides. Only underline genuine misspellings
      -- (SpellBad). SpellRare/SpellLocal fire on valid-but-uncommon or
      -- other-region words (e.g. US spellings under en_nz) and SpellCap on
      -- capitalisation; clearing them stops the blue underlines on technical
      -- terms while keeping real misspellings flagged.
      SpellBad = { undercurl = true, sp = "#5c82bf" },
      SpellRare = {},
      SpellLocal = {},
      SpellCap = {},
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
      -- Diffview background overrides
      DiffAdd = { bg = "#103010" },
      DiffChange = { bg = "#101525" },
      DiffText = { bg = "#4d0000" },
      DiffDelete = { bg = "#4d0000" },
      -- keep the filler background the same as the default background
      DiffviewDiffDeleteDim = { fg = "#444444", bg = "NONE" },
    },
  }
}
