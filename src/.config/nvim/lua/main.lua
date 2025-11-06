-- Not working
-- sss keybind
-- cmp popover styling
require("plugins/plug")

-- nvim config
require("config.auto_commands")
require("config.config")
require("config.functions")
require("config.keymaps")
require("config.theme")

-- plugins
require("plugins.cmp")
require("plugins.render-markdown")
-- require("plugins.devdocs")
require("plugins.mcp-hub") -- must come before codecompanion
-- require("plugins.minuet")
-- require("plugins.mini_complete")
require("plugins.code-companion")
require("plugins.gh")
require("plugins.neoformat")
require("plugins.nvimtree")
require("plugins.telescope")
require("plugins.tailwind_tools")
require("plugins.tree-sitter")
-- require("plugins.harpoon")
-- require("plugins.neotest")
-- require("plugins.notes")

-- lspconfig
require("lsp.tailwindcss")
require("lsp.bash_ls")
require("lsp.css_modules")
require("lsp.go_pls")
require("lsp.lexical")
require("lsp.lspconfig")
require("lsp.typescript-tools")
-- require("lsp.pyright")
require("lsp.basedpyright")
require("lsp.ruff")
-- require("lsp.typescript")
