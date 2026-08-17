return {
  'RRethy/vim-illuminate',
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("illuminate").configure({
      filetypes_denylist = { "sh", "bash", "zsh" },
    })
  end
}
