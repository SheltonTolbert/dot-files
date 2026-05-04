local function root_dir(fname)
  return vim.fs.root(fname, { "package.json" })
end

vim.lsp.config('cssmodules_ls', {
  cmd = { 'cssmodules-language-server' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_dir = root_dir,
})
vim.lsp.enable('cssmodules_ls')
