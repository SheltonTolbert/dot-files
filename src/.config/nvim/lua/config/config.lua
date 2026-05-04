-- Override default Neovim nofity with a notify.nvim
-- vim.notify = require("notify")
-- vim.lsp.set_log_level("DEBUG")

vim.diagnostic.config({
  virtual_text = true,
  source = false,
  float = { border = "rounded" },
})

vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
  if not (result and result.contents) then
    return
  end

  local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  lines = vim.lsp.util.trim_empty_lines(lines)
  if vim.tbl_isempty(lines) then
    return
  end

  local pad_left, pad_right, pad_top, pad_bottom = 2, 2, 1, 1
  for i, line in ipairs(lines) do
    lines[i] = string.rep(" ", pad_left) .. line .. string.rep(" ", pad_right)
  end
  for _ = 1, pad_top do
    table.insert(lines, 1, string.rep(" ", pad_left + pad_right))
  end
  for _ = 1, pad_bottom do
    table.insert(lines, string.rep(" ", pad_left + pad_right))
  end

  local opts = vim.tbl_extend("force", config or {}, { border = "rounded" })
  local width, height = vim.lsp.util._make_floating_popup_size(lines, opts)
  local ui = vim.api.nvim_list_uis()[1]
  if not ui then
    return
  end

  opts.relative = "editor"
  opts.anchor = "NW"
  opts.row = math.max(0, math.floor((ui.height - height) / 2))
  opts.col = math.max(0, math.floor((ui.width - width) / 2))

  vim.lsp.util.open_floating_preview(lines, "markdown", opts)
end
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = "rounded" }
)

vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" }
vim.opt.shada = "!,'1000,<50,s10,h"
-- Set line numbers
vim.opt.number = true

-- Disable search highlight
vim.opt.hlsearch = false

-- Disable error bells
vim.opt.errorbells = false

-- Set tab settings
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Enable smart indent
vim.opt.smartindent = true

-- Disable line wrap
vim.opt.wrap = false

-- Disable swap file
vim.opt.swapfile = false

-- Disable backup file
vim.opt.backup = false

-- Set undo directory
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Enable undo file
vim.opt.undofile = true

-- Enable incremental search
vim.opt.incsearch = true

-- Set inccommand to split to avoid conflicts with cmp cmdline
vim.opt.inccommand = "split"

-- Set scroll offset
vim.opt.scrolloff = 24

-- Disable show mode
vim.opt.showmode = false

-- Always show the sign column
vim.opt.signcolumn = "yes"

-- Enable hidden buffers
vim.opt.hidden = true

-- Disable spell check
vim.opt.spell = false

-- Enable cursor line
vim.opt.cursorline = true
vim.opt.cursorlineopt = "screenline"

-- Set path
vim.opt.path:append(".,,/Users/sheltontolbert/repos/dscout/apps/dendra/src/**")

-- Garbage collection command
vim.api.nvim_create_user_command("GarbageCollect", function()
  collectgarbage("collect")
  print("GC done: " .. math.floor(collectgarbage("count") / 1024) .. "MB Lua memory")
end, {})

-- Periodic garbage collection (every 5 minutes)
vim.defer_fn(function()
  local timer = vim.loop.new_timer()
  timer:start(0, 300000, vim.schedule_wrap(function()
    collectgarbage("collect")
  end))
end, 5000)
