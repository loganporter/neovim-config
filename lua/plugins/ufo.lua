return {
  "kevinhwang91/nvim-ufo",
  dependencies = "kevinhwang91/promise-async",
  config = function()
    require("ufo").setup({
      provider_selector = function(bufnr, filetype, buftype)
        if filetype == "sh" or filetype == "bash" or filetype == "zsh" then
          return { "indent" }
        end
        -- for all other file types, use treesitter first, then indent
        return { "treesitter", "indent" }
      end
    })
  end,
}
