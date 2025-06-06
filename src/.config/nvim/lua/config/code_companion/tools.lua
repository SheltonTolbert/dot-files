--- Tools must implement the following interface
---
--- @class CodeCompanion.Tool
--- @field name string 
--- The name of the tool
--- @field cmds table
--- The commands to execute
--- @field schema table
--- The schema that the LLM must use in its response to execute a tool
--- @field system_prompt fun(schema: table): string
--- The system prompt to the LLM explaining the tool and the schema
--- @field opts? table
--- The options for the tool
--- @field env? fun(schema: table): table|nil
--- Any environment variables that can be used in the *_cmd fields. Receives the parsed schema from the LLM
--- @field handlers table
--- Functions which can be called during the execution of the tool
--- @field handlers.setup? fun(self: CodeCompanion.Tools): any
--- Function used to setup the tool. Called before any commands
--- @field handlers.approved? fun(self: CodeCompanion.Tools): boolean
--- Function to call if an approval is needed before running a command
--- @field handlers.on_exit? fun(self: CodeCompanion.Tools): any
--- Function to call at the end of all of the commands
--- @field output? table
--- Functions which can be called after the command finishes
--- @field output.rejected? fun(self: CodeCompanion.Tools, cmd: table): any
--- Function to call if the user rejects running a command
--- @field output.error? fun(self: CodeCompanion.Tools, cmd: table, error: table|string): any
--- Function to call if the tool is unsuccessful
--- @field output.success? fun(self: CodeCompanion.Tools, cmd: table, output: table|string): any
--- Function to call if the tool is successful
--- @field request table
--- The request from the LLM to use the Tool

local chat_tools = {
  ["cmd_runner"] = {
    callback = "strategies.chat.agents.tools.cmd_runner",
    description = "Run shell commands initiated by the LLM",
    opts = {
      requires_approval = true,
    },
  },
  ["editor"] = {
    callback = "strategies.chat.agents.tools.editor",
    description = "Update a buffer with the LLM's response",
  },
  ["files"] = {
    callback = "strategies.chat.agents.tools.files",
    description = "Update the file system with the LLM's response",
    opts = {
      requires_approval = true,
    },
  },
  ["get_review_requests"] = {
    description = "A list of PRs that are requesting your review",
    callback = function()
       return vim.fn.system("gh pr list --search 'review-requested:@me' --json number,title,author,state,url | jq")
    end
  },
  groups = {
    ["full_stack_dev_test"] = {
      description = "Full Stack Developer - Can run code, edit code and modify files",
      system_prompt =
      "**DO NOT** make any assumptions about the dependencies that a user has installed. If you need to install any dependencies to fulfil the user's request, do so via the Command Runner tool. If the user doesn't specify a path, use their current working directory.",
      tools = {
        "cmd_runner",
        "editor",
        "files",
      },
    },
  },
}

local tools = {
  chat_tools = chat_tools,
}

return tools
