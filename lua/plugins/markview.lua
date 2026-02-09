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
          if vim.bo[buffer].filetype == 'codecompanion' then
            return true
          end
        end,
      },
    })
  end,
}
