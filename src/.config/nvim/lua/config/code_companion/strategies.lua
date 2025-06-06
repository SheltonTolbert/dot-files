local tools = require("config.code_companion.tools")
local slash_commands = require("config.code_companion.slash_commands")

local strategies = {
  chat = {
    adapter = "copilot",
    keymaps = {
      send = {
        modes = {
          i = { "<C-CR>", "<C-n>" },
        },
      },
      completion = {
        modes = {
          i = { "<C-x>" },
        },
      },
    },
    slash_commands = slash_commands.chat_slash_commands,
    tools = tools.chat_tools,
  },
  inline = {
    keymaps = {
      accept_change = {
        modes = { n = "ga" },
        description = "Accept the change",
      },
      reject_change = {
        modes = { n = "gr" },
        description = "Reject the change",
      },
    },
  }
}

return strategies
