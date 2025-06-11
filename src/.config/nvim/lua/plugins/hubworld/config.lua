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
    local buf_full_path = vim.api.nvim_buf_get_name(buf)
    if buf_full_path and buf_full_path ~= "" and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      local project_path_val = data.projects[project_name].path

      -- Normalize project_path_val to not have a trailing slash for consistent comparison
      if project_path_val:sub(-1) == '/' then project_path_val = project_path_val:sub(1, -2) end
      -- Add Windows path separator if necessary
      if project_path_val:sub(-1) == '\\' then project_path_val = project_path_val:sub(1, -2) end

      local path_to_store = buf_full_path
      -- Check if buf_full_path starts with project_path_val and the next char is a separator
      if buf_full_path:find(project_path_val .. "/", 1, true) == 1 then -- Unix separator
          path_to_store = buf_full_path:sub(#project_path_val + 2)
      elseif buf_full_path:find(project_path_val .. "\\", 1, true) == 1 then -- Windows separator
          path_to_store = buf_full_path:sub(#project_path_val + 2)
      end

      -- Only add if path_to_store is not empty (e.g. if it was the project root itself and we made it empty)
      if path_to_store ~= "" then
          table.insert(buffers, path_to_store)
      end
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
