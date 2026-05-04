local session_root = vim.fn.stdpath("state") .. "/sessions/"

require("auto-session").setup({
  auto_save = true,
  auto_restore = true,
  auto_create = false,
  root_dir = session_root,
  post_restore_cmds = { "NvimTreeClose", "NvimTreeOpen" },
})

require("session-lens").setup({
  path_display = { "shorten" },
  theme_conf = { border = true },
})

require("telescope").load_extension("session-lens")
