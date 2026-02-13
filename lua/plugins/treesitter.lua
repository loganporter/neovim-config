return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = {
        "c", "lua", "vim", "vimdoc", "elixir", "javascript", "html", "python", "typescript", "tsx", "graphql", "json",
        "yaml", "css", "scss", "bash", "markdown", "markdown_inline"
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
}
