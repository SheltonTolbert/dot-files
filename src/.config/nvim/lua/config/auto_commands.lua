vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*.git/COMMIT_EDITMSG",
  callback = function()
    -- Debug: Create a file on desktop with timestamp and context
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local debug_file = string.format("/Users/sheltontolbert/Desktop/git_debug_%s.txt", timestamp)

    -- Gather debug info
    local buf_name = vim.api.nvim_buf_get_name(0)
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local cwd = vim.fn.getcwd()
    local git_status = vim.fn.system("cd " .. cwd .. " && git status --porcelain 2>/dev/null || echo 'No git repo'")

    local debug_content = string.format([[
COMMIT_EDITMSG AUTOCMD TRIGGERED
================================
Timestamp: %s
Buffer Name: %s
Current Working Directory: %s
Buffer Line Count: %d
Git Status:
%s

Buffer Contents:
%s

Vim Mode: %s
]],
      os.date("%Y-%m-%d %H:%M:%S"),
      buf_name,
      cwd,
      #buf_lines,
      git_status,
      table.concat(buf_lines, "\n"),
      vim.fn.mode()
    )

    -- Write debug file
    local file = io.open(debug_file, "w")
    if file then
      file:write(debug_content)
      file:close()
    end
  end,
})

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
