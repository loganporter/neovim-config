return {
  'RRethy/vim-illuminate',
  config = function()
    require("illuminate").configure({
      filetypes_denylist = { "sh", "bash", "zsh" },
    })
  end
}
