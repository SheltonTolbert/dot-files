local fmt = string.format

local constants = {
  LLM_ROLE = "llm",
  USER_ROLE = "user",
  SYSTEM_ROLE = "system"
}

local workflows = {
  ["PR description"] = {
    strategy = "workflow",
    description = "Use a workflow to generate a PR description",
    opts = {
      index = 4,
      is_default = true,
      short_name = "pr_desc",
    },
    prompts = {
      {
        {
          name = "Setup Test",
          role = constants.USER_ROLE,
          opts = { auto_submit = false },
          content = function()
            -- Enable turbo mode!!!
            vim.g.codecompanion_auto_tool_mode = true

            return [[### Instructions

Your instructions here

### Steps to Follow

You are required to write code following the instructions provided above and test the correctness by running the designated test suite. Follow these steps exactly:

1. Update the code in #buffer{watch} using the @editor tool
2. Then use the @cmd_runner tool to run the test suite with `<test_cmd>` (do this after you have updated the code)
3. Make sure you trigger both tools in the same response

We'll repeat this cycle until the tests pass. Ensure no deviations from these steps.]]
          end
        }
      },
      {
        {
          name = "Repeat On Failure",
          role = constants.USER_ROLE,
          opts = { auto_submit = true },
          -- Scope this prompt to the cmd_runner tool
          condition = function()
            return vim.g.codecompanion_current_tool == "cmd_runner"
          end,
          -- Repeat until the tests pass, as indicated by the testing flag
          -- which the cmd_runner tool sets on the chat buffer
          repeat_until = function(chat)
            return chat.tool_flags.testing == true
          end,
          content = "The tests have failed. Can you edit the buffer and run the test suite again?"
        }
      }
    }
  }
}

return workflows
