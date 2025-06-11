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
require("plugins.mcp-hub") -- must come before codecompanion
require("plugins.code-companion")
require("plugins.gh")
require("plugins.navigator")
require("plugins.neoformat")
require("plugins.nvimtree")
require("plugins.telescope")
require("plugins.tree-sitter")
require("plugins.harpoon")
require("plugins.neotest")
require("plugins.notes")
require("plugins.hubworld.hubworld").setup({
  projects_file = vim.fn.stdpath("data") .. "/my_hubworld_data.json", -- Custom path for project data
  default_project_path = vim.fn.expand("~/my_projects"),             -- Default directory for new projects
  telescope_theme = "dropdown",                                     -- Theme for Telescope pickers
  auto_save_session = true,                                         -- Automatically save session on project switch
})
require("plugins.code_review").setup({
  -- Optional: custom config
  github_cli_path = "gh",  -- Path to GitHub CLI
  diff_command = "Gdiff",  -- Command for diff view
  keymap = {
    list_prs = "<leader>crl",  -- List PRs
    reset_review = "<leader>crr",  -- Reset review mode
    reset_filter = "<C-r>",  -- Reset file filter
  },
  enable_keymaps = true,  -- Whether to create default keymaps
})

-- lspconfig
-- require("lsp.elixir_ls")
-- require("lsp.typescript")
require("lsp.bash_ls")
require("lsp.css_modules")
require("lsp.go_pls")
require("lsp.lexical")
require("lsp.lspconfig")
require("lsp.typescript-tools")

