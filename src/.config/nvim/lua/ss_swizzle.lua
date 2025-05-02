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
require("plugins.code-companion")
require("plugins.devdocs")
require("plugins.gh")
require("plugins.navigator")
require("plugins.neoformat")
require("plugins.nvimtree")
require("plugins.render-markdown")
require("plugins.telescope")
require("plugins.tree-sitter")
require("plugins.harpoon")

-- lspconfig
-- require("lsp.elixir_ls")
-- require("lsp.typescript")
require("lsp.bash_ls")
require("lsp.css_modules")
require("lsp.go_pls")
require("lsp.lexical")
require("lsp.lspconfig")
require("lsp.typescript-tools")

