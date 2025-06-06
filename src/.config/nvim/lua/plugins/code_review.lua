-- code_review.lua
-- A Neovim plugin for GitHub PR code reviews

local M = {}

-- Dependencies
local has_telescope, telescope = pcall(require, "telescope")
local has_nvimtree, nvimtree = pcall(require, "nvim-tree")

-- Config with default values
M.config = {
  github_cli_path = "gh",
  diff_command = "Gdiff",
  keymap = {
    list_prs = "<leader>crl",
    reset_review = "<leader>crr",
    reset_filter = "<C-r>",
  },
  enable_keymaps = true,
}

-- Helper function to run shell commands asynchronously
function M.run_command(cmd, callback)
  local stdout = ""
  local stderr = ""

  local function on_stdout(_, data, _)
    if data then
      for _, line in ipairs(data) do
        if line ~= "" then
          stdout = stdout .. line .. "\n"
        end
      end
    end
  end

  local function on_stderr(_, data, _)
    if data then
      for _, line in ipairs(data) do
        if line ~= "" then
          stderr = stderr .. line .. "\n"
        end
      end
    end
  end

  local function on_exit(_, exit_code, _)
    -- When commands like "gh pr checkout" succeed but write to stderr, 
    -- they often still return exit code 0. We'll consider this a success.
    if exit_code ~= 0 then
      vim.schedule(function()
        callback("", stderr)
      end)
    else
      -- Success case - pass both stdout and stderr, but don't treat stderr as an error
      vim.schedule(function()
        callback(stdout, "")
      end)
    end
  end

  local job_id = vim.fn.jobstart(cmd, {
    on_stdout = on_stdout,
    on_stderr = on_stderr,
    on_exit = on_exit,
    stdout_buffered = true,
    stderr_buffered = true,
  })

  if job_id <= 0 then
    vim.notify("Error running command: " .. cmd, vim.log.levels.ERROR)
    callback("", "Failed to start job")
  end
end

function M.list_pull_requests()
  -- Run the GitHub CLI command to get pull requests
  local command = M.config.github_cli_path ..
  " pr list --search 'review-requested:@me' --json number,title,author,state,url | jq"

  vim.notify("Fetching pull requests...", vim.log.levels.INFO)

  M.run_command(command, function(output, error_output)
    if error_output and error_output ~= "" then
      vim.notify("Error fetching PRs: " .. error_output, vim.log.levels.ERROR)
      return
    end

    -- Check if we have valid output before trying to parse
    if not output or output == "" then
      vim.notify("No pull requests found or empty response", vim.log.levels.INFO)
      return
    end

    -- Parse the JSON output
    local success, pull_requests = pcall(vim.fn.json_decode, output)

    if not success then
      vim.notify("Error parsing JSON response: " .. (pull_requests or "unknown error"), vim.log.levels.ERROR)
      return
    end

    if not pull_requests or vim.tbl_isempty(pull_requests) then
      vim.notify("No pull requests found for review", vim.log.levels.INFO)
      return
    end

    -- Format pull requests for telescope display
    M.show_pr_selection(pull_requests)
  end)
end


-- Show pull requests in telescope
function M.show_pr_selection(pull_requests)
  if not has_telescope then
    vim.notify("Telescope is required for PR selection", vim.log.levels.ERROR)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Format the pull request data for display
  local pr_items = {}
  for _, pr in ipairs(pull_requests) do
    table.insert(pr_items, {
      number = pr.number,
      title = pr.title,
      author = pr.author and pr.author.login or "unknown",
      state = pr.state,
      url = pr.url,
      display = string.format("#%d - %s (%s)", pr.number, pr.title, pr.author and pr.author.login or "unknown")
    })
  end

  -- Create the picker
  pickers.new({}, {
    prompt_title = "Pull Requests for Review",
    finder = finders.new_table({
      results = pr_items,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if selection and selection.value then
          -- Checkout the selected PR
          M.checkout_pull_request(selection.value)
        end
      end)
      return true
    end,
  }):find()
end

-- Checkout the selected pull request
function M.checkout_pull_request(pr_data)
  local pr_number = pr_data.number
  local command = M.config.github_cli_path .. " pr checkout " .. pr_number

  vim.notify("Checking out PR #" .. pr_number .. "...", vim.log.levels.INFO)

  M.run_command(command, function(output, error_output)
    if error_output and error_output ~= "" then
      vim.notify("Error checking out PR: " .. error_output, vim.log.levels.ERROR)
      return
    end

    vim.notify("Successfully checked out PR #" .. pr_number, vim.log.levels.INFO)

    -- After checkout, get the changed files
    M.get_changed_files(pr_number)
  end)
end

-- Get files changed in the pull request
function M.get_changed_files(pr_number)
  local command = M.config.github_cli_path .. " pr view " .. pr_number .. " --json files"

  M.run_command(command, function(output, error_output)
    if error_output and error_output ~= "" then
      vim.notify("Error fetching changed files: " .. error_output, vim.log.levels.ERROR)
      return
    end

    -- Parse the JSON output
    local success, pr_data = pcall(vim.fn.json_decode, output)
    if not success or not pr_data or not pr_data.files then
      vim.notify("Error parsing changed files JSON", vim.log.levels.ERROR)
      return
    end

    -- Extract file paths
    local changed_files = {}
    for _, file in ipairs(pr_data.files) do
      table.insert(changed_files, file.path)
    end

    -- Store the changed files in global for filtering
    M.current_pr_files = changed_files

    -- Open NvimTree with filtered files
    M.open_file_tree_with_filter()
  end)
end

-- NvimTree integration - open tree with filtered files
function M.open_file_tree_with_filter()
  if not has_nvimtree then
    vim.notify("NvimTree is required for file navigation", vim.log.levels.ERROR)
    return
  end

  -- Apply custom filter to NvimTree
  M.setup_nvimtree_filter()

  -- Open NvimTree
  vim.cmd("NvimTreeOpen")

  -- Notify the user about what's happening
  if M.current_pr_files and #M.current_pr_files > 0 then
    vim.notify(
      "Showing " .. #M.current_pr_files .. " changed files in PR. " ..
      "Press " .. M.config.keymap.reset_filter .. " in NvimTree to reset filter.",
      vim.log.levels.INFO
    )
  else
    vim.notify("No changed files found in PR", vim.log.levels.WARN)
  end
end

-- Setup NvimTree filter for PR files
function M.setup_nvimtree_filter()
  -- If we have the api module available
  if not require("nvim-tree.api") then
    vim.notify("NvimTree API not available for filtering", vim.log.levels.ERROR)
    return
  end

  local api = require("nvim-tree.api")

  -- Store original filter so we can restore it later
  if not M.original_filter then
    -- Try to get the original filter if available
    local ok, lib = pcall(require, "nvim-tree.lib")
    if ok and lib and lib.config and lib.config.filter then
      M.original_filter = lib.config.filter.filter_list
    else
      M.original_filter = {}
    end
  end

  -- Create a filter that only shows changed files
  if M.current_pr_files and #M.current_pr_files > 0 then
    -- Create inverse filter: anything NOT in our list gets filtered out
    -- We need to track folders that contain changed files
    local relevant_paths = {}

    for _, file_path in ipairs(M.current_pr_files) do
      -- Add the file itself
      relevant_paths[file_path] = true

      -- Add all parent directories
      local path_parts = vim.split(file_path, "/")
      local current_path = ""

      for i, part in ipairs(path_parts) do
        if i < #path_parts then -- don't add the file itself again
          if current_path ~= "" then
            current_path = current_path .. "/"
          end
          current_path = current_path .. part
          relevant_paths[current_path] = true
        end
      end
    end

    -- Setup filter function for nvim-tree
    api.tree.reload({
      filter = function(node)
        -- Always show if it's a directory
        if node.fs_stat and node.fs_stat.type == "directory" then
          -- But only if it contains relevant files
          return relevant_paths[node.absolute_path] ~= nil
        end

        -- For files, only show if they're in the changed files list
        return relevant_paths[node.absolute_path] ~= nil
      end
    })

    -- Add keybinding to reset the filter
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NvimTree",
      callback = function()
        vim.api.nvim_buf_set_keymap(
          0,
          "n",
          M.config.keymap.reset_filter,
          ":lua require('plugins.code_review').reset_nvimtree_filter()<CR>",
          { noremap = true, silent = true, desc = "Reset PR file filter" }
        )
      end,
    })
  end
end

-- Reset NvimTree filter to show all files
function M.reset_nvimtree_filter()
  if not require("nvim-tree.api") then return end

  local api = require("nvim-tree.api")

  -- Restore original filter
  api.tree.reload()

  vim.notify("File filter reset - showing all files", vim.log.levels.INFO)
end

-- Open file with diff view
function M.open_diff(file_path)
  -- Check if file exists
  if vim.fn.filereadable(file_path) == 0 then
    vim.notify("File not found: " .. file_path, vim.log.levels.ERROR)
    return
  end

  -- Open the file
  vim.cmd("edit " .. vim.fn.fnameescape(file_path))

  -- Show diff using fugitive if available
  if vim.fn.exists(":Gdiff") > 0 then
    vim.cmd(M.config.diff_command)
  else
    vim.notify("Fugitive plugin not found for diff view. Using regular buffer.", vim.log.levels.WARN)
  end
end

-- Add functionality to enhance NvimTree for PR review
function M.enhance_nvimtree_for_pr_review()
  -- Check if NvimTree is available
  if not has_nvimtree then return end

  -- Get the proper API
  local api = require("nvim-tree.api")
  if not api or not api.events then
    vim.notify("NvimTree events API not available", vim.log.levels.ERROR)
    return
  end
  
  -- Get Event enum from API
  local Event = api.events.Event
  
  -- Store the original open function to restore later
  if not M.original_open_func then
    M.original_open_func = api.node.open.edit
  end

  -- Override the node open function to handle PR review mode
  -- We'll monitor file creation which happens when opening files
  api.events.subscribe(Event.FileCreated, function(data)
    if M.current_pr_files and data and data.fname then
      -- If we're in PR review mode and the file is opened
      -- Run our diff view on it
      vim.schedule(function()
        M.open_diff(data.fname)
      end)
    end
  end)
  
  -- We'll also handle node opening by overriding the edit function
  api.node.open.edit = function(node)
    if M.current_pr_files and node and node.absolute_path then
      -- If we're in PR review mode, use our diff view
      M.open_diff(node.absolute_path)
      return
    end
    
    -- Otherwise use the original function
    if M.original_open_func then
      M.original_open_func(node)
    end
  end
end

-- Reset everything when done with PR review
function M.reset_pr_review_mode()
  M.current_pr_files = nil
  M.reset_nvimtree_filter()
  vim.notify("PR review mode disabled", vim.log.levels.INFO)
end

-- Create user commands and keymaps
function M.create_commands()
  -- List pull requests command
  vim.api.nvim_create_user_command("CodeReviewList", function()
    M.list_pull_requests()
  end, { desc = "List pull requests for review" })

  -- Reset PR review mode
  vim.api.nvim_create_user_command("CodeReviewReset", function()
    M.reset_pr_review_mode()
  end, { desc = "Reset PR review mode" })

  -- Add keybindings for convenience
  if M.config.enable_keymaps then
    vim.api.nvim_set_keymap("n", M.config.keymap.list_prs, ":CodeReviewList<CR>",
      { noremap = true, silent = true, desc = "List PRs for review" })

    vim.api.nvim_set_keymap("n", M.config.keymap.reset_review, ":CodeReviewReset<CR>",
      { noremap = true, silent = true, desc = "Reset PR review mode" })
  end
end

-- Check if the GitHub CLI is available
function M.check_dependencies()
  -- Check GitHub CLI
  M.run_command(M.config.github_cli_path .. " --version", function(output, error_output)
    if error_output and error_output ~= "" then
      vim.notify(
        "GitHub CLI not found or not working. Please install it for this plugin to work.\n" ..
        "Installation instructions: https://cli.github.com/manual/installation",
        vim.log.levels.ERROR
      )
      return false
    end
  end)

  -- Check if jq is available (needed for JSON processing)
  M.run_command("jq --version", function(output, error_output)
    if error_output and error_output ~= "" then
      vim.notify(
        "jq not found. Please install it for better JSON handling.\n" ..
        "Installation instructions: https://stedolan.github.io/jq/download/",
        vim.log.levels.WARN
      )
    end
  end)

  return true
end

-- Setup function to initialize the plugin
function M.setup(opts)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Check if dependencies are installed
  if not has_telescope then
    vim.notify("code-review.nvim requires telescope.nvim", vim.log.levels.ERROR)
    return
  end

  if not has_nvimtree then
    vim.notify("code-review.nvim requires nvim-tree.lua", vim.log.levels.ERROR)
    return
  end

  -- Check external dependencies
  M.check_dependencies()

  -- Enhance NvimTree for PR review
  M.enhance_nvimtree_for_pr_review()

  -- Register commands
  M.create_commands()

  return M
end

_G.code_review = M

return M

