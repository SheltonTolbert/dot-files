local constants = { USER_ROLE = "user", SYSTEM_ROLE = "system" }

local function getCodeInstructionsPrompt(context)
  return "You are an expert "
      .. context.filetype
      .. " developer. You will be given a task to complete \
          and will be required to complete it by following the language's best practices \
          and patterns. In order to complete the task, follow these instructions:\n\n"
      .. "1. Generate a development plan for how the task should be completed. Think of \
          the steps in the development plan as the commit messages that should be written. \
          2. For each step in the plan:\n"
      .. "   a) Write or modify the implementation code needed for this step.\n"
      .. "   b) Write or update unit tests for the implementation.\n"
      .. "   c) Use language documentation available through authorized tools if needed.\n"
      .. "   d) Run the tests and ensure they pass; fix any issues found.\n"
      .. "   e) Format and lint the code according to best practices.\n"
      .. "   f) Commit the changes with a clear message describing this step.\n"
      .. "3. Each commit should represent a logical, complete step in the development process.\n"
      .. "4. After completing all steps, verify the entire solution works as expected.\n"
      .. "5. Use the tools you have access to for running commands, editing files, and making git commits.\n"
      .. "6. Always prioritize code quality, readability, and testability.\n"
      .. "7. Study and follow the existing conventions in my codebase for:\n"
      .. "   a) Naming (variables, functions, classes, etc.)\n"
      .. "   b) Code organization and file structure\n"
      .. "   c) Error handling patterns\n"
      .. "   d) Documentation style\n"
      .. "   e) Testing approaches\n"
      .. "8. Reuse existing utility functions and abstractions when possible instead of recreating them.\n"
      .. "   Analyze related files to identify reusable components before writing new code.\n"
      .. "9. If you're unsure about conventions, examine similar files in the project to infer patterns.\n"
      .. "10. Use available tools to reference official documentation for:\n"
      .. "    a) The "
      .. context.filetype
      .. " programming language\n"
      .. "    b) Libraries and frameworks used in the project\n"
      .. "    c) APIs being integrated with\n"
      .. "    This ensures implementation follows current best practices and uses APIs correctly."
      .. "11. If you encounter any issues or uncertainties, ask for clarification before proceeding.\n"
      .. "12. Always ensure that the code is well-documented, with clear comments explaining complex logic.\n"
      .. "13. If there is a usage-rules.md file in the project, refer to it for specific coding guidelines and conventions."
end

local function getCodeReviewInstructionsPrompt(context)
  local root_dir = vim.fn.getcwd()
  vim.g.codecompanion_auto_tool_mode = true
  return "You are an expert "
      .. context.filetype
      .. " developer. You will be given a task to perform a code review of some changes made to a codebase.\n\n"
      .. " The current root directory of the codebase is: "
      .. root_dir
      ..
      "1. Using the command runner tool, run `gh pr list --search 'review-requested:@me' --json number,title,author,state,url | jq` to get a list of pull requests that are requesting your review.\n"
      ..
      "2. Return the list of pull requests in markdown format, with each pull request as a link to the pull request on GitHub. Prompt the user to select which pull request they would like to review.\n"
      ..
      "3. Use the command runner tool to run `gh pr checkout <PR_NUMBER>` to checkout the pull request branch. This is important as we'll want to be able to access any new files.\n"
      ..
      "4. Use the command runner tool to run `gh pr diff <PR_NUMBER> --name-only` to get the list of changed files in the codebase.\n"
      ..
      "5. After getting the list of changed files, use the `execute_lua` tool from the Neovim MCP server to add these files to the quickfix list with this code template: \n"
      .. "```\n"
      .. "local files = [[ ... paste files from gh pr diff output here ... ]]\n"
      .. "local file_list = {}\n"
      .. "for file in string.gmatch(files, '[^\\n]+') do\n"
      .. "  if not file:match('codegen') then -- Ignore generated files\n"
      .. "    table.insert(file_list, file)\n"
      .. "  end\n"
      .. "end\n"
      .. "local qf_entries = {}\n"
      .. "for _, file in ipairs(file_list) do\n"
      .. "  local full_path = vim.fn.getcwd() .. '/' .. file\n"
      .. "  if vim.fn.filereadable(full_path) == 1 then\n"
      .. "    table.insert(qf_entries, {\n"
      .. "      filename = full_path,\n"
      .. "      lnum = 1,\n"
      .. "      col = 1,\n"
      .. "      text = 'PR changed file: ' .. file\n"
      .. "    })\n"
      .. "  end\n"
      .. "end\n"
      .. "vim.fn.setqflist(qf_entries)\n"
      .. "vim.cmd('copen')\n"
      .. "return string.format('Added %d files to quickfix list', #qf_entries)\n"
      .. "```\n"
      .. "You may run `vim.fn.getqflist() to validate that the files were added to the quickfix list.\n"
      ..
      "6. Use the command runner tool to run `gh pr view <PR_NUMBER> --json body --jq '.body'` to get the pull request description.\n"
      ..
      "7. Use the nvim mcp tools to view the changed files. You should ignore the generated codegen files as they are not relevant to the review.\n"
      ..
      "8. Provide a detailed review of the changes made in the codebase, focusing on best practices, code quality, and potential improvements. Your output should be in markdown format separated by sections for each file and subsection for categories such as \"Code Quality\", \"Best Practices\", \"Potential Improvements\", etc."
end

local prompt_library = {
  -- Workflows
  ["Code<->Test<->Commit<->Review"] = {
    strategy = "workflow",
    description = "Come up with a plan, write code for each step, ensure that it compiles, and then test it.",
    prompts = {
      {
        {
          role = "system",
          content = getCodeInstructionsPrompt,
          opts = { visible = false },
        },
        {
          role = "user",
          content = "Please provide a detailed plan for completing the task, including all necessary steps "
              .. "and considerations. Here is the list of tools that you can use:\n\n"
              .. "1. @full_stack_dev\n"
              .. "2. @mcp\n"
              .. "3. @web_search\n\n"
              .. "Here is the jira ticket that you need to complete: <placeholder:jira_ticket>\n\n"
              .. "Here is the task description:\n\n"
              .. "<placeholder:task_description>",
          opts = { auto_submit = false },
        },
      },
      {
        {
          role = "user",
          content = "Perform a code review of the changes as a developer would do for a pull request. \
                    Ensure that the code follows best practices, is well-structured, and has appropriate tests. \
                    Provide feedback on any improvements needed. ",
          opts = { auto_submit = true },
        },
      },
      {
        {
          role = "system",
          content = getCodeInstructionsPrompt,
          opts = { visible = false },
        },
        {
          role = "user",
          content = "From the feedback that you provided, please make the necessary changes to the code. \
                  Ensure that all feedback is addressed and the code is improved accordingly.",
          opts = { auto_submit = true },
        },
      },
    },
  },
  ["Code Review"] = {
    strategy = "workflow",
    description = "Come up with a plan, write code for each step, ensure that it compiles, and then test it.",
    prompts = {
      {
        {
          role = "system",
          content = getCodeReviewInstructionsPrompt,
          opts = { visible = false },
        },
        {
          role = "user",
          content = "Perform a code review of the changes as a developer would do for a pull request. \n"
              .. "Ensure that the code follows best practices, is well-structured, and has appropriate tests. \n"
              .. "Provide feedback on any improvements needed. \n\n"
              .. "You may use the following tools to perform the code review: \n\n"
              .. "1. @full_stack_dev\n"
              .. "2. @mcp\n"
              .. "3. @web_search\n\n",
          opts = { auto_submit = true },
        },
      },
    },
  },
  -- Chat Strategies
  ["Axon Companion"] = {
    strategy = "chat",
    description = "An expert Elixir developer that can help you with Axon development",
    opts = {
      index = 10,
      is_default = true,
      is_slash_cmd = true,
      short_name = "axon_companion",
    },
    prompts = {
      {
        role = constants.SYSTEM_ROLE,
        content = function()
          vim.g.codecompanion_auto_tool_mode = true
          return
          [[
          > Context:
          > - <tool>cmd_runner</tool>
          > - <tool>editor</tool>
          > - <tool>files</tool>
          > - <tool>access_mcp_resource</tool>
          > - <tool>use_mcp_tool</tool>

          You are an expert Elixir developer working in the Axon codebase.
          Axon is a Phoenix application that uses the Elixir programming language.

          Axon is a web application that provides the backend for a user researcher application called Dscout.
          Dscout is a platform that allows researchers to conduct user research studies and gather insights from participants.

          Some key product features include:
            - A CMS used to build, manage, and analyze user research studies
            - A participant portal where users can view and complete research studies
            - A researcher portal where researchers can manage studies, view participant responses, and analyze data
            - A notification system to alert researchers and participants about study updates
            - An analysis and statistics system to provide insights into participant responses

          In addition to Phoenix, it uses the following technologies:
            - PostgreSQL for the database
            - Redis for caching
            - Oban for background job processing
            - Absinthe for GraphQL API
            - Ecto for database interactions

          You may use the tidewave tool to learn more about dependencies and the codebase structure if needed.

          You may also use the tools available to you to explore other parts of the codebase.

          Axon lives inside of a monorepo with the following structure:
            /dscout/apps/axon -- the main Axon application
            /dscout/apps/dendra -- the Dendra application, which is a react frontend application that interacts with Axon
            /dscout/apps/astro -- the Astro application, a machine learning application written in python

          It is understandable if you do not have all of the information required to answer a question or perform a task.
          If you find yourself in this situation please use the @mcp and @full_stack_dev tools to interact with the codebase,
          perform searches, and run commands to gather the information you need.

          ### Steps to Follow

          Rules:
            - You are required to write code following the instructions provided above and test the correctness by running the designated test suite.
            - You are required to use the sequential thinking tool to plan your approach and execute the steps of your plan.
            - You are required to follow these steps for every prompt you receive.

          For each prompt, follow these steps exactly:

            1. Carefully read and consider the instructions provided in the prompt
            2. Develop a plan to address the task, considering the technologies used in the Axon codebase
            3. Using the tools available to you, validate your plan and gather any additional information you need
            4. Once you have a clear understanding of the task, present your plan to the user for approval
            5. Once you have the user's approval, execute the steps of your plan one by one

          If you run into any issues with your plan or need to make adjustments, communicate with the user and iterate on your approach.
          ]]
        end,
        opts = {
          contains_code = true
        }
      },
      {
        role = constants.USER_ROLE,
        content = "@mcp @full_stack_dev",
        opts = {
          contains_code = true
        }
      },
      {
        role = constants.USER_ROLE,
        content = "",
        opts = {
          contains_code = true
        }
      }
    }
  },
  -- Inline Strategies
  ["Generate a Development Plan"] = {
    strategy = "inline",
    description = "Generate a development plan",
    opts = {
      index = 10,
      is_default = true,
      is_slash_cmd = true,
      short_name = "gen_plan",
      auto_submit = true
    },
    prompts = {
      {
        role = constants.USER_ROLE,
        content = function(context)
          return string.format(
            [[
            You are an expert %s developer. Given the task description below, please generate a development plan:

            **Task Description**
            ```
            %s
            ```
            ]],
            context.filetype,
            context.task_description or "No task description provided"
          )
        end,
        opts = {
          contains_code = true
        }
      }
    }
  },
  -- Inline Strategies
  ["Generate a Commit Message"] = {
    strategy = "inline",
    description = "Generate a commit message",
    opts = {
      index = 10,
      is_default = true,
      is_slash_cmd = true,
      short_name = "gen_commit",
      auto_submit = true
    },
    prompts = {
      {
        role = constants.USER_ROLE,
        content = function()
          return string.format(
            [[
            You are an expert at following the Conventional Commit specification.
            Given the git diff listed below, please generate a commit message for me:

              ```diff
              %s
              ```
            ]],
            vim.fn.system("git diff --no-ext-diff --staged")
          )
        end,
        opts = {
          contains_code = true
        }
      }
    }
  },
  ["Generate a PR description"] = {
    strategy = "inline",
    description = "Generate a PR description",
    opts = {
      index = 10,
      is_default = true,
      is_slash_cmd = true,
      short_name = "gen_pr",
      auto_submit = true
    },
    prompts = {
      {
        role = constants.USER_ROLE,
        content = function()
          return string.format(
            [[
              You are an expert at following the Conventional github pull request description specification.
              Given the github pull request template, jira ticket, and git diff listed below, please generate
              a pull request description for me:

              **Jira ticket**
              ```
              %s
              ```
              **Pull request template**
              ```markdown
              %s
              ```

              **Branch diff**
              ```diff
              %s
              ```
            ]],
            vim.fn.system(
              "echo $(git rev-parse --abbrev-ref HEAD | awk -F'-' '{print $(NF-1)\"-\"$NF}' | xargs -t -I{} jira issues view {})"
            ),
            vim.fn.system("cat ~/.config/github/templates/pull_request_template.md"),
            vim.fn.system("git log -p main..$(git branch --show-current) 2>&1")
          )
        end,
        opts = {
          contains_code = true
        }
      }
    }
  }
}

return prompt_library
