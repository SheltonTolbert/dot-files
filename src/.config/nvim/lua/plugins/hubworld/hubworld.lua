-- hubworld.lua
-- A Neovim plugin for managing multiple repositories and projects

local M = {}

-- Plugin configuration with default values
M.config = {
  projects_file = vim.fn.stdpath("data") .. "/hubworld_projects.json",
  default_project_path = vim.fn.expand("~/projects"),
  telescope_theme = "dropdown",
  auto_save_session = true,
}

-- Initialize the plugin
function M.setup(opts)
  -- Merge user options with default config
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  -- Ensure the projects file exists
  M._ensure_projects_file()

  -- Create user commands
  M._create_commands()
end

-- Ensure the projects file exists
function M._ensure_projects_file()
  local file = io.open(M.config.projects_file, "r")
  if file then
    file:close()
  else
    local default_data = {
      projects = {},
      last_project = nil,
    }

    file = io.open(M.config.projects_file, "w")
    if file then
      file:write(vim.fn.json_encode(default_data))
      file:close()
    else
      vim.notify("Hubworld: Failed to create projects file", vim.log.levels.ERROR)
    end
  end
end

-- Create user commands
function M._create_commands()
  vim.api.nvim_create_user_command("Hubworld", function(opts)
    if opts.args == "list" then
      M.list_projects()
    elseif opts.args == "create" then
      M.create_project()
    elseif opts.args == "delete" then
      M.delete_project()
    elseif opts.args == "switch" then
      M.switch_project()
    else
      M.list_projects()
    end
  end, {
    nargs = '?',
    desc = 'Hubworld project management',
    complete = function(_, _, _)
      return { "list", "create", "delete", "switch" }
    end,
  })
end

-- List projects (placeholder, will be expanded)
function M.list_projects()
  vim.notify("Hubworld: Project listing not yet implemented", vim.log.levels.INFO)
end

-- Create a new project (placeholder, will be expanded)
function M.create_project()
  vim.notify("Hubworld: Project creation not yet implemented", vim.log.levels.INFO)
end

-- Delete a project (placeholder, will be expanded)
function M.delete_project()
  vim.notify("Hubworld: Project deletion not yet implemented", vim.log.levels.INFO)
end

-- Switch to a project (placeholder, will be expanded)
function M.switch_project()
  vim.notify("Hubworld: Project switching not yet implemented", vim.log.levels.INFO)
end

return M

