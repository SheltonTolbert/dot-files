-- project.lua
-- Project management functionality for Hubworld plugin

local config = require("plugins.hubworld.config")
local M = {}

-- Check if a path is a git repository
function M.is_git_repo(path) -- Exported for notes_manager
  local git_dir = path .. "/.git"
  local stat = vim.loop.fs_stat(git_dir)
  return stat and stat.type == "directory"
end

-- Initialize a new git repository
function M.init_git_repo(path)
  local result = vim.fn.system("cd " .. vim.fn.shellescape(path) .. " && git init")
  return vim.v.shell_error == 0, result
end

-- Get the status of a git repository
function M.get_git_status(path)
  local result = vim.fn.system("cd " .. vim.fn.shellescape(path) .. " && git status --porcelain")
  if vim.v.shell_error ~= 0 then
    return nil
  end

  return #result > 0 and "dirty" or "clean"
end

-- Create a new project
function M.create_project(config_path, name, path, init_git, non_interactive)
  -- Validate inputs
  if not non_interactive then -- Skip these checks if called non-interactively for a note collection
    if not name or name == "" then
      require("plugins.hubworld.hubworld").notify("Hubworld: Project name cannot be empty", vim.log.levels.ERROR)
      return false
    end
    
    if not path or path == "" then
      require("plugins.hubworld.hubworld").notify("Hubworld: Project path cannot be empty", vim.log.levels.ERROR)
      return false
    end
  end

  -- Expand path
  path = vim.fn.expand(path)

  -- Check if path exists
  local stat = vim.loop.fs_stat(path)
  local create_dir = false

  if not stat then
    -- Directory doesn't exist, create it
    create_dir = true
  elseif stat.type ~= "directory" then
    require("plugins.hubworld.hubworld").notify("Hubworld: Path exists but is not a directory: " .. path, vim.log.levels.ERROR)
    return false
  end

  -- Create directory if needed
  if create_dir then
    local ok = vim.fn.mkdir(path, "p")
    if tonumber(ok) ~= 1 and tonumber(ok) ~= 0 then -- mkdir returns 0 on success with Neovim Lua API, 1 with vim.fn
      -- For vim.fn.mkdir, success is 1. Let's assume it might return string "0" or number 0 for failure with some vim.fn versions.
      -- A more robust check might be needed if behavior varies wildly, but this covers common cases.
      if not non_interactive then
        require("plugins.hubworld.hubworld").notify("Hubworld: Failed to create directory " .. path, vim.log.levels.ERROR)
      end
      return false -- Silently fail if non_interactive for notes
    end
  end

  -- Initialize git repository if requested
  local is_git = M.is_git_repo(path)
  if init_git and not is_git and not non_interactive then -- Don't init git for note collections
    local ok, result = M.init_git_repo(path)
    if not ok then
      require("plugins.hubworld.hubworld").notify("Hubworld: Failed to initialize git repository: " .. result, vim.log.levels.ERROR)
      return false
    end
    is_git = true
  end

  -- Create project data
  local project = {
    name = name,
    path = path,
    is_git = is_git,
    last_opened_buffers = {},
    last_opened_panes = {},
  }

  -- Add project to configuration
  return config.add_project(config_path, project)
end

-- Delete a project (from configuration only, not files)
function M.delete_project(config_path, name)
  local data = config.read_config(config_path)
  if not data or not data.projects[name] then
    require("plugins.hubworld.hubworld").notify("Hubworld: Project '" .. name .. "' not found in configuration.", vim.log.levels.ERROR)
    return false
  end

  return config.remove_project(config_path, name)
end

-- Switch to a project
function M.switch_project(config_path, name, auto_save)
  local data = config.read_config(config_path)
  if not data or not data.projects[name] then
    require("plugins.hubworld.hubworld").notify("Hubworld: Project '" .. name .. "' not found for switching.", vim.log.levels.ERROR)
    return false
  end

  local project = data.projects[name]

  -- Save current project session if auto_save is enabled
  if auto_save and data.last_project and data.last_project ~= name then
    config.save_project_session(config_path, data.last_project)
    require("plugins.hubworld.hubworld").notify("Hubworld: Session saved for " .. data.last_project, vim.log.levels.INFO)
  end

  -- Change to project directory
  vim.cmd("silent! cd " .. vim.fn.fnameescape(project.path)) -- Use global cd
  require("plugins.hubworld.hubworld").notify("Switched to project: " .. name .. " at " .. project.path, vim.log.levels.INFO)

  -- Close all buffers
  -- Close all listed buffers, except the new one we might create if list is empty
  local current_buffers = vim.api.nvim_list_bufs()
  for _, buf_id in ipairs(current_buffers) do
    if vim.bo[buf_id].buflisted and vim.api.nvim_buf_is_loaded(buf_id) then
      -- Avoid deleting the buffer if it's the only one and unmodifiable, etc.
      -- A simple approach is to open a new empty buffer first, then delete others.
      -- However, for now, let's try to delete them directly. If issues arise, we can refine.
      pcall(vim.cmd, "silent! bdelete! " .. buf_id)
    end
  end

  -- Restore window layout if available, otherwise fall back to simple buffer list
  local panes_restored = false
  if project.last_opened_panes and #project.last_opened_panes > 0 then
    vim.cmd("silent tabonly") -- Close all other windows in the current tab
    local active_win_id_to_set = nil

    local previous_pane_restored_win_id = nil
    local previous_pane_info = nil

    for i, pane_info in ipairs(project.last_opened_panes) do -- Panes are sorted by win_nr from save
      local path_to_open = pane_info.buffer_path
      if not (path_to_open:sub(1,1) == "/" or path_to_open:match("^[A-Za-z]:\\")) then
        path_to_open = project.path .. "/" .. path_to_open
      end
      path_to_open = vim.fn.simplify(path_to_open)

      local current_win_for_pane = vim.api.nvim_get_current_win()

      if i > 1 and previous_pane_info then
        -- Determine split direction based on relative positions of saved pane_info data
        -- This compares the *intended* positions from the saved session.
        local row_diff = pane_info.row - previous_pane_info.row
        local col_diff = pane_info.col - previous_pane_info.col

        -- Heuristic: if it starts on a new row, it's likely a horizontal split.
        -- If it's on the same row but a new column, it's a vertical split.
        -- This assumes a somewhat top-to-bottom, left-to-right layout scan during save.
        if row_diff > 0 and math.abs(col_diff) < (previous_pane_info.width / 2) then -- New row, likely horizontal
          vim.cmd("silent split")
        elseif col_diff > 0 and math.abs(row_diff) < (previous_pane_info.height / 2) then -- New col, likely vertical
          vim.cmd("silent vsplit")
        else -- Default or ambiguous, or if the previous window was tiny
          vim.cmd("silent split") 
        end
        current_win_for_pane = vim.api.nvim_get_current_win() -- New split is now current
      elseif i == 1 then -- First pane, resize the initial window
        pcall(vim.api.nvim_win_set_width, current_win_for_pane, pane_info.width)
        pcall(vim.api.nvim_win_set_height, current_win_for_pane, pane_info.height)
      end

      if vim.fn.filereadable(path_to_open) == 1 then
        vim.cmd("silent edit " .. vim.fn.fnameescape(path_to_open))
        if pane_info.is_active then
          active_win_id_to_set = current_win_for_pane
        end
      else
        require("plugins.hubworld.hubworld").notify("Hubworld: Could not find buffer for pane: " .. path_to_open, vim.log.levels.WARN)
        vim.cmd("silent enew") -- Open an empty buffer in the split if file not found
      end

      -- Attempt to set dimensions for the newly focused/created window
      -- This happens after loading the buffer, as buffer loading might affect window dimensions.
      -- For the first window, it was already attempted. For splits, set dimensions after creation.
      if i > 1 then 
        pcall(vim.api.nvim_win_set_width, current_win_for_pane, pane_info.width)
        pcall(vim.api.nvim_win_set_height, current_win_for_pane, pane_info.height)
      end

      previous_pane_restored_win_id = current_win_for_pane -- Keep track of the actual window ID
      previous_pane_info = pane_info -- Keep track of the saved info for the next comparison
    end

    if active_win_id_to_set then
      vim.api.nvim_set_current_win(active_win_id_to_set)
    end
    vim.cmd("redraw!") -- Redraw to ensure UI updates correctly
    panes_restored = true
  end

  -- Fallback: If panes were not restored, use the old buffer list logic
  if not panes_restored then
    local buffers_opened = 0
    if project.last_opened_buffers and #project.last_opened_buffers > 0 then
      for _, saved_buf_path in ipairs(project.last_opened_buffers) do
        local path_to_open = saved_buf_path
        if not (saved_buf_path:sub(1,1) == "/" or saved_buf_path:match("^[A-Za-z]:\\")) then
          path_to_open = project.path .. "/" .. saved_buf_path
        end
        path_to_open = vim.fn.simplify(path_to_open)

        if vim.fn.filereadable(path_to_open) == 1 then
          vim.cmd("silent edit " .. vim.fn.fnameescape(path_to_open))
          buffers_opened = buffers_opened + 1
        else
          require("plugins.hubworld.hubworld").notify("Hubworld: Could not find buffer to restore: " .. path_to_open, vim.log.levels.WARN)
        end
      end
    end

    if buffers_opened == 0 then
      vim.cmd("silent enew")
      require("plugins.hubworld.hubworld").notify("Hubworld: No previous buffers to restore, opened a new buffer.", vim.log.levels.INFO)
    end
  end

  -- Update last project
  config.set_last_project(config_path, name)

  -- Fire an autocommand to notify other plugins/user configs about the switch
  vim.cmd("doautocmd User HubworldProjectSwitched")

  return true
end

-- Get all projects
function M.get_all_projects(config_path)
  local data = config.read_config(config_path)
  if not data then
    return {}
  end

  -- Convert projects table to array for easier use with telescope
  local projects = {}
  for name, project in pairs(data.projects) do
    -- Update git status if it's a git repository
    if project.is_git then
      project.git_status = M.get_git_status(project.path) or "unknown"
    end

    table.insert(projects, project)
  end

  return projects
end

return M

