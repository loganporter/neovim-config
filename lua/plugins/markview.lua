return {
  'OXY2DEV/markview.nvim',
  ft = { 'markdown', 'codecompanion' },
  lazy = false,
  config = function()
    require('markview').setup({
      preview = {
        enable = true,
        filetypes = { 'markdown', 'codecompanion' },
        condition = function(buffer)
          local ft = vim.bo[buffer].filetype
          return ft == 'markdown' or ft == 'codecompanion'
        end,
      },
    })
  end,
}
