return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8', -- or, branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup({
      defaults = {
        -- nvim-treesitter `main` removed parsers.ft_to_lang / configs.is_enabled,
        -- which Telescope 0.1.8's treesitter previewer relies on. Disable it so
        -- previews fall back to Vim regex `syntax` highlighting instead of erroring.
        preview = { treesitter = false },
      },
    })
  end
}
