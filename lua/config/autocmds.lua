-- Auto-save modified buffers when leaving a buffer or losing focus.
-- Skips special buffers (help, terminal, etc.) and gitgraph buffers,
-- which would otherwise get written as files in the working directory.
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].modified and vim.bo[buf].filetype ~= "gitgraph" and vim.bo[buf].buftype == "" then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent! write")
        end)
      end
    end
  end,
})

local filepathname = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
vim.opt.titlestring = "nvim - " .. filepathname:gsub("^~/code/", "")
vim.opt.title = true
