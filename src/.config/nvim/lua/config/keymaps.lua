-- Set leader key
vim.g.mapleader = " "

-- Define key mappings
local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}
-- local copilotChatActions = require("CopilotChat.actions")

-- Normal mode mappings
map("n", "<leader>o", ":vertical :G<CR>", opts)

map("n", "<leader>p", '<cmd>lua require("telescope.builtin").find_files({hidden = true})<CR>', opts)
map("n", "<leader>v", ":vsp<CR>", opts)
map("n", "<leader>h", ":sp<CR>", opts)
map("n", "<leader>hw", ":Hubworld<CR>", opts)
map("n", "<leader>co", ":copen<CR>", opts)

-- map("n", "<leader>co", ":lua quickfix()<CR>", opts)
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
map("n", "<leader>ss", "<cmd>Telescope session-lens<CR>", opts)
vim.keymap.set("n", "<leader>sn", function()
  vim.ui.input({ prompt = "Session name: " }, function(name)
    if not name or name == "" then
      return
    end
    vim.cmd("AutoSession save " .. vim.fn.fnameescape(name))
  end)
end, { silent = true })
--
map("n", "<leader>ft", ":NvimTreeToggle<CR>", opts)
map("n", "<leader>fc", ":lua vim.lsp.buf.format()<CR>", opts)
map("n", "<leader>k", ":lua custom_diagnostics()<CR>", opts)
map("n", "<leader>K", ":lua pretty_diagnostics()<CR>", opts)
map("n", "<leader>sss", ":luafile ~/.config/nvim/lua/config/functions.lua<CR>", opts)
map("n", "<Leader>yy", ':let @+=getline(".")<CR>', opts)
map("n", "<leader>yfp", ':let @+ = expand("%:p")<CR>', opts)

-- LLM
vim.keymap.set("n", "<leader>ais", function()
  require("99").search()
end, { desc = "99 search" })

vim.keymap.set("n", "<leader>aix", function()
  require("99").stop_all_requests()
end, { desc = "99 stop all requests" })

vim.keymap.set("n", "<leader>ail", function()
  require("99").view_logs()
end, { desc = "99 logs" })

vim.keymap.set("n", "<leader>aiq", function()
  require("99").previous_requests_to_qfix()
end, { desc = "99 previous requests" })

map("n", "gf", ":lua better_gf()<CR>", opts)
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

-- Visual mode mappings
map("v", "<Leader>y", '"+y', opts)
map("v", "<leader>lg", ":lua git_log_list()<CR>", opts)
vim.keymap.set("v", "<leader>aiv", function()
  require("99").visual()
end, { desc = "99 visual" })

-- Insert mode mappings
map("i", "jj", "<esc>", opts)
