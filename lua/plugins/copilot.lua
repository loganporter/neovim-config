return {
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    -- Optional: Set up Copilot suggestions to be shown in a floating window
    vim.g.copilot_suggestion_enable_popup = true
  end,
}
