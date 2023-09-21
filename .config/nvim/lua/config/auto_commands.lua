-- vim.cmd([[
--   augroup MixFormatAuto
--     autocmd!
--     autocmd BufWritePost *.ex,*.exs :Neoformat
--   augroup end
-- ]])

vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*",
  callback = function()
    local max_file_size = 100 * 1024 -- 100 KB
    local file_size = vim.fn.getfsize(vim.fn.expand("<afile>"))
    if file_size > max_file_size then
      print("File size exceeds " .. file_size .. " bytes. Large file mode enabled for this buffer.")
      -- vim.opt_local.syntax = "off"
      -- vim.opt_local.undofile = false
      vim.opt_local.swapfile = false
      vim.opt_local.buflisted = false
      vim.opt_local.foldenable = false
      vim.opt_local.relativenumber = false
      -- vim.opt_local.number = false
      vim.opt_local.wrap = false
      vim.opt_local.lazyredraw = true
    end
  end
})
