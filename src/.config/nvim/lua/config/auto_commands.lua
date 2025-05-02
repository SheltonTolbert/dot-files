vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*.git/COMMIT_EDITMSG",
  callback = function()
    vim.cmd("normal! gv")
    vim.cmd("CodeCompanion /gen_commit")
  end,
})
