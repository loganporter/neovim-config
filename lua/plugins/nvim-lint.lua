return {
  "mfussenegger/nvim-lint",
  event = { "BufWritePost", "BufReadPost", "InsertLeave" },
  config = function()
    local lint = require("lint")
    local uv = vim.loop or vim.uv
    local cwd = vim.fn.getcwd()
    local use_biome = uv.fs_stat(cwd .. "/biome.json") or uv.fs_stat(cwd .. "/biome.jsonc")
    if use_biome then
      lint.linters_by_ft = {
        javascript = { "biomejs" },
        typescript = { "biomejs" },
        javascriptreact = { "biomejs" },
        typescriptreact = { "biomejs" },
        css = { "biomejs" },
        scss = { "biomejs" },
        html = { "biomejs" },
        json = { "biomejs" },
        yaml = { "biomejs" },
        markdown = { "biomejs" },
        python = { "ruff" },
      }
    else
      lint.linters_by_ft = {
        javascript = { "eslint" },
        typescript = { "eslint" },
        javascriptreact = { "eslint" },
        typescriptreact = { "eslint" },
        python = { "ruff" },
      }
    end

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}

