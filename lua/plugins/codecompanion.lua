return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local local_ok, local_config = pcall(require, "config.codecompanion.local")

    -- MCP servers config for HTTP adapters (copilot, gemini, ollama, anthropic).
    -- ACP adapters (copilot_acp, claude_code) manage MCP servers separately:
    --   copilot_acp: configure via ~/.copilot/mcp-config.json or `/mcp add`
    --   claude_code: configure via ~/.claude/claude_desktop_config.json
    local mcp_ok, mcp_servers = pcall(require, "config.codecompanion.mcp_servers")
    if not mcp_ok then
      mcp_servers = {}
    end

    local http_adapters = {}
    local acp_adapters = {}
    local chat_adapter = "copilot"   -- default chat adapter
    local inline_adapter = "copilot" -- default inline adapter
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
      if local_config.copilot_acp then
        acp_adapters.copilot_acp = function()
          return require("codecompanion.adapters").extend("copilot_acp", local_config.copilot_acp)
        end
      end

      if local_config.chat_adapter then
        chat_adapter = local_config.chat_adapter
      end
      if local_config.inline_adapter then
        inline_adapter = local_config.inline_adapter
      end
    end

    local default_tools = {}
    if local_config and local_config.enable_tools_by_default then
      default_tools = {
        "run_command",
        "create_file",
        "file_search",
        "get_changed_files",
        "grep_search",
        "insert_edit_into_file",
        "read_file"
      }
    end

    require("codecompanion").setup({
      adapters = {
        http = http_adapters,
        acp = acp_adapters,
      },
      interactions = {
        chat = {
          adapter = chat_adapter,
          tools = {
            opts = {
              default_tools = default_tools,
            }
          }
        },
        inline = {
          adapter = inline_adapter,
        },
      },
      mcp = {
        servers = mcp_servers,
        opts = {
          default_servers = vim.tbl_keys(mcp_servers),
        },
      },
    })

    vim.opt.splitright = true
  end
}
