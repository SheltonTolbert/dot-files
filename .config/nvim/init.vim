"===================================================================================="
"System dependencies
"===================================================================================="

"brew install lua, ripgrep"

"I'm relying on a global installation of prettier here. might want to
"reconsider this. maybe we can look for local prettier.rc and default to
"global if needed.

"npm install -g prettier

"powerline font:

"brew tap homebrew/cask-fonts &&
"brew install --cask font-hack-nerd-font
"
"The Elixir Lsp requires specifying an absolute path. This should 
"be set in the require'lspconfig'.elixirls.setup() call in ./lau/ss_swizzle.lau
"
"# Lsp dependencies
"
"npm i -g vscode-langservers-extracted
"
"===================================================================================="
"Settings
"===================================================================================="

set exrc
set relativenumber
set nu
set nohlsearch
set noerrorbells
set tabstop=2 softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set nowrap
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set scrolloff=8
set noshowmode
set signcolumn=yes
set hidden
set nospell
set cursorline
set path=.,,/Users/sheltontolbert/repos/dscout/apps/dendra/src/**

lua << EOF
vim.diagnostic.config({virtual_text = true, source = false})
EOF

"===================================================================================="
"Plugins"
"===================================================================================="

call plug#begin('~/.vim.plugged')
"Git blame"
Plug 'APZelos/blamer.nvim'
"Telescope" 
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
"Themes"
Plug 'markvincze/panda-vim'
Plug 'mhartington/oceanic-next'
Plug 'srcery-colors/srcery-vim'
"Syntax Highlighting"
Plug 'elixir-editors/vim-elixir'
"Utils"
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'jiaoshijie/undotree'
Plug 'tpope/vim-fugitive'
"LSP"
Plug 'neovim/nvim-lspconfig'
"js/ts"
    Plug 'jose-elias-alvarez/null-ls.nvim'
    Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
    Plug 'jose-elias-alvarez/typescript.nvim'
"File Tree"
Plug 'kyazdani42/nvim-web-devicons' "optional, for file icons"
Plug 'kyazdani42/nvim-tree.lua'
"Fonts"
Plug 'powerline/powerline-fonts'
"fzf"
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
"Diff Gutter"
Plug 'airblade/vim-gitgutter'
"Spell Check"
Plug 'kamykn/spelunker.vim'
"Prettier"
Plug 'sbdchd/neoformat'
"Elixir Formatter"
Plug 'mhinz/vim-mix-format'
"Completion Engine & Snippet Engine"
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
"AutoCloseTags for react and html"
Plug 'alvan/vim-closetag'
call plug#end()

"===================================================================================="
"Post-Plugin Settings"
"===================================================================================="

syntax on 
filetype plugin indent on
colorscheme OceanicNext
hi diffAdded ctermfg=black ctermbg=green guibg=NONE 
hi diffRemoved ctermfg=black ctermbg=197 cterm=NONE guifg=black guibg=NONE 

set completeopt=menu,menuone,noselect

"Transparent background"
hi Normal guibg=none ctermbg=none
hi LineNr guibg=none ctermbg=none
hi Folded guibg=none ctermbg=none
hi NonText guibg=none ctermbg=none
hi SpecialKey guibg=none ctermbg=none
hi VertSplit guibg=none ctermbg=none
hi SignColumn guibg=none ctermbg=none
hi EndOfBuffer guibg=none ctermbg=none

let g:neoformat_try_node_exe = 1

"===================================================================================="
"Key Bindings"
"===================================================================================="

let mapleader = " "

nnoremap <leader>p :Files<CR>
nnoremap <leader>v :vsp<CR>
nnoremap <leader>h :sp<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>ff <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fw <cmd>lua require('telescope.builtin').grep_string()<cr>
nnoremap <leader>ft :NvimTreeToggle<CR>
nnoremap <leader>fc :Neoformat<CR>
nnoremap <leader>k :lua vim.diagnostic.open_float()<CR>
nnoremap <leader>sss :source $MYVIMRC<CR>

"===================================================================================="
"LSP config"
"===================================================================================="

lua << EOF

local lspconfig = require("lspconfig")

require("ss_swizzle")
require('nvim-treesitter.configs').setup({
    highlight = {
        enable = true 
        }
    })

EOF

"File tree setup"

lua << EOF

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
      },
    },
  },
  renderer = {
    group_empty = true,
    indent_markers = {
        enable = true,
    },
  },
  filters = {
    dotfiles = false,
  },
})

EOF

"===================================================================================="
"Auto Commands"
"===================================================================================="

"autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js Neoformat"
autocmd BufWritePost *.ex,*.exs :MixFormat

