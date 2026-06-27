return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  init = function()
    -- Use the lazygit config bundled with this nvim repo so keybinding overrides
    -- (e.g. <esc> to quit) work on any device without per-machine setup.
    vim.g.lazygit_use_custom_config_file_path = 1
    vim.g.lazygit_config_file_path = vim.fn.stdpath("config") .. "/lazygit/config.yml"

    -- When lazygit exits, if it was launched from a terminal buffer, return
    -- that terminal to normal mode instead of dropping back into terminal mode.
    vim.g.lazygit_on_exit_callback = function()
      if vim.bo.buftype == "terminal" then
        vim.schedule(function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
        end)
      end
    end
  end,
}
