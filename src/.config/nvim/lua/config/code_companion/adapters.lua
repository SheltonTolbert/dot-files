local gemini = require("config.code_companion.adapters.gemini")

local adapters = {
  http = {
    gemini = gemini,
    copilot = function()
      return require("codecompanion.adapters").extend("copilot", {
        schema = {
          model = {
            default = "claude-3.7-sonnet",
          },
        },
      })
    end,
    local_ollama = function()
      return require("codecompanion.adapters").extend("ollama", {
        opts = {
          base_url = "http://192.168.0.152:11434",
        },
        name = "local_ollama",
        schema = {
          model = {
            default = "deepseek-r1:8b",
          },
          num_ctx = {
            default = 16384,
          },
        },
      })
    end,
  },
}

return adapters
