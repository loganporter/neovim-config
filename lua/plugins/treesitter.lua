return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "c", "lua", "vim", "vimdoc", "elixir", "javascript", "html", "python", "typescript", "tsx", "graphql", "json",
      "yaml", "css", "scss", "bash", "markdown", "markdown_inline"
    })

    -- highlight + indent are enabled per-buffer on the main branch (the old
    -- configs.setup highlight/indent modules no longer exist).
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
        pcall(vim.treesitter.start)
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end
}
