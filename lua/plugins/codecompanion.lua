return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local local_ok, local_config = pcall(require, "config.codecompanion.local")
    local adapters = {}
    if local_ok then
      if local_config.gemini then
        adapters.gemini = function()
          return require("codecompanion.adapters").extend("gemini", local_config.gemini)
        end
      end
      if local_config.ollama then
        adapters.ollama = function()
          return require("codecompanion.adapters").extend("ollama", local_config.ollama)
        end
      end
      if local_config.copilot then
        adapters.copilot = function()
          return require("codecompanion.adapters").extend("copilot", local_config.copilot)
        end
      end
      if local_config.claude then
        adapters.anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", local_config.claude)
        end
      end
    end

    require("codecompanion").setup({
      adapters = adapters,
      strategies = {
        chat = {
          adapter = "copilot", -- or "gemini", "ollama", "anthropic"g
        },
        inline = {
          adapter = "copilot", -- or "gemini", "ollama", "anthropic"
        },
        agent = {
          adapter = "copilot", -- or "gemini", "ollama", "anthropic"
        },
      },
    })

    vim.opt.splitright = true
  end
}
