require("render-markdown").setup(
  {
    completions = { lsp = { enabled = true } },
    render_modes = true,
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
    injections = {
        gitcommit = {
            enabled = true,
            query = [[
                ((message) @injection.content
                    (#set! injection.combined)
                    (#set! injection.include-children)
                    (#set! injection.language "markdown"))
            ]],
        },
    },
    anti_conceal = {
        enabled = true,
        -- Which elements to always show, ignoring anti conceal behavior. Values can either be booleans
        -- to fix the behavior or string lists representing modes where anti conceal behavior will be
        -- ignored. Possible keys are:
        --  head_icon, head_background, head_border, code_language, code_background, code_border
        --  dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
        ignore = {
            code_background = true,
            sign = true,
        },
        above = 0,
        below = 0,
    },
    heading = {
        enabled = true,
        sign = false,
        position = "overlay",
        -- icons = {"| ", "|| ", "|-| ", "|--| ", "|-=-| ", "|-==-| "},
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
    },
    bullet = {
      enabled = true,
      render_modes = false,
      icons = { '●', '○', '◆', '◇' },
      ordered_icons = function(ctx)
          local value = vim.trim(ctx.value)
          local index = tonumber(value:sub(1, #value - 1))
          return string.format('%d.', index > 1 and index or ctx.index)
      end,
      left_pad = 2,
      right_pad = 0,
      highlight = 'RenderMarkdownBullet',
      scope_highlight = {},
    },
  }
)
