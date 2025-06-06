local display = {
  action_palette = {
    width = 95,
    height = 10,
    prompt = "Prompt ",                      -- Prompt used for interactive LLM calls
    provider = "telescope",                  -- default|telescope|mini_pick
    opts = {
      show_default_actions = true,           -- Show the default actions in the action palette?
      show_default_prompt_library = true     -- Show the default prompt library in the action palette?
    }
  },
  diff = {
    enabled = false
  }
}
return display
