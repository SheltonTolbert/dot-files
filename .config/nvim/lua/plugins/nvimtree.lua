  local function my_on_attach(bufnr)
    local api = require "nvim-tree.api"

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    -- vim.keymap.set("n", "<TAB>", api.node.show_info_popup, opts("Info"))
  end

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  update_focused_file = { enable = true },
  view = {
    adaptive_size = true,
  },
  filesystem_watchers = {
    enable = false,
  },
  git = {
    enable = false,
  },
  renderer = {
    group_empty = false,
    indent_markers = {
        enable = true,
    },
    icons = {
      show = {
        hidden = true
      }
    }
  },
  filters = {
    dotfiles = false,
  },
})
