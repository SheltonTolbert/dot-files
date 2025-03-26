vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*.git/COMMIT_EDITMSG",
  callback = function()
    vim.cmd("normal! gv")
    vim.cmd("CodeCompanion /gen_commit")
  end,
})

vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*",
  callback = function()
    local max_file_size = 100 * 1024 -- 100 KB
    local file_size = vim.fn.getfsize(vim.fn.expand("<afile>"))
    if file_size > max_file_size then
      print("File size exceeds " .. file_size .. " bytes. Large file mode enabled for this buffer.")
      vim.opt_local.swapfile = false
      vim.opt_local.buflisted = false
      vim.opt_local.foldenable = false
      vim.opt_local.relativenumber = false
      vim.opt_local.wrap = false
      vim.opt_local.lazyredraw = true
    end
  end
})
