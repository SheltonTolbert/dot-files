-- Set leader key
vim.g.mapleader = ' '

-- Define key mappings
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local myvimrc = vim.fn.expand('$MYVIMRC')

-- Normal mode mappings
  map('n', '<leader>p', ':Files<CR>', opts)
  map('n', '<leader>v', ':vsp<CR>', opts)
  map('n', '<leader>h', ':sp<CR>', opts)
  map('n', '<leader>co', ':copen<CR>', opts)

    -- Telescope mappings
--  map('n', '<leader>b', ':Telescope buffers<CR>', opts) FIXME: Not sorted by most recent
  -- map('n', '<leader>co', ':lua require(\'telescope.builtin\').quickfix()<CR>', opts)
  -- map('n', '<leader>cd', ':call setqflist([])<CR>', opts)


  local telescopeActions = require('telescope.actions')
  -- local copilotChatActions = require("CopilotChat.actions")
  quickfix = require('telescope.builtin').quickfix

  require('telescope').setup{
    defaults = {
      mappings = {
        i = {
          ["<C-q>"] = telescopeActions.send_to_qflist
        },
        n = {
          ["<C-q>"] = telescopeActions.send_to_qflist
        },
      },
    }
  }

  map('n', '<leader>w', ':w | cn<CR>', opts)
  map('n', '<leader>co', ':lua quickfix()<CR>', opts)
  map('n', '<leader>cd', ':call setqflist([])<CR>', opts)
  map('n', '<leader>b', ':Buffers<CR>', opts)
  map('n', 'ml', ':lua list_marked_files()<CR>', opts)
  map('n', 'mb', ':lua mark_current_file()<CR>', opts)
  map('n', '<leader>U', ':lua unmark_current_file()<CR>', opts)
  map('n', '<leader>m', ':lua view_mark_groups_selector()<CR>', opts)

  map('n', '<leader>gh', ':FzfLua register_ui_select<CR>', opts)
  map('n', '<leader>td', '<cmd>lua require("telescope.builtin").lsp_definitions()<CR>', opts)
  -- telescope
  map('n', 'gd', '<cmd>lua require("telescope.builtin").lsp_definitions()<CR>', opts)
  map('n', 'ft', '<cmd>lua require("telescope.builtin").lsp_type_definitions()<CR>', opts)
  map('n', 'fi', '<cmd>lua require("telescope.builtin").lsp_incoming_calls()<CR>', opts)
  map('n', 'fo', '<cmd>lua require("telescope.builtin").lsp_outgoing_calls()<CR>', opts)
  map('n', 'fr', '<cmd>lua require("telescope.builtin").lsp_references()<CR>', opts)
  map('n', '<leader>ff', '<cmd>lua require("telescope.builtin").live_grep()<CR>', opts)
  map('n', '<leader>fw', '<cmd>lua require("telescope.builtin").grep_string()<CR>', opts)
  map('n', '<leader>fb', '<cmd>lua require("telescope.builtin").buffers()<CR>', opts)
  map('n', '<leader>fh', '<cmd>lua require("telescope.builtin").help_tags()<CR>', opts)
  map('n', '<leader>cp', '<cmd>lua require("CopilotChat.integrations.telescope").pick(require("CopilotChat.actions").prompt_actions())<CR>', { noremap = true, silent = true, desc = "CopilotChat - Prompt actions" })

  --
  map('n', '<leader>ft', ':NvimTreeToggle<CR>', opts)
  map('n', '<leader>fc', ':Neoformat<CR>', opts)
  map('n', '<leader>db', ':DB postgresql:dscout_development<CR>', opts)
  map('n', '<leader>k', ':lua custom_diagnostics()<CR>', opts)
  map('n', '<leader>K', ':lua pretty_diagnostics()<CR>', opts)
  map('n', '<leader>sss', 'luafile ~/.config/nvim/lua/config/functions.lua<CR>', opts)
  map('n', '<Leader>yy', ':let @+=getline(".")<CR>', opts)
  map('n', '<leader>yfp', ':let @+ = expand("%:p")<CR>', opts)

  -- LLM
  map('n', '<leader>ai', ':CodeCompanionActions<CR>', opts)

  map('n', 'gf', ':lua better_gf()<CR>', opts)
  map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

-- Visual mode mappings
map('v', '<Leader>y', '"+y', opts)
map('v', '<leader>lg', ':lua git_log_list()<CR>', opts)
map('v', '<leader>cp', ':CopilotChat' , { noremap = true, silent = true, desc = "CopilotChat - Prompt actions (with selection)" })

vim.keymap.set('v', '<leader>ai', function()
  vim.api.nvim_feedkeys(':CodeCompanion #buffer', 'n', false)
end, { desc = 'CodeCompanion for current buffer' })

-- Insert mode mappings
map('i', 'jj', '<esc>', opts)
