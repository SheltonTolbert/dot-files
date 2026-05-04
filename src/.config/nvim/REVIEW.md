# Neovim Config Review

## Bugs

### 1. Deprecated `vim.lsp.buf.formatting()` — `elixir_ls.lua:11`
```lua
vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
```
Should be `vim.lsp.buf.format()`. This will error on modern Neovim.

### 2. Deprecated `nvim_get_hl_by_name` — `theme.lua:18`
```lua
local current_def = vim.api.nvim_get_hl_by_name(name, true)
```
Removed in Neovim 0.9+. Use `vim.api.nvim_get_hl(0, { name = name, link = false })`.

### 3. Deprecated `nvim_buf_set_option` — `functions.lua:98`
```lua
vim.api.nvim_buf_set_option(bufnr, 'filetype', 'diff')
```
Use `vim.bo[bufnr].filetype = 'diff'` instead.

### 4. `list_marked_files()` checks wrong table — `functions.lua:221`
```lua
if #MARKED_FILES == 0 then  -- checks the top-level table, not the current group
```
Should be `#MARKED_FILES[CURRENT_MARKED_GROUP] == 0`.

### 5. `better_gf()` calls `get_file()` instead of `M.get_file()` — `functions.lua:39`
The local function uses `get_file(file_string)` but the method is defined as `M.get_file`. It works only because you alias it to `_G.get_file` at the bottom, but this creates a load-order dependency — if `better_gf` is called before the `_G` assignments run, it will error.

### 6. `keymaps.lua:63` — missing colon
```lua
map("n", "<leader>sss", "luafile ~/.config/nvim/lua/config/functions.lua<CR>", opts)
```
Missing the leading `:` — should be `":luafile ..."`. This keymap does nothing.

### 7. `keymaps.lua:7` — eager `require` at top level
```lua
local quickfix = require("telescope.builtin").quickfix
```
This is loaded but never used (the keymaps use string commands). It forces telescope to load at startup for no reason.

### 8. `BranchIssue()` is defined outside module `M` — `functions.lua:2`
It's a global function leak, not attached to the module table.

---

## Performance

### 9. vim-plug instead of lazy.nvim
You're loading ~40+ plugins eagerly at startup with vim-plug. Migrating to `lazy.nvim` would let you lazy-load by filetype, event, or command and could cut startup time significantly (often 2-5x).

### 10. Duplicate plugin functionality
- Both `fzf`/`fzf.vim` AND `fzf-lua` AND `telescope` are installed — three fuzzy finders. Pick one (telescope seems to be your primary) and drop the others.
- Both `nvim-cmp` (with 5 cmp-* plugins) AND `mini.completion` are installed. You're using the native `vim.lsp.completion.enable` in your autocmd, so both cmp and mini.completion appear unused.
- Both `vim-gitgutter` AND `gitsigns` are in the plug file (gitsigns commented out). gitgutter is vimscript — gitsigns is faster and lua-native.

### 11. Forced GC timer — `config.lua:122-127`
The `collectgarbage("collect")` every 5 minutes on a `vim.loop` timer can cause micro-stutters. Lua's incremental GC is usually fine on its own. If you do keep it, `collectgarbage("step", 200)` is less aggressive than a full collect.

### 12. Treesitter highlight `disable` function returns nil — `tree-sitter.lua:7-13`
The disable callback is defined but the large-file check is commented out, so it returns nil every time. Either uncomment the size check or remove the function entirely to avoid the overhead of calling it on every buffer.

### 13. NvimTree has `filesystem_watchers` and `git` disabled
Disabling watchers means the tree won't auto-refresh when files change externally. If this was intentional for perf, it's fine, but worth noting.

---

## Quality of Life Improvements

### 14. Standardize keymap API
You mix `vim.api.nvim_set_keymap` / `vim.api.nvim_buf_set_keymap` with `vim.keymap.set`. The latter supports lua function callbacks, `desc` for which-key, and is the modern standard. Standardizing makes all keymaps discoverable.

### 15. No `which-key.nvim`
With 40+ custom keymaps and no descriptions on most of them, discoverability is poor. `folke/which-key.nvim` would show available keymaps on leader press with zero config overhead.

### 16. No statusline plugin
You have `showmode = false` but no lualine/mini.statusline. Adding `nvim-lualine/lualine.nvim` or `echasnovski/mini.statusline` gives you branch, diagnostics, filetype, and cursor position at a glance.

### 17. No autopairs
You have `vim-closetag` for HTML but no general autopair for `()`, `{}`, `[]`, `""`. `windwp/nvim-autopairs` or `echasnovski/mini.pairs` would help.

### 18. No indent guides
`lukas-reineke/indent-blankline.nvim` shows indentation levels — very useful in deeply nested Elixir/JS code.

### 19. Global namespace pollution — `functions.lua:237-249`
You put ~12 functions into `_G`. A cleaner approach is using `vim.keymap.set` with lua function callbacks directly, avoiding globals entirely.

### 20. Hardcoded path — `config.lua:113`
```lua
vim.opt.path:append(".,,/Users/sheltontolbert/repos/dscout/apps/dendra/src/**")
```
This only works on your machine and for one project. Consider making this project-specific via `.nvim.lua` or an exrc pattern.

### 21. Consider `folke/trouble.nvim`
You have custom diagnostic float functions. Trouble gives you a persistent diagnostics panel, quickfix replacement, and LSP references list — would replace `custom_diagnostics()` and `pretty_diagnostics()` with something more featureful.

### 22. Consider `stevearc/oil.nvim`
As an alternative/complement to nvim-tree, oil.nvim lets you edit the filesystem like a buffer (rename files by editing text). Great paired with a tree viewer.

### 23. Consider `lewis6991/gitsigns.nvim` over `vim-gitgutter`
You already have it commented out in plug.lua. gitsigns is pure Lua, faster, and supports inline blame, hunk staging, and hunk preview natively.

### 24. Session-lens is archived
`rmagatti/session-lens` hasn't been updated in a while and auto-session now has built-in telescope support. You can replace `<leader>ss` with `:Telescope session-lens` from auto-session directly or use the built-in session search.

---

## Summary of Priority Fixes

| Priority | Item | File |
|----------|------|------|
| Bug | `formatting()` -> `format()` | `elixir_ls.lua:11` |
| Bug | `nvim_get_hl_by_name` deprecated | `theme.lua:18` |
| Bug | Missing `:` in keymap | `keymaps.lua:63` |
| Bug | Wrong table checked in `list_marked_files` | `functions.lua:221` |
| Perf | Remove duplicate fuzzy finders (fzf + fzf-lua + telescope) | `plug.lua` |
| Perf | Remove unused cmp/mini.completion plugins | `plug.lua` |
| QOL | Add `which-key.nvim` | - |
| QOL | Add `lualine.nvim` or `mini.statusline` | - |
| QOL | Switch `vim-gitgutter` to `gitsigns.nvim` | `plug.lua` |
| QOL | Migrate to `lazy.nvim` | `plug.lua` |
