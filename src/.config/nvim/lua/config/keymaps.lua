-- Set leader key
vim.g.mapleader = " "

-- Define key mappings
local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}

quickfix = require("telescope.builtin").quickfix

-- local copilotChatActions = require("CopilotChat.actions")

-- Normal mode mappings
map("n", "<leader>p", ":Files<CR>", opts)
map("n", "<leader>v", ":vsp<CR>", opts)
map("n", "<leader>h", ":sp<CR>", opts)
map("n", "<leader>co", ":copen<CR>", opts)

map("n", "<leader>co", ":lua quickfix()<CR>", opts)
map("n", "<leader>cd", ":call setqflist([])<CR>", opts)
map("n", "<leader>b", ":Buffers<CR>", opts)
map("n", "ml", ":lua list_marked_files()<CR>", opts)
map("n", "mb", ":lua mark_current_file()<CR>", opts)
map("n", "<leader>U", ":lua unmark_current_file()<CR>", opts)
map("n", "<leader>m", ":lua view_mark_groups_selector()<CR>", opts)

map("n", "<leader>gh", ":FzfLua register_ui_select<CR>", opts)
map("n", "<leader>td", '<cmd>lua require("telescope.builtin").lsp_definitions()<CR>', opts)
map("n", "<leader>tg", '<cmd>lua require("telescope.builtin").git_status()<CR>', opts)

-- telescope
map("n", "gd", '<cmd>lua require("telescope.builtin").lsp_definitions()<CR>', opts)
map("n", "ft", '<cmd>lua require("telescope.builtin").lsp_type_definitions()<CR>', opts)
map("n", "fi", '<cmd>lua require("telescope.builtin").lsp_incoming_calls()<CR>', opts)
map("n", "fo", '<cmd>lua require("telescope.builtin").lsp_outgoing_calls()<CR>', opts)
map("n", "fr", '<cmd>lua require("telescope.builtin").lsp_references()<CR>', opts)
map("n", "<leader>ff", '<cmd>lua require("telescope.builtin").live_grep()<CR>', opts)
map("n", "<leader>fw", '<cmd>lua require("telescope.builtin").grep_string()<CR>', opts)
map("n", "<leader>fb", '<cmd>lua require("telescope.builtin").buffers()<CR>', opts)
map("n", "<leader>fh", '<cmd>lua require("telescope.builtin").help_tags()<CR>', opts)
map(
    "n",
    "<leader>cp",
    '<cmd>lua require("CodeCompanion.integrations.telescope").pick(require("CodeCompanion.actions").prompt_actions())<CR>',
    {noremap = true, silent = true, desc = "CodeCompanionChat - Prompt actions"}
)

--
map("n", "<leader>ft", ":NvimTreeToggle<CR>", opts)
map("n", "<leader>fc", ":Neoformat<CR>", opts)
map("n", "<leader>k", ":lua custom_diagnostics()<CR>", opts)
map("n", "<leader>K", ":lua pretty_diagnostics()<CR>", opts)
map("n", "<leader>sss", "luafile ~/.config/nvim/lua/config/functions.lua<CR>", opts)
map("n", "<Leader>yy", ':let @+=getline(".")<CR>', opts)
map("n", "<leader>yfp", ':let @+ = expand("%:p")<CR>', opts)
vim.keymap.set('n', '<leader>db', function()
  vim.api.nvim_feedkeys(':DB postgresql:dscout_development ', 'n', false)
end, { desc = 'Query dscout_development' })

-- LLM
map("n", "<leader>ai", ":CodeCompanionActions<CR>", opts)

map("n", "gf", ":lua better_gf()<CR>", opts)
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

-- Visual mode mappings
map("v", "<Leader>y", '"+y', opts)
map("v", "<leader>lg", ":lua git_log_list()<CR>", opts)
map(
    "v",
    "<leader>cp",
    ":CodeCompanionChat<CR>",
    {noremap = true, silent = true, desc = "CopilotChat - Prompt actions (with selection)"}
)

vim.keymap.set('v', '<leader>ai', function()
  vim.api.nvim_feedkeys(':CodeCompanion #buffer', 'n', false)
end, { desc = 'CodeCompanion for current buffer' })

-- Insert mode mappings
map("i", "jj", "<esc>", opts)
