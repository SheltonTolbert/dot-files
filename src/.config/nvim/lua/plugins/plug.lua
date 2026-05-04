local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')


-- "Devdocs"
-- Plug 'luckasRanarison/nvim-devdocs'

Plug 'nvim-lua/plenary.nvim'

-- "Testing"
-- Plug 'nvim-lua/plenary.nvim'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'nvim-neotest/nvim-nio'
Plug 'nvim-neotest/neotest'
Plug 'jfpedroza/neotest-elixir'

-- "AI"
Plug 'https://github.com/ThePrimeagen/99.git'

-- "UI"
-- Plug 'glepnir/dashboard-nvim'
-- Plug 'rcarriga/nvim-notify'

-- "Fzf.lua"
Plug('ibhagwan/fzf-lua', { branch = 'main' })

-- "Git blame"
Plug 'APZelos/blamer.nvim'

-- "Telescope"
Plug 'nvim-telescope/telescope.nvim'

-- "LLM"
-- Plug 'github/copilot.vim'
-- Plug 'milanglacier/minuet-ai.nvim'
-- Plug 'ravitemer/codecompanion-history.nvim'
-- Plug 'olimorris/codecompanion.nvim'
-- Plug 'ravitemer/mcphub.nvim'

-- "Octo"
-- Plug 'pwntester/octo.nvim'
-- Plug 'nvim-tree/nvim-web-devicons'

-- "Themes"
Plug 'markvincze/panda-vim'
Plug 'mhartington/oceanic-next'
Plug 'srcery-colors/srcery-vim'
Plug 'ayu-theme/ayu-vim'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'sainnhe/gruvbox-material'

-- "Syntax Highlighting"
-- Plug 'elixir-editors/vim-elixir'

-- "Utils"
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug 'jiaoshijie/undotree'
Plug 'tpope/vim-fugitive'
Plug 'knsh14/vim-github-link'
Plug 'MeanderingProgrammer/render-markdown.nvim'
Plug 'rmagatti/auto-session'
Plug 'rmagatti/session-lens'
-- Plug('ThePrimeagen/harpoon', { branch = 'harpoon2' })
Plug 'yousefakbar/notmuch.nvim'

-- "LSP"
Plug 'neovim/nvim-lspconfig'

-- "js/ts"
Plug 'pmizio/typescript-tools.nvim'

-- "File Tree"
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua' -- "optional, for file icons"

-- "Fonts"
Plug 'powerline/powerline-fonts'

-- "fzf"
Plug('junegunn/fzf', { ['do'] = function() vim.fn['fzf#install']() end })
Plug 'junegunn/fzf.vim'

-- "Diff Gutter"
Plug 'airblade/vim-gitgutter'
-- Plug 'lewis6991/gitsigns.nvim'

-- "Spell Check"
Plug 'kamykn/spelunker.vim'

-- "Prettier"
Plug 'sbdchd/neoformat'

-- "Elixir Formatter"
Plug 'mhinz/vim-mix-format'

-- "Completion Engine & Snippet Engine"
-- -Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'echasnovski/mini.completion'


-- "AutoCloseTags for react and html"
Plug 'alvan/vim-closetag'

-- "Github"
Plug 'ldelossa/litee.nvim'
Plug('ldelossa/gh.nvim', { requires = { 'ldelossa/litee.nvim' } })

-- "TPope"
Plug 'tpope/vim-surround'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-dispatch'

-- "Tmux navigation"
Plug 'christoomey/vim-tmux-navigator'

-- "Navigator"
Plug('ray-x/guihua.lua', { ['do'] = 'cd lua/fzy && make' })
Plug 'ray-x/navigator.lua'

-- "Layout"
Plug('shortcuts/no-neck-pain.nvim', { ['tag'] = '*' })

vim.call('plug#end')
