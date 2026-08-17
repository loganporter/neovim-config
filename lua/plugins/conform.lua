return {
  'stevearc/conform.nvim',
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = function()
    local project = require("config.project")

    -- Resolved per buffer (conform calls this with the bufnr on every format),
    -- so a Biome package and a Prettier package can be open side by side.
    local function web(bufnr)
      if project.uses_biome(bufnr) then
        return { "biome", "biome-check", "biome-organize-imports" }
      end
      return { "prettier" }
    end

    local formatters_by_ft = {}
    for _, ft in ipairs({
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "css",
      "scss",
      "html",
      "json",
      "yaml",
      "markdown",
    }) do
      formatters_by_ft[ft] = web
    end

    return {
      formatters_by_ft = formatters_by_ft,
      -- NB: `default_format_opts`, not `default_format_ops` -- the misspelling
      -- was silently ignored by conform, so `lsp_format` never applied.
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    }
  end
}
