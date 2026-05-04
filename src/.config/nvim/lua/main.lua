-- Not working
-- sss keybind
-- popover styling
require("plugins/plug")

-- nvim config
require("config.auto_commands")
require("config.config")
require("config.functions")
require("config.keymaps")
require("config.theme")

-- plugins
require("plugins.render-markdown")
require("plugins.99")
-- require("plugins.devdocs")
-- require("plugins.mcp-hub")
-- require("plugins.minuet")
-- require("plugins.mini_complete")
-- require("plugins.code-companion")
require("plugins.gh")
require("plugins.neoformat")
require("plugins.nvimtree")
require("plugins.telescope")
require("plugins.tree-sitter")
require("plugins.auto-session")
-- require("plugins.notmuch")
-- require("plugins.harpoon")
-- require("plugins.neotest")
-- require("plugins.notes")

-- lspconfig
require("lsp.lspconfig")
-- require("lsp.tailwindcss")
-- require("lsp.bash_ls")
-- require("lsp.css_modules")
-- require("lsp.go_pls")
require("lsp.elixir_ls")
-- require("lsp.expert_ls")
require("lsp.typescript-tools")
-- require("lsp.pyright")
-- require("lsp.basedpyright")
-- require("lsp.ruff")
-- require("lsp.typescript")
