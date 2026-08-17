return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  config = function()
    local lint = require("lint")
    local project = require("config.project")

    -- Linters that don't depend on which JS toolchain the project uses.
    lint.linters_by_ft = {
      python = { "ruff" },
    }

    local web_filetypes = {
      javascript = true,
      typescript = true,
      javascriptreact = true,
      typescriptreact = true,
      css = true,
      scss = true,
      html = true,
      json = true,
      yaml = true,
      markdown = true,
    }

    -- ESLint only claims the filetypes it actually handles; Biome covers the
    -- wider set (css/json/yaml/...), matching how each tool is normally used.
    local eslint_filetypes = {
      javascript = true,
      typescript = true,
      javascriptreact = true,
      typescriptreact = true,
    }

    --- Point a linter at the binary belonging to this buffer's project, and
    --- report whether one could be found at all. Without this a project that
    --- has an ESLint config but no reachable `eslint` binary raises ENOENT on
    --- every BufRead/BufWrite/InsertLeave.
    local function usable(linter, bin_name, bufnr)
      local bin = project.node_bin(bufnr, bin_name)
      if not bin then
        return false
      end
      lint.linters[linter].cmd = bin
      return true
    end

    --- Which linters to run for a buffer, resolved from that buffer's own
    --- project root rather than from the cwd nvim happened to start in.
    local function linters_for(bufnr)
      local ft = vim.bo[bufnr].filetype
      local names = vim.list_extend({}, lint.linters_by_ft[ft] or {})
      if not web_filetypes[ft] then
        return names
      end
      if project.uses_eslint(bufnr) and eslint_filetypes[ft] then
        if usable("eslint", "eslint", bufnr) then
          table.insert(names, "eslint")
        end
      elseif project.uses_biome(bufnr) then
        if usable("biomejs", "biome", bufnr) then
          table.insert(names, "biomejs")
        end
      end
      return names
    end

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function(args)
        local names = linters_for(args.buf)
        if #names > 0 then
          lint.try_lint(names)
        end
      end,
    })
  end,
}
