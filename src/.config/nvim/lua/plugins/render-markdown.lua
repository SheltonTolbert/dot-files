require("render-markdown").setup(
    {
        code = {
            enabled = true,
            sign = false,
            style = "full",
            position = "left",
            language_pad = 0,
            language_name = true,
            disable_background = {"diff"},
            width = "block",
            left_margin = 0,
            left_pad = 4,
            right_pad = 0,
            min_width = 100,
            border = "thick",
            above = "▄",
            below = "▀",
            highlight = "RenderMarkdownCode",
            highlight_inline = "RenderMarkdownCodeInline",
            highlight_language = nil
        },
        heading = {
            enabled = true,
            sign = false,
            position = "overlay",
            icons = {"| ", "|| ", "|-| ", "|--| ", "|-=-| ", "|-==-| "},
            signs = {"󰫎 "},
            width = "full",
            left_margin = 0,
            left_pad = 0,
            right_pad = 0,
            min_width = 0,
            border = false,
            border_virtual = false,
            border_prefix = false,
            above = "▄",
            below = "▀",
            backgrounds = {
                "@markup",
                "@markup.strong",
                "@markup.heading",
                "@markup.link",
                "@diff.delta",
                "@tag"
            },
            foregrounds = {
                "@markup",
                "@markup.strong",
                "@markup.heading",
                "@markup.link",
                "@diff.delta",
                "@tag"
            }
        }
    }
)
