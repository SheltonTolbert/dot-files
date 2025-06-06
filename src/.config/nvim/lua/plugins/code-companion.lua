local prompt_library = require("config.code_companion.prompt_library")
local extensions = require("config.code_companion.extensions")
local display = require("config.code_companion.display")
local adapters = require("config.code_companion.adapters")
local strategies = require("config.code_companion.strategies")

local LOG_LEVEL = "TRACE"

require("codecompanion").setup(
  {
    adapters = adapters,
    display = display,
    extensions = extensions,
    prompt_library = prompt_library,
    strategies = strategies,
    workflows = workflows,
    opts = {
      log_level = LOG_LEVEL
    }
  }
)
