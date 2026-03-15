-- Example MCP Server Configurations for CodeCompanion
-- ====================================================
--
-- This file documents how to configure MCP (Model Context Protocol) servers
-- for use with CodeCompanion.
--
-- To use: copy this file to `mcp_servers.lua` in the same directory and
-- uncomment/modify the servers you want. The `mcp_servers.lua` file is
-- gitignored so your personal configuration stays local.
--
-- Format
-- ------
-- Each entry is a table key (server name) mapped to a configuration object:
--
--   server_name = {
--     cmd             = { "executable", "arg1", "arg2" },  -- (required) command + args
--     env             = { KEY = "value" },                  -- (optional) environment variables
--     tool_defaults   = { require_approval_before = true }, -- (optional) defaults for all tools
--     tool_overrides  = { ["tool-name"] = { ... } },        -- (optional) per-tool overrides
--     roots           = function() return { ... } end,      -- (optional) root directories
--   }
--
-- Servers are loaded into the top-level `mcp.servers` config of codecompanion.setup().
-- All servers communicate over stdio (stdin/stdout).

return {
  -----------------------------------------------------------------------
  -- Everything (Test Server) - Official MCP test server for verification
  -- No API keys or configuration required. Provides sample tools like
  -- `echo`, `add`, and `longRunningOperation` to confirm your MCP
  -- integration is working. Remove once you've verified the setup.
  -- Install: npx -y @modelcontextprotocol/server-everything
  -----------------------------------------------------------------------
  -- everything = {
  --   cmd = { "npx", "-y", "@modelcontextprotocol/server-everything" },
  -- },

  -----------------------------------------------------------------------
  -- Filesystem - Read/write access to specified directories
  -----------------------------------------------------------------------
  -- filesystem = {
  --   cmd = { "npx", "-y", "@modelcontextprotocol/server-filesystem", "/Users/you/projects" },
  -- },

  -----------------------------------------------------------------------
  -- GitHub - Repository, issue, and PR management
  -- Requires a GitHub personal access token.
  -----------------------------------------------------------------------
  -- github = {
  --   cmd = { "npx", "-y", "@modelcontextprotocol/server-github" },
  --   env = {
  --     GITHUB_PERSONAL_ACCESS_TOKEN = os.getenv("GITHUB_TOKEN"),
  --   },
  -- },

  -----------------------------------------------------------------------
  -- PostgreSQL - Read-only database access
  -----------------------------------------------------------------------
  -- postgres = {
  --   cmd = {
  --     "npx", "-y", "@modelcontextprotocol/server-postgres",
  --     "postgresql://user:password@localhost:5432/mydb",
  --   },
  -- },

  -----------------------------------------------------------------------
  -- Brave Search - Web search via Brave API
  -----------------------------------------------------------------------
  -- brave_search = {
  --   cmd = { "npx", "-y", "@modelcontextprotocol/server-brave-search" },
  --   env = {
  --     BRAVE_API_KEY = os.getenv("BRAVE_API_KEY"),
  --   },
  -- },

  -----------------------------------------------------------------------
  -- Memory - Persistent knowledge graph for long-term context
  -----------------------------------------------------------------------
  -- memory = {
  --   cmd = { "npx", "-y", "@modelcontextprotocol/server-memory" },
  -- },

  -----------------------------------------------------------------------
  -- Fetch - Retrieve and convert web content to markdown
  -----------------------------------------------------------------------
  -- fetch = {
  --   cmd = { "npx", "-y", "@modelcontextprotocol/server-fetch" },
  -- },

  -----------------------------------------------------------------------
  -- Custom server example (e.g. a local Python MCP server)
  -----------------------------------------------------------------------
  -- my_custom_server = {
  --   cmd = { "python", "-m", "my_mcp_server" },
  --   env = {
  --     MY_SERVER_CONFIG = "/path/to/config.json",
  --   },
  -- },
}
