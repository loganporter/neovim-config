return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    vim.opt.fillchars:append { diff = "╱" }
    require("diffview").setup({})
  end,
}
