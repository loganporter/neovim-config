return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local codecompanion_lualine = require("config.lualine_codecompanion")

    require("lualine").setup({
      options = {
        theme = "vscode",
        refresh = {
          statusline = 80,
        },
      },
      sections = {
        lualine_x = { codecompanion_lualine, "diagnostics", "encoding", "fileformat", "filetype" }
      }
    })
  end
}
