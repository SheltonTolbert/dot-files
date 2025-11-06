require('minuet').setup {
      provider = 'gemini',
      enabled_ft = { 'toml', 'lua', 'cpp', 'elixir', 'js', 'python', 'py', 'js', 'ex', 'exs' },
      virtualtext = {
        auto_trigger_ft = { 'toml', 'lua', 'cpp', 'elixir', 'js', 'python', 'py', 'js', 'ex', 'exs' },
        keymap = {
            -- accept whole completion
            accept = '<S-Tab>',
            -- accept n lines (prompts for number)
            -- e.g. "A-z 2 CR" will accept 2 lines
            accept_n_lines = '<A-z>',
            -- Cycle to prev completion item, or manually invoke completion
            prev = '<A-[>',
            -- Cycle to next completion item, or manually invoke completion
            next = '<A-]>',
            dismiss = '<A-e>',
        },
    },
}
