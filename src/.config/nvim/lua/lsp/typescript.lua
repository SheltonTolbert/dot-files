local capabilities = vim.lsp.protocol.make_client_capabilities()

vim.lsp.config('tsserver', {
  capabilities = capabilities,
  on_attach = function()
    -- vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })
  end,
})
vim.lsp.enable('tsserver')
