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
    local cli = nil
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

      if local_config.cli then
        cli = local_config.cli
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

    local config_dir = vim.fn.stdpath("config")

    require("codecompanion").setup({
      prompt_library = {
        markdown = {
          dirs = {
            config_dir .. "/.prompts",
            config_dir .. "/.prompts.local",
          },
        },
      },
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
          },
          keymaps = {
            clear = false,
          },
        },
        inline = {
          adapter = inline_adapter,
        },
        cli = cli,
      },
      mcp = {
        servers = mcp_servers,
        opts = {
          default_servers = vim.tbl_keys(mcp_servers),
        },
      },
    })

    vim.opt.splitright = true

    -- markview can't render tables while `wrap` is on: for any table wider than
    -- ~90% of the window it bails out and leaves the raw `| ... |` markdown (see
    -- markview's renderers/markdown.lua, "BUG, wrap breaks table rendering").
    -- We keep `wrap` on for readable prose, so wide tables fall back to raw
    -- markdown. `linebreak`/`breakindent` at least make that fallback wrap at
    -- word boundaries with indented continuation lines instead of mid-word.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "codecompanion",
      callback = function()
        vim.wo.linebreak = true
        vim.wo.breakindent = true
      end,
      desc = "Nicer soft-wrapping for CodeCompanion chat (incl. raw wide tables)",
    })

    -- Register CodeCompanion's completion source (`#` editor context, `@` tools,
    -- `/` slash commands) with blink.cmp for the chat buffers. This uses blink's
    -- additive `add_filetype_source`, so it composes with any other sources
    -- (e.g. markview) instead of clobbering them.
    pcall(require, "codecompanion.providers.completion.blink.setup")
  end
}
