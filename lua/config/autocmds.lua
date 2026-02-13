vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  command = "silent! wall",
})

local filepathname = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
vim.opt.titlestring = "nvim - " .. filepathname:gsub("^~/code/", "")
vim.opt.title = true
