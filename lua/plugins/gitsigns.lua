return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      current_line_blame = true,
      preview_config = {
        border = { " ", " ", " ", " ", " ", " ", " ", " " },
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    })
  end
}
