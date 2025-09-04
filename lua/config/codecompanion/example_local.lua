-- This file is for local configuration and is not checked into git.
-- Add your API keys and other sensitive information here.

local M = {}

M.chat_adapter = "gemini_cli" -- or "copilot", "gemini", "ollama", "anthropic"
M.inline_adapter = "copilot"  -- or "gemini", "ollama", "anthropic"
M.agent_adapter = "copilot"   -- or "gemini", "copilot", "ollama", "anthropic"

M.gemini = {
  adapter = "gemini",
  env = {
    api_key = os.getenv("GEMINI_API_KEY"),
  },
}

M.gemini_cli = {
  adapter = "gemini_cli",
}

M.ollama = {
  adapter = "ollama",
  schema = {
    model = {
      default = "llama3",
    },
  },
}

M.copilot = {
  adapter = "copilot",
}

M.claude = {
  adapter = "anthropic",
  env = {
    api_key = os.getenv("ANTHROPIC_API_KEY"),
  },
  schema = {
    model = {
      default = "claude-3-opus-20240229",
    },
  },
}

M.claude_code = {
  env = {
    CLAUDE_CODE_OAUTH_TOKEN = "Token here"
  }
}

return M
