local itermBgColorWithTransparancy = "#1A2B47"
local itermBaseColor = "#151a23"

-- Enable syntax highlighting and filetype plugin indent
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

-- Set colorscheme
-- vim.cmd('colorscheme OceanicNext')
vim.cmd('colorscheme gruvbox-material')

-- Set completeopt and termguicolors
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.termguicolors = true

-- Transparent background settings
function extend_hl(name, def)
    local current_def = vim.api.nvim_get_hl_by_name(name, true)
    local new_def = vim.tbl_extend('force', {}, current_def, def)

    vim.api.nvim_set_hl(0, name, new_def)
end

extend_hl('Normal', { bg = 'none', ctermbg = 'none' })
extend_hl('LineNr', { bg = 'none', ctermbg = 'none' })
extend_hl('Folded', { bg = 'none', ctermbg = 'none' })
extend_hl('NonText', { bg = 'none', ctermbg = 'none' })
extend_hl('SpecialKey', { bg = 'none', ctermbg = 'none' })
extend_hl('WinSeparator', { fg = '#343d46', bg = 'none', ctermbg = 'none'  })
extend_hl('SignColumn', { bg = 'none', ctermbg = 'none' })
extend_hl('EndOfBuffer', { bg = 'none', ctermbg = 'none' })
extend_hl('CursorLine', { bg = '#323e54', ctermbg = 235 })
-- extend_hl('GitGutterAdd', { bg = 'none', ctermbg = 'none' })
-- extend_hl('GitGutterChange', { bg = 'none', ctermbg = 'none' })
-- extend_hl('GitGutterDelete', { bg = 'none', ctermbg = 'none' })
extend_hl('NormalFloat', { bg = itermBgColorWithTransparancy })
extend_hl('FloatBorder', { bg = itermBgColorWithTransparancy })

-- Specific settings for the oceanic next theme
extend_hl('LspReferenceRead', { link = 'Visual' })
extend_hl('LspReferenceText', { link = 'Visual' })
extend_hl('LspReferenceWrite', { link = 'Visual' })

-- Diff syntax highlighting
extend_hl('DiffAdd', { bg = 'green', ctermbg = 0, ctermfg = 15 })
extend_hl('DiffChange', { bg = 'blue', ctermbg = 0, ctermfg = 15 })
extend_hl('DiffDelete', { bg = 'red', ctermbg = 0, ctermfg = 15 })
extend_hl('DiffText', { bg = '#2f3f4c', fg = '#ffffff', ctermbg = 0, ctermfg = 15 })
