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
"set relativenumber
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
"Fzf.lua"
Plug 'ibhagwan/fzf-lua', {'branch': 'main'}
"Git blame"
Plug 'APZelos/blamer.nvim'
"Telescope" 
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
"Themes"
Plug 'markvincze/panda-vim'
Plug 'mhartington/oceanic-next'
Plug 'srcery-colors/srcery-vim'
Plug 'ayu-theme/ayu-vim'
"Syntax Highlighting"
Plug 'elixir-editors/vim-elixir'
"Utils"
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'jiaoshijie/undotree'
Plug 'tpope/vim-fugitive'
Plug 'knsh14/vim-github-link'
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
" Org Mode"
Plug 'nvim-orgmode/orgmode'
"Github"
Plug 'ldelossa/litee.nvim'
Plug 'ldelossa/gh.nvim', { 'requires': ['ldelossa/litee.nvim'] }
Plug 'pwntester/octo.nvim'

call plug#end()

"===================================================================================="
"Post-Plugin Settings"
"===================================================================================="

syntax enable
filetype plugin indent on
colorscheme OceanicNext

" different diff highlight colors"
"hi diffAdded ctermfg=black ctermbg=green guibg=NONE "
"hi diffRemoved ctermfg=black ctermbg=197 cterm=NONE guifg=black guibg=NONE "

set completeopt=menu,menuone,noselect
set termguicolors


"Transparent background"
"hi Normal guibg=none ctermbg=none"
"hi LineNr guibg=none ctermbg=none"
"hi Folded guibg=none ctermbg=none"
"hi NonText guibg=none ctermbg=none"
"hi SpecialKey guibg=none ctermbg=none"
"hi VertSplit guibg=none ctermbg=none"
"hi SignColumn guibg=none ctermbg=none"
"hi EndOfBuffer guibg=none ctermbg=none"

let g:neoformat_try_node_exe = 1

"===================================================================================="
"Key Bindings"
"===================================================================================="

let mapleader = " "

nnoremap <leader>p :Files<CR>
nnoremap <leader>v :vsp<CR>
nnoremap <leader>h :sp<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>gh :FzfLua register_ui_select <CR>
nnoremap <leader>ff <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fw <cmd>lua require('telescope.builtin').grep_string()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <leader>ft :NvimTreeToggle<CR>
nnoremap <leader>fc :Neoformat<CR>
nnoremap <leader>k :lua vim.diagnostic.open_float()<CR>
nnoremap <leader>sss :source $MYVIMRC<CR>
vnoremap <Leader>y "+y"
nnoremap <Leader>yy :let @+=getline('.')<CR>

"===================================================================================="
"LSP config"
"===================================================================================="

lua << EOF

local lspconfig = require("lspconfig")

require("ss_swizzle")
require("gpt")

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

lua << EOF
    function get_file(file_string)
      -- if file string starts with './'
      if string.find(file_string, '^./') then
        -- remove './'
        return vim.fn.findfile(string.gsub(file_string, './', ''), ".;")
      end
      return vim.fn.findfile(file_string)
    end

    function better_gf()
      -- Get the file string under the cursor and expand it to get the full path. strip the file string of quotes y semicolons
      local file_string = vim.fn.expand("<cWORD>"):gsub("'", ""):gsub('"', ""):gsub(";", "")

      -- get the absolute path of the file string under the cursor using finddir
      local path = vim.fn.finddir(file_string)

      -- use getfile to get the full path of the file, if there is one
      local file = get_file(file_string)

      -- get list of all files in path, filter out files that do not contain path as a substring
      local dir_files = vim.fn.globpath(path, "**/*", true, true)

      -- if there is a file, open it in the current buffer
      if file ~= "" then
        vim.cmd("e " .. file)
      elseif #dir_files > 0 then
        require("telescope.builtin").find_files({cwd = path})
      end

    end

    -- if the current file is a js, ts, jsx, or tsx file, map the better_gf function to gf
      vim.api.nvim_set_keymap('n', 'gf', ':lua better_gf()<CR>', { noremap = true, silent = true })
EOF

"===================================================================================="
"Github Setup"
"===================================================================================="


lua << EOF


require('litee.lib').setup()
require('litee.gh').setup({
  -- deprecated, around for compatability for now.
  jump_mode   = "invoking",
  -- remap the arrow keys to resize any litee.nvim windows.
  map_resize_keys = false,
  -- do not map any keys inside any gh.nvim buffers.
  disable_keymaps = false,
  -- the icon set to use.
  icon_set = "default",
  -- any custom icons to use.
  icon_set_custom = nil,
  -- whether to register the @username and #issue_number omnifunc completion
  -- in buffers which start with .git/
  git_buffer_completion = true,
  -- defines keymaps in gh.nvim buffers.
  keymaps = {
      -- when inside a gh.nvim panel, this key will open a node if it has
      -- any futher functionality. for example, hitting <CR> on a commit node
      -- will open the commit's changed files in a new gh.nvim panel.
      open = "<CR>",
      -- when inside a gh.nvim panel, expand a collapsed node
      expand = "zo",
      -- when inside a gh.nvim panel, collpased and expanded node
      collapse = "zc",
      -- when cursor is over a "#1234" formatted issue or PR, open its details
      -- and comments in a new tab.
      goto_issue = "gd",
      -- show any details about a node, typically, this reveals commit messages
      -- and submitted review bodys.
      details = "d",
      -- inside a convo buffer, submit a comment
      submit_comment = "<C-s>",
      -- inside a convo buffer, when your cursor is ontop of a comment, open
      -- up a set of actions that can be performed.
      actions = "<C-a>",
      -- inside a thread convo buffer, resolve the thread.
      resolve_thread = "<C-r>",
      -- inside a gh.nvim panel, if possible, open the node's web URL in your
      -- browser. useful particularily for digging into external failed CI
      -- checks.
      goto_web = "gx"
  }
})
EOF
