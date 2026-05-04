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
      highlight = {
        enable = true,
        -- Neovim 0.12 + bash parser can surface stale-node errors in decoration provider.
        -- Fall back to Vim syntax highlighting for shell buffers.
        disable = { "bash" },
        additional_vim_regex_highlighting = { "bash" },
      },
      indent = { enable = true },
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
