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
    --
    -- indentexpr is only set when treesitter actually started for the buffer.
    -- Setting it unconditionally overrode the runtime `indent/*.vim` script for
    -- every filetype we have no parser for (haskell, cobol, ...), and
    -- nvim-treesitter's indentexpr has nothing to work from there -- so `=`,
    -- `==` and auto-indent silently became no-ops in exactly the filetypes that
    -- were relying on the built-in indenting.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      callback = function(ev)
        if pcall(vim.treesitter.start) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end
}
