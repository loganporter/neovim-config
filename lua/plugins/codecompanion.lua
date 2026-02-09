return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local local_ok, local_config = pcall(require, "config.codecompanion.local")
    local http_adapters = {}
    local acp_adapters = {}
    local chat_adapter = "copilot"   -- default chat adapter
    local inline_adapter = "copilot" -- default inline adapter
    local agent_adapter = "copilot"  -- default agent adapter
    if local_ok then
      if local_config.gemini then
        http_adapters.gemini = function()
          return require("codecompanion.adapters").extend("gemini", local_config.gemini)
        end
      end
      if local_config.gemini_cli then
        acp_adapters.gemini = function()
          return require("codecompanion.adapters").extend("gemini_cli", local_config.gemini_cli)
        end
      end
      if local_config.ollama then
        http_adapters.ollama = function()
          return require("codecompanion.adapters").extend("ollama", local_config.ollama)
        end
      end
      if local_config.copilot then
        http_adapters.copilot = function()
          return require("codecompanion.adapters").extend("copilot", local_config.copilot)
        end
      end
      if local_config.claude then
        http_adapters.anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", local_config.claude)
        end
      end
      if local_config.claude_code then
        acp_adapters.claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", local_config.claude_code)
        end
      end

      if local_config.chat_adapter then
        chat_adapter = local_config.chat_adapter
      end
      if local_config.inline_adapter then
        inline_adapter = local_config.inline_adapter
      end
      if local_config.agent_adapter then
        agent_adapter = local_config.agent_adapter
      end
    end

    require("codecompanion").setup({
      adapters = {
        http = http_adapters,
        acp = acp_adapters,
      },
      strategies = {
        chat = {
          adapter = chat_adapter,
        },
        inline = {
          adapter = inline_adapter,
        },
        agent = {
          adapter = agent_adapter,
        },
      },
    })

    vim.opt.splitright = true
  end
}
