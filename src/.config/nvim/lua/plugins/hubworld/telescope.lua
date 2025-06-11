-- telescope.lua
-- Telescope integration for Hubworld plugin

local has_telescope, telescope = pcall(require, "telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local project = require("plugins.hubworld.project")
local M = {}

-- Setup telescope extension
function M.setup()
  if not has_telescope then
    vim.notify("Hubworld: Telescope.nvim is required for UI features", vim.log.levels.ERROR)
    return
  end
  
  telescope.register_extension({
    exports = {
      hubworld = M.project_list,
    }
  })
end

-- Display project list with telescope
function M.project_list(opts, hubworld_config)
  if not has_telescope then
    vim.notify("Hubworld: Telescope.nvim is required for UI features", vim.log.levels.ERROR)
    return
  end
  
  opts = opts or {}
  
  -- Get all projects
  local projects = project.get_all_projects(hubworld_config.projects_file)
  
  -- Create finder for projects
  local finder = finders.new_table({
    results = projects,
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
    finder = finder,
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      -- Switch to selected project
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        
        if selection and selection.value then
          project.switch_project(
            hubworld_config.projects_file, 
            selection.value.name, 
            hubworld_config.auto_save_session
          )
        end
      end)
      
      -- Add custom mappings
      map("i", "<C-d>", function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        
        if selection and selection.value then
          -- Confirm deletion
          vim.ui.input({
            prompt = "Delete project " .. selection.value.name .. "? (y/N): ",
          }, function(input)
            if input and input:lower() == "y" then
              project.delete_project(hubworld_config.projects_file, selection.value.name)
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
  if not has_telescope then
    vim.notify("Hubworld: Telescope.nvim is required for UI features", vim.log.levels.ERROR)
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
      default = hubworld_config.default_project_path .. "/" .. name,
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
        local success = project.create_project(
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
            if not switch or switch == "" or switch:lower() ~= "n" then
              project.switch_project(
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