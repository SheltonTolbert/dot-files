local elixir_on_attach = function(client, bufnr)
  local opts = { noremap=true, silent=true }

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cf', '<cmd>lua vim.lsp.buf.format()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cd', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local function root_dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local matches = vim.fs.find({ "mix.exs" }, { upward = true, limit = 2, path = fname })
  local child_or_root_path, maybe_umbrella_path = unpack(matches)
  local dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)
  on_dir(dir)
end

local function find_elixir_ls_cmd()
  local cmd_path = vim.fn.exepath("elixir-ls")
  if cmd_path ~= "" then
    return cmd_path
  end

  local fallback = vim.fn.globpath(
    vim.env.HOME .. "/.local/share/mise/installs/elixir-ls",
    "*/bin/elixir-ls",
    false,
    true
  )
  return fallback[1] or ""
end

local cmd_path = find_elixir_ls_cmd()
if cmd_path ~= "" then
  vim.lsp.config('elixirls', {
      cmd = { cmd_path },
      root_dir = root_dir,
      filetypes = { "elixir", "eelixir", "heex" },
      on_attach = elixir_on_attach,
      capabilities = capabilities
  })
  vim.lsp.enable('elixirls')
else
  vim.notify("elixir-ls not found on PATH or mise installs", vim.log.levels.WARN)
end
