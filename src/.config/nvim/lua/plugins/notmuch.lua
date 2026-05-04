require("notmuch").setup({
  opts = {
    notmuch_db_path = "/Users/sheltontolbert/Mail/",
    maildir_sync_cmd = "mbsync personal",
    sync = {
      sync_mode = "buffer"
    },
    keymaps = {
      sendmail = "<C-g><C-g>",
    },
  },
})
