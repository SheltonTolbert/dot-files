-- Override default Neovim nofity with a notify.nvim
-- vim.notify = require("notify")
-- vim.lsp.set_log_level("info")

vim.diagnostic.config({virtual_text = true, source = false})
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
