return {
  'stevearc/conform.nvim',
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = (function()
      local uv = vim.loop or vim.uv
      local cwd = vim.fn.getcwd()
      if uv.fs_stat(cwd .. "/biome.json") or uv.fs_stat(cwd .. "/biome.jsonc") then
        return {
          javascript = { "biome", "biome-check", "biome-organize-imports" },
          typescript = { "biome", "biome-check", "biome-organize-imports" },
          javascriptreact = { "biome", "biome-check", "biome-organize-imports" },
          typescriptreact = { "biome", "biome-check", "biome-organize-imports" },
          css = { "biome", "biome-check", "biome-organize-imports" },
          scss = { "biome", "biome-check", "biome-organize-imports" },
          html = { "biome", "biome-check", "biome-organize-imports" },
          json = { "biome", "biome-check", "biome-organize-imports" },
          yaml = { "biome", "biome-check", "biome-organize-imports" },
          markdown = { "biome", "biome-check", "biome-organize-imports" }
        }
      else
        return {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" }
        }
      end
    end)(),
    -- Set default options
    default_format_ops = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    }
  }
}
