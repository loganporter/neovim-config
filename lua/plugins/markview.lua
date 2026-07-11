return {
  'OXY2DEV/markview.nvim',
  ft = { 'markdown', 'codecompanion' },
  lazy = false,
  config = function()
    require('markview').setup({
      preview = {
        enable = true,
        filetypes = { 'markdown', 'codecompanion' },
        map_gx = false,
        condition = function(buffer)
          local ft = vim.bo[buffer].filetype
          return ft == 'markdown' or ft == 'codecompanion'
        end,
      },
      markdown = {
        -- Render table borders as dedicated virtual lines instead of overlaying
        -- them onto adjacent buffer lines. The default (false) breaks in
        -- codecompanion chat buffers, where the neighbouring lines aren't laid
        -- out the way markview expects, so table borders render misaligned.
        tables = {
          use_virt_lines = true,
        },
      },
    })
  end,
}
