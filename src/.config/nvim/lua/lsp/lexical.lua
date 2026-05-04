-- Define the on_attach function once. This will be called by the LSP handler
-- when the lexical server attaches to a buffer.
local on_attach = function(client, bufnr)
  -- Use vim.keymap.set for a cleaner and more modern keymapping API.
  -- The `buffer = bufnr` option ensures the keymaps are local to the current buffer.
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- LSP-related keymaps
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)
  vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts) -- Set for both normal and visual mode

  -- NOTE: vim.lsp.buf.formatting() is deprecated.
  -- Use vim.lsp.buf.format() instead. It is asynchronous by default.
  vim.keymap.set('n', '<leader>cf', function()
    vim.lsp.buf.format { async = true }
  end, opts)

  -- Diagnostic keymaps
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, opts) -- Uncommented as it's a useful mapping
end

local function root_dir(fname)
  return vim.fs.root(fname, { "mix.exs", ".git" })
end

vim.lsp.config('lexical', {
  -- Your custom command to start the server is still perfectly valid.
  cmd = { os.getenv("HOME") .. "/repos/lexical/_build/dev/package/lexical/bin/start_lexical.sh" },
  root_dir = root_dir,
  filetypes = { "elixir", "eelixir", "heex" },
  on_attach = on_attach,
  settings = {},
})
vim.lsp.enable('lexical')
