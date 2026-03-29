return {
  "mfussenegger/nvim-lint",
  event = { "BufWritePost", "BufReadPost", "InsertLeave" },
  config = function()
    local lint = require("lint")
    local uv = vim.loop or vim.uv
    local cwd = vim.fn.getcwd()

    local eslint_configs = {
      ".eslintrc",
      ".eslintrc.json",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.cjs",
    }

    local use_eslint = false
    for _, config in ipairs(eslint_configs) do
      if uv.fs_stat(cwd .. "/" .. config) then
        use_eslint = true
        break
      end
    end

    if use_eslint then
      lint.linters_by_ft = {
        javascript = { "eslint" },
        typescript = { "eslint" },
        javascriptreact = { "eslint" },
        typescriptreact = { "eslint" },
        python = { "ruff" },
      }
    else
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
    end

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}

