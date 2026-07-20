return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    vim.opt.fillchars:append { diff = "╱" }
    require("diffview").setup({
      enhanced_diff_hl = true,
    })

    -- Close the Diffview tab automatically when you leave it, so you don't
    -- end up with stale Diffview tabs stacking up.
    vim.api.nvim_create_autocmd("User", {
      pattern = "DiffviewViewLeave",
      callback = function()
        vim.schedule(function()
          require("diffview").close()
        end)
      end,
    })
  end,
}
