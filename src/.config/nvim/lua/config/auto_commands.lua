vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "markdown", "md" },
  callback = function()
    -- Enable line wrapping
    vim.opt_local.wrap = true

    -- Make wrapped lines visually indented
    vim.opt_local.breakindent = true

    -- Set formatting options for better wrapping
    vim.opt_local.linebreak = true

    -- Enable navigating visual lines instead of logical lines
    vim.keymap.set("n", "j", "gj", { buffer = true })
    vim.keymap.set("n", "k", "gk", { buffer = true })
    vim.keymap.set("v", "j", "gj", { buffer = true })
    vim.keymap.set("v", "k", "gk", { buffer = true })

    -- Additional options for better markdown editing
    vim.opt_local.conceallevel = 0 -- Don't hide markup
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client_id = args.data.client_id
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(client_id)
        if not client then
            return
        end

        if client.server_capabilities.completionProvider and client.name ~= 'minuet' then
            vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = true })
        end
    end,
    desc = 'Enable built-in auto completion',
})
