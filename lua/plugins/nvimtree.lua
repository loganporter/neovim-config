return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup(
      {
        filters = {
          dotfiles = false,
          git_ignored = false
        }
      }
    )
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {
      desc = 'Toggle file explorer'
    })
  end
}
