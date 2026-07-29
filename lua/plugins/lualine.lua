return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local codecompanion_lualine = require("config.lualine_codecompanion")

    require("lualine").setup({
      options = {
        theme = "vscode",
        refresh = {
          statusline = 120,
        },
      },
      sections = {
        lualine_c = {
          {
            "filename",
            path = 1, -- 0=name, 1=relative, 2=absolute, 3=absolute+~, 4=name+parent
            symbols = {
              modified = "[+]",
              readonly = "[-]",
              unnamed = "[No Name]",
            },
          },
        },
        lualine_x = { codecompanion_lualine, "diagnostics", "encoding", "fileformat", "filetype" }
      },
      inactive_sections = {
        lualine_c = {
          {
            "filename",
            path = 1, -- 0=name, 1=relative, 2=absolute, 3=absolute+~, 4=name+parent
            symbols = {
              modified = "[+]",
              readonly = "[-]",
              unnamed = "[No Name]",
            },
          },
        },
      }
    })
  end
}
