return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'Mofiqul/vscode.nvim',
  },
  config = function()
    vim.cmd.colorscheme("vscode")
    vim.opt.termguicolors = true
    require('bufferline').setup {}
  end
}
