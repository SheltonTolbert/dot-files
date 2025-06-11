-- config.lua
-- Configuration management for Hubworld plugin

local M = {}

-- Read the project configuration from file
function M.read_config(config_path)
  local file = io.open(config_path, "r")
  if not file then
    return nil
  end

  local content = file:read("*all")
  file:close()

  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok then
    vim.notify("Hubworld: Failed to parse configuration file", vim.log.levels.ERROR)
    return { projects = {}, last_project = nil }
  end

  return data
end

-- Write the project configuration to file
function M.write_config(config_path, data)
  local file = io.open(config_path, "w")
  if not file then
    vim.notify("Hubworld: Failed to open configuration file for writing", vim.log.levels.ERROR)
    return false
  end

  local ok, json_str = pcall(vim.fn.json_encode, data)
  if not ok then
    vim.notify("Hubworld: Failed to encode configuration data", vim.log.levels.ERROR)
    file:close()
    return false
  end

  file:write(json_str)
  file:close()
  return true
end

-- Add a project to the configuration
function M.add_project(config_path, project)
  local data = M.read_config(config_path)
  if not data then
    data = { projects = {}, last_project = nil }
  end

  -- Ensure project has required fields
  project.last_opened_buffers = project.last_opened_buffers or {}
  project.last_opened_panes = project.last_opened_panes or {}

  -- Add or update the project
  data.projects[project.name] = project

  return M.write_config(config_path, data)
end

-- Remove a project from the configuration
function M.remove_project(config_path, project_name)
  local data = M.read_config(config_path)
  if not data then
    return false
  end

  -- Remove the project
  if data.projects[project_name] then
    data.projects[project_name] = nil
  end

  -- Update last project if needed
  if data.last_project == project_name then
    data.last_project = nil
  end

  return M.write_config(config_path, data)
end

-- Update the last opened project
function M.set_last_project(config_path, project_name)
  local data = M.read_config(config_path)
  if not data then
    return false
  end

  -- Update last project
  data.last_project = project_name

  return M.write_config(config_path, data)
end

-- Save the current session state for a project
function M.save_project_session(config_path, project_name)
  local data = M.read_config(config_path)
  if not data or not data.projects[project_name] then
    return false
  end

  -- Get current buffers
  local buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name and name ~= "" and vim.api.nvim_buf_is_loaded(buf) then
      -- Convert to relative path if it's within the project directory
      local project_path = data.projects[project_name].path
      if name:sub(1, #project_path) == project_path then
        name = name:sub(#project_path + 2) -- +2 to remove the slash
      end
      table.insert(buffers, name)
    end
  end

  -- TODO: Save pane configuration
  local panes = {}
  -- This would require more complex window/layout capturing

  -- Update project data
  data.projects[project_name].last_opened_buffers = buffers
  data.projects[project_name].last_opened_panes = panes

  return M.write_config(config_path, data)
end

return M
