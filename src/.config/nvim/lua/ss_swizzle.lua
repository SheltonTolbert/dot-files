-- Not working
  -- sss keybind
  -- cmp popover styling
require("plugins/plug")

-- nvim config
require("config.functions")
require("config.theme")
require("config.keymaps")
require("config.config")
require("config.auto_commands")

-- plugins
require("plugins.telescope")
require("plugins.cmp")
require("plugins.nvimtree")
require("plugins.navigator")
require("plugins.gh")
require("plugins.tree-sitter")
require("plugins.render-markdown")
require("plugins.neoformat")
require("plugins.code-companion")

-- lspconfig
require("lsp.lspconfig")
require("lsp.typescript-tools")
-- require("lsp.elixir_ls")
require("lsp.css_modules")
require("lsp.go_pls")
require("lsp.bash_ls")
-- require("lsp.typescript")
require("lsp.lexical")

