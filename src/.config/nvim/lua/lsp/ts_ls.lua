vim.lsp.config('ts_ls', {
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
        languages = {"javascript", "typescript"},
      },
    },
  },
  filetypes = {
    "javascript",
    "typescript",
  },
})
vim.lsp.enable('ts_ls')
