return {
  "kevinhwang91/nvim-ufo",
  dependencies = "kevinhwang91/promise-async",
  config = function()
    require("ufo").setup({
      provider_selector = function(bufnr, filetype, buftype)
        -- for js, ts, jsx, tsx file types
        if filetype == "javascript" or filetype == "typescript" or
            filetype == "javascriptreact" or filetype == "typescriptreact" then
          -- use lsp first, then treesitter
          return { "lsp", "treesitter" }
        end
        -- for all other file types, use treesitter first, then indent
        return { "treesitter", "indent" }
      end
    })
  end,
}
