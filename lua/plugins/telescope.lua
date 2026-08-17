return {
  'nvim-telescope/telescope.nvim',
  -- Tracking master rather than the 0.1.8 tag. 0.1.8's treesitter previewer
  -- called nvim-treesitter's `parsers.ft_to_lang` / `configs.is_enabled`, which
  -- the `main` branch deleted -- so previews had to be downgraded to Vim regex
  -- syntax. Master now uses core `vim.treesitter.language.get_lang` +
  -- `vim.treesitter.start`, so treesitter previews work again.
  branch = 'master',
  cmd = 'Telescope',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Native C sorter. Telescope's default sorter is pure Lua and gets
    -- noticeably sluggish filtering large result sets (find_files/live_grep in
    -- a big repo). Built locally with `make`, so it needs a C compiler --
    -- `cc` ships with the Xcode command line tools.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      -- Skip loading (rather than erroring) if the build didn't produce the
      -- shared object, e.g. on a machine without a compiler.
      cond = function()
        return vim.fn.executable('make') == 1
      end,
    },
  },
  opts = {
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        -- "smart_case": case-insensitive unless the pattern has a capital,
        -- matching the ignorecase/smartcase pair set in init.lua.
        case_mode = 'smart_case',
      },
    },
  },
  config = function(_, opts)
    require('telescope').setup(opts)
    -- Must come after setup(); load_extension is what swaps the sorters in.
    pcall(require('telescope').load_extension, 'fzf')
  end,
}
