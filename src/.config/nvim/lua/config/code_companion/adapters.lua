local gemini = require("config.code_companion.adapters.gemini")

local adapters = {
  gemini = gemini,
  copilot = function()
    return require("codecompanion.adapters").extend("copilot", {
      schema = {
        model = {
          default = "claude-3.7-sonnet",
        },
      },
    })
  end
}

return adapters
