vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  command = "silent! wall",
})
