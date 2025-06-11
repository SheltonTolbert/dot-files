-- project.lua
-- Project management functionality for Hubworld plugin

local config = require("plugins.hubworld.config")
local M = {}

-- Check if a path is a git repository
function M.is_git_repo(path)
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
function M.create_project(config_path, name, path, init_git)
  -- Validate inputs
  if not name or name == "" then
    vim.notify("Hubworld: Project name cannot be empty", vim.log.levels.ERROR)
    return false
  end

  if not path or path == "" then
    vim.notify("Hubworld: Project path cannot be empty", vim.log.levels.ERROR)
    return false
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
    vim.notify("Hubworld: Path exists but is not a directory", vim.log.levels.ERROR)
    return false
  end

  -- Create directory if needed
  if create_dir then
    local ok = vim.fn.mkdir(path, "p")
    if ok ~= 1 then
      vim.notify("Hubworld: Failed to create directory", vim.log.levels.ERROR)
      return false
    end
  end

  -- Initialize git repository if requested
  local is_git = M.is_git_repo(path)
  if init_git and not is_git then
    local ok, result = M.init_git_repo(path)
    if not ok then
      vim.notify("Hubworld: Failed to initialize git repository: " .. result, vim.log.levels.ERROR)
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
    vim.notify("Hubworld: Project not found", vim.log.levels.ERROR)
    return false
  end

  return config.remove_project(config_path, name)
end

-- Switch to a project
function M.switch_project(config_path, name, auto_save)
  local data = config.read_config(config_path)
  if not data or not data.projects[name] then
    vim.notify("Hubworld: Project not found", vim.log.levels.ERROR)
    return false
  end

  local project = data.projects[name]

  -- Save current project session if auto_save is enabled
  if auto_save and data.last_project and data.last_project ~= name then
    config.save_project_session(config_path, data.last_project)
    vim.notify("Hubworld: Session saved for " .. data.last_project, vim.log.levels.INFO)
  end

  -- Change to project directory
  vim.cmd("silent! lcd " .. vim.fn.fnameescape(project.path)) -- Use lcd to be window-local if preferred, or cd for global
  vim.notify("Switched to project: " .. name .. " at " .. project.path, vim.log.levels.INFO)

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

  -- Open previously opened buffers
  local buffers_opened = 0
  if project.last_opened_buffers and #project.last_opened_buffers > 0 then
    for _, saved_buf_path in ipairs(project.last_opened_buffers) do
      local path_to_open = saved_buf_path
      -- Check if it's an absolute path (simple check, might need refinement for Windows)
      if not (saved_buf_path:sub(1,1) == "/" or saved_buf_path:match("^[A-Za-z]:\\")) then
        path_to_open = project.path .. "/" .. saved_buf_path
      end
      
      -- Ensure the path is clean (e.g. no double slashes if project.path had a trailing one)
      path_to_open = vim.fn.simplify(path_to_open)

      if vim.fn.filereadable(path_to_open) == 1 then
        vim.cmd("silent edit " .. vim.fn.fnameescape(path_to_open))
        buffers_opened = buffers_opened + 1
      else
        vim.notify("Hubworld: Could not find buffer to restore: " .. path_to_open, vim.log.levels.WARN)
      end
    end
  end

  -- TODO: Restore window layout

  -- If no buffers were opened (e.g., new project or all paths invalid), open a new empty buffer
  if buffers_opened == 0 then
    vim.cmd("silent enew")
    vim.notify("Hubworld: No previous buffers to restore, opened a new buffer.", vim.log.levels.INFO)
  end

  -- Update last project
  config.set_last_project(config_path, name)

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

