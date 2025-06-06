-- slash commands for the chat strategy
local chat_slash_commands = {
  ["buffer"] = {
    callback = "strategies.chat.slash_commands.buffer",
    description = "Select a file using Telescope",
    opts = {
      provider = "telescope",
    },
  },
  ["file"] = {
    callback = "strategies.chat.slash_commands.file",
    description = "Select a file using Telescope",
    opts = {
      provider = "telescope",
      contains_code = true,
    },
  },
  ["git_files"] = {
    description = "List git files",
    callback = function(chat)
      local handle = io.popen("git ls-files")
      if handle ~= nil then
        local result = handle:read("*a")
        handle:close()
        chat:add_reference({ role = "user", content = result }, "git", "<git_files>")
      else
        return vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
      end
    end,
    opts = {
      contains_code = false,
    },
  },
}

return { chat_slash_commands = chat_slash_commands }
