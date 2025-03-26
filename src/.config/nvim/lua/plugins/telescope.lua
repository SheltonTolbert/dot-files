local telescopeActions = require("telescope.actions")

require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<C-q>"] = telescopeActions.send_to_qflist
            },
            n = {
                ["<C-q>"] = telescopeActions.send_to_qflist
            }
        }
    }
}
