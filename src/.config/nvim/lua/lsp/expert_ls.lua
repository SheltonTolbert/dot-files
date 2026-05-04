vim.lsp.config('expert', {
  cmd = { '/Users/sheltontolbert/.local/bin/expert_darwin_arm64', '--stdio' },
  root_markers = { 'mix.exs', '.git' },
  filetypes = { 'elixir', 'eelixir', 'heex' },
})
vim.lsp.enable('expert')
