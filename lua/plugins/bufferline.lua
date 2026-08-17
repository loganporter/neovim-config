return {
  'akinsho/bufferline.nvim',
  version = "*",
  event = "VeryLazy",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  -- The colorscheme used to be applied from here, which made the whole theme
  -- contingent on bufferline loading. It now lives in colorscheme.lua.
  opts = {},
}
