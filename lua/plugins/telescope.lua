return {
  'nvim-telescope/telescope.nvim',
  -- Tracking master rather than the 0.1.8 tag. 0.1.8's treesitter previewer
  -- called nvim-treesitter's `parsers.ft_to_lang` / `configs.is_enabled`, which
  -- the `main` branch deleted -- so previews had to be downgraded to Vim regex
  -- syntax. Master now uses core `vim.treesitter.language.get_lang` +
  -- `vim.treesitter.start`, so treesitter previews work again.
  branch = 'master',
  cmd = 'Telescope',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
}
