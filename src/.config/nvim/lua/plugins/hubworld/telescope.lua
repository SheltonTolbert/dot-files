-- telescope.lua
-- Telescope integration for Hubworld plugin

local has_telescope, telescope = pcall(require, "telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local project_module = require("plugins.hubworld.project") -- Renamed for clarity from 'project'

local M = {}

-- Internal check for Telescope library
local has_telescope_lib, telescope_lib = pcall(require, "telescope")
local pickers_lib, finders_lib, conf_lib, actions_lib, action_state_lib

if has_telescope_lib then
  pickers_lib = require("telescope.pickers")
  finders_lib = require("telescope.finders")
  conf_lib = require("telescope.config").values
  actions_lib = require("telescope.actions")
  action_state_lib = require("telescope.actions.state")
end

-- Function to check if Telescope integration is usable
function M.is_available()
  return has_telescope_lib
end

-- Setup telescope extension
function M.setup()
  if not M.is_available() then
    -- Silently return; hubworld.lua can notify if needed
    return
  end

  telescope_lib.register_extension({
    exports = {
      hubworld = M.project_list,
    }
  })
end

-- Display project list with telescope
function M.project_list(opts, hubworld_config)
  if not M.is_available() then
    vim.notify("Hubworld: Telescope.nvim is required for UI features", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}

  -- Get all projects
  local projects_data = project_module.get_all_projects(hubworld_config.projects_file)

  -- Create finder for projects
  local finder = finders_lib.new_table({
    results = projects_data,
    entry_maker = function(entry)
      local display = entry.name
      if entry.is_git then
        local status_symbol = "🔄"
        if entry.git_status == "clean" then
          status_symbol = "✓"
        elseif entry.git_status == "dirty" then
          status_symbol = "✗"
        end
        display = display .. " [" .. status_symbol .. "]"
      end
      display = display .. " (" .. entry.path .. ")"

      return {
        value = entry,
        display = display,
        ordinal = entry.name,
      }
    end
  })

  -- Create picker
  pickers.new(opts, {
    prompt_title = "Hubworld Projects",
    finder = finder, -- This should be finders_lib
    sorter = conf_lib.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      -- Switch to selected project
      actions_lib.select_default:replace(function()
        local selection = action_state_lib.get_selected_entry()
        actions_lib.close(prompt_bufnr)

        if selection and selection.value then
          project_module.switch_project(
            hubworld_config.projects_file,
            selection.value.name,
            hubworld_config.auto_save_session
          )
        end
      end)

      -- Add custom mappings
      map("i", "<C-d>", function()
        local selection = action_state_lib.get_selected_entry()
        actions_lib.close(prompt_bufnr)

        if selection and selection.value then
          -- Confirm deletion
          vim.ui.input({
            prompt = "Delete project " .. selection.value.name .. "? (y/N): ",
          }, function(input)
            if input and input:lower() == "y" then
              project_module.delete_project(hubworld_config.projects_file, selection.value.name)
              vim.notify("Project deleted: " .. selection.value.name, vim.log.levels.INFO)
            end
          end)
        end
      end)

      return true
    end,
  }):find()
end

-- Create a new project with telescope prompt
function M.create_project(opts, hubworld_config)
  if not M.is_available() then
    -- hubworld.lua will pcall this and handle the error for fallback
    error("Hubworld: Telescope.nvim is not available for create_project UI.")
    return
  end

  -- Prompt for project name
  vim.ui.input({
    prompt = "Project name: ",
  }, function(name)
    if not name or name == "" then
      return
    end

    -- Prompt for project path
    vim.ui.input({
      prompt = "Project path: ",
      default = vim.fn.getcwd() .. "/" .. name, -- Use current working directory
    }, function(path)
      if not path or path == "" then
        return
      end

      -- Prompt for git initialization
      vim.ui.input({
        prompt = "Initialize as git repository? (y/N): ",
      }, function(init_git)
        local init = init_git and init_git:lower() == "y"

        -- Create project
        local success = project_module.create_project(
          hubworld_config.projects_file,
          name,
          path,
          init
        )

        if success then
          vim.notify("Project created: " .. name, vim.log.levels.INFO)

          -- Ask if user wants to switch to the new project
          vim.ui.input({
            prompt = "Switch to the new project? (Y/n): ",
          }, function(switch)
            if not switch or switch == "" or switch:lower() == "y" then -- Corrected logic
              project_module.switch_project(
                hubworld_config.projects_file,
                name,
                hubworld_config.auto_save_session
              )
            end
          end)
        end
      end)
    end)
  end)
end

return M

