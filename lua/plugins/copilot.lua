return {
  "github/copilot.vim",
  config = function()
    -- Set up Copilot keybindings
    vim.g.copilot_no_tab_map = true
    vim.api.nvim_set_keymap("i", "<Tab>", 'copilot#Accept("<CR>")', { expr = true, silent = true, noremap = true })
    vim.api.nvim_set_keymap("i", "<D-Right>", '<Plug>(copilot-accept-word)',
      { expr = true, silent = true, noremap = true })
    vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Dismiss()', { expr = true, silent = true, noremap = true })

    -- Optional: Set up Copilot suggestions to be shown in a floating window
    vim.g.copilot_suggestion_enable_popup = true
  end,
}
