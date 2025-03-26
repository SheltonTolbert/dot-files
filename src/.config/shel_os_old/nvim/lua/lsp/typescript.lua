require("typescript").setup({
     --disable_commands = false, -- prevent the plugin from creating Vim commands
     --debug = false, -- enable debug logging for commands
    server = { -- pass options to lspconfig's setup method
        on_attach = function()
            --vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = 0})
        end,
    },
  capabilities = capabilities
})

