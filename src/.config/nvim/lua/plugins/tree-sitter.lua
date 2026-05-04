require('nvim-treesitter').setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "yaml", "html", "elixir", "heex", "eex" },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    disable = function(lang, buf)
        -- local max_filesize = 100 * 1024 -- 100 KB
        -- local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        -- if ok and stats and stats.size > max_filesize then
        --     return true
        -- end
    end,
    additional_vim_regex_highlighting = false,
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'elixir', 'eelixir', 'heex' },
  callback = function()
    vim.treesitter.start()
  end,
})
