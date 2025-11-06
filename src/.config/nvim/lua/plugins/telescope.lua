local telescopeActions = require("telescope.actions")

require("telescope").setup {
    defaults = {
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
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
