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
        local ft = vim.bo[ev.buf].filetype
        -- Neovim 0.12 + bash parser can surface stale-node errors in the decoration
        -- provider. Fall back to Vim syntax highlighting for shell buffers.
        if ft == "sh" or ft == "bash" then
          return
        end
        pcall(vim.treesitter.start)
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- Guard set-lang-from-info-string! against stale treesitter nodes (neovim v0.12.0+).
    -- Stale nodes can pass a nil check but error on :range() when the underlying C object is freed.
    local query = require("vim.treesitter.query")
    local non_filetype_aliases = { ex = "elixir", pl = "perl", sh = "bash", uxn = "uxntal", ts = "typescript" }
    query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
      local node = match[pred[2]]
      -- Neovim 0.12 can pass a capture list instead of a single node.
      if type(node) == "table" then
        node = node[1]
      end
      if not node then
        return
      end
      if not pcall(function()
            return node:range()
          end) then
        return
      end
      local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
      if not ok or not text then
        return
      end
      local alias = text:lower()
      local ft = vim.filetype.match({ filename = "a." .. alias })
      metadata["injection.language"] = ft or non_filetype_aliases[alias] or alias
    end, { force = true })
  end
}
