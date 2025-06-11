-- hubworld.lua
-- A Neovim plugin for managing multiple repositories and projects

local M = {}
local hubworld_telescope_integration = nil -- To store the loaded telescope module

-- Plugin configuration with default values
M.config = {
  projects_file = vim.fn.stdpath("data") .. "/hubworld_projects.json",
  default_project_path = vim.fn.expand("~/projects"), -- Default path for creating new projects
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
  M._create_commands() -- This also creates keymaps now

  -- Attempt to load and setup our Telescope integration
  local telescope_ok, telescope_mod = pcall(require, "plugins.hubworld.telescope")
  if telescope_ok and telescope_mod.is_available and telescope_mod:is_available() then
    telescope_mod.setup()
    hubworld_telescope_integration = telescope_mod -- Store for later use
  else
    vim.notify("Hubworld: Telescope.nvim not found or not available. UI will use basic prompts.", vim.log.levels.WARN)
  end
end

-- Ensure the projects file exists
function M._ensure_projects_file()
  local config_module = require("plugins.hubworld.config")
  local data = config_module.read_config(M.config.projects_file)

  if not data then
    local default_data = {
      projects = {},
      last_project = nil,
    }
    config_module.write_config(M.config.projects_file, default_data)
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
    elseif opts.args == "save" then
      M.save_project_session()
    else
      M.list_projects()
    end
  end, {
    nargs = '?',
    desc = 'Hubworld project management',
    complete = function(_, _, _)
      return { "list", "create", "delete", "switch", "save" }
    end,
  })

  -- Create keymaps
  vim.api.nvim_set_keymap('n', '<leader>hp', ':Hubworld list<CR>',
    { noremap = true, silent = true, desc = 'Hubworld: List Projects' })
  vim.api.nvim_set_keymap('n', '<leader>hc', ':Hubworld create<CR>',
    { noremap = true, silent = true, desc = 'Hubworld: Create Project' })
  vim.api.nvim_set_keymap('n', '<leader>hd', ':Hubworld delete<CR>',
    { noremap = true, silent = true, desc = 'Hubworld: Delete Project' })
  vim.api.nvim_set_keymap('n', '<leader>hs', ':Hubworld switch<CR>',
    { noremap = true, silent = true, desc = 'Hubworld: Switch Project' })
end

-- List projects
function M.list_projects()
  if hubworld_telescope_integration then
    hubworld_telescope_integration.project_list({
      theme = M.config.telescope_theme
    }, M.config)
  else
    vim.notify(
      "Hubworld: Telescope.nvim integration not available for project list view. Please ensure Telescope is installed and loaded.",
      vim.log.levels.ERROR)
    -- Consider adding a vim.ui.select fallback here for non-Telescope users
    return
  end
end

-- Create a new project
function M.create_project()
  if hubworld_telescope_integration then
    local ok, err = pcall(hubworld_telescope_integration.create_project, {}, M.config)
    if not ok then
      vim.notify(
        "Hubworld: Error using Telescope for project creation: " .. tostring(err) .. "\nFalling back to basic prompts.",
        vim.log.levels.WARN)
      -- Fall-through to basic prompts if Telescope UI fails or isn't available
    else
      return -- Telescope UI handled it
    end
  end

  -- Fallback to CLI input if Telescope is not available
  vim.ui.input({ prompt = "Project name: " }, function(name)
    if not name or name == "" then return end

    vim.ui.input({
      prompt = "Project path: ",
      default = vim.fn.getcwd() .. "/" -- Use current working directory
    }, function(path)
      if not path or path == "" then return end

      vim.ui.input({ prompt = "Initialize as git repository? (y/N): " }, function(init_git_str)
        local init_git = init_git_str and init_git_str:lower() == "y"

        local project_module = require("plugins.hubworld.project")
        local success = project_module.create_project(
          M.config.projects_file,
          name,
          path,
          init_git
        )

        if success then
          vim.notify("Hubworld: Project created: " .. name, vim.log.levels.INFO)
        end
      end)
    end)
  end)
end

-- Delete a project
function M.delete_project()
  local project_module = require("plugins.hubworld.project")
  local config_module = require("plugins.hubworld.config")

  local data = config_module.read_config(M.config.projects_file)
  if not data or vim.tbl_isempty(data.projects) then
    vim.notify("Hubworld: No projects found to delete", vim.log.levels.WARN)
    return
  end

  local project_names = {}
  for name, _ in pairs(data.projects) do
    table.insert(project_names, name)
  end

  vim.ui.select(project_names, {
    prompt = "Select project to delete:",
  }, function(selected_name)
    if not selected_name then return end

    vim.ui.input({
      prompt = "Are you sure you want to delete project '" .. selected_name .. "' from Hubworld? (y/N): ",
    }, function(confirmation)
      if confirmation and confirmation:lower() == "y" then
        local success = project_module.delete_project(M.config.projects_file, selected_name)
        if success then
          vim.notify("Hubworld: Project deleted: " .. selected_name, vim.log.levels.INFO)
        end
      end
    end)
  end)
end

-- Switch to a project
function M.switch_project()
  local project_module = require("plugins.hubworld.project")
  local config_module = require("plugins.hubworld.config")

  local data = config_module.read_config(M.config.projects_file)
  if not data or vim.tbl_isempty(data.projects) then
    vim.notify("Hubworld: No projects found to switch to", vim.log.levels.WARN)
    return
  end

  local project_names = {}
  for name, _ in pairs(data.projects) do
    table.insert(project_names, name)
  end

  vim.ui.select(project_names, {
    prompt = "Select project to switch to:",
  }, function(selected_name)
    if not selected_name then return end

    project_module.switch_project(
      M.config.projects_file,
      selected_name,
      M.config.auto_save_session
    )
  end)
end

-- Save current project session
function M.save_project_session()
  local config_module = require("plugins.hubworld.config")

  local data = config_module.read_config(M.config.projects_file)
  if not data or not data.last_project then
    vim.notify("Hubworld: No active project to save session for", vim.log.levels.WARN)
    return
  end

  local success = config_module.save_project_session(
    M.config.projects_file,
    data.last_project
  )

  if success then
    vim.notify("Hubworld: Session saved for project: " .. data.last_project, vim.log.levels.INFO)
  end
end

return M
