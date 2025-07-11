-- telescope.lua
-- Telescope integration for Hubworld plugin

local has_telescope, telescope = pcall(require, "telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local project_module = require("plugins.hubworld.project") -- Renamed for clarity from 'project'

local notes_manager = require("plugins.hubworld.notes_manager")
local config_manager = require("plugins.hubworld.config") -- For reading current project path

local worktree_manager = require("plugins.hubworld.worktree_manager")

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
function M.project_list(opts, hubworld_config, current_project_name)
  if not M.is_available() then
    require("plugins.hubworld.hubworld").notify("Hubworld: Telescope.nvim is required for UI features", vim.log.levels.ERROR)
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
      local list_view_config = hubworld_config.list_view or {}
      local git_config = list_view_config.git or { status = true, symbols = { clean = "✓", dirty = "✗", unknown = "?" } }
      local symbols_config = list_view_config.symbols or { active = "➜" }
      local show_path_config = list_view_config.show_path == nil and true or list_view_config.show_path

      -- Add an indicator for the current project
      if current_project_name and entry.name == current_project_name then
        display = (symbols_config.active or "➜") .. " " .. display
      end

      if git_config.status and entry.is_git then
        local git_symbols = git_config.symbols or { clean = "✓", dirty = "✗", unknown = "?" }
        local status_symbol = git_symbols.unknown or "?"
        if entry.git_status == "clean" then
          status_symbol = git_symbols.clean or "✓"
        elseif entry.git_status == "dirty" then
          status_symbol = git_symbols.dirty or "✗"
        end
        display = display .. " [" .. status_symbol .. "]"
      end

      if show_path_config then
        display = display .. " (" .. entry.path .. ")"
      end

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
              require("plugins.hubworld.hubworld").notify("Project deleted: " .. selection.value.name, vim.log.levels.INFO)
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
    -- This error is for when the Telescope UI itself can't be used for project creation.
    -- The main hubworld.lua will catch this and fall back to vim.ui.input, so this error is more for debugging.
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
          require("plugins.hubworld.hubworld").notify("Project created: " .. name, vim.log.levels.INFO)

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

-- Telescope picker for managing notes
function M.notes_picker(opts, hubworld_config)
  if not M.is_available() then
    require("plugins.hubworld.hubworld").notify("Hubworld: Telescope.nvim is required for notes management.", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}

  -- Get current project details
  local current_hubworld_config_data = config_manager.read_config(hubworld_config.projects_file)
  if not (current_hubworld_config_data and current_hubworld_config_data.last_project) then
    require("plugins.hubworld.hubworld").notify("Hubworld: No active project selected to manage notes for.", vim.log.levels.WARN)
    return
  end

  local current_project_details = current_hubworld_config_data.projects[current_hubworld_config_data.last_project]
  if not current_project_details then
    require("plugins.hubworld.hubworld").notify("Hubworld: Could not retrieve details for the active project: " .. current_hubworld_config_data.last_project, vim.log.levels.ERROR)
    return
  end

  local project_root = current_project_details.path
  local hubworld_project_name_for_notes = current_hubworld_config_data.last_project

  local available_notes = notes_manager.list_available_notes(hubworld_project_name_for_notes, project_root, hubworld_config)

  if #available_notes == 0 then
    -- Offer to create default note structures if none exist
    notes_manager.ensure_project_collections_dir(hubworld_project_name_for_notes, hubworld_config) -- Ensure base dir for collections
    if project_module.is_git_repo(project_root) then
        notes_manager.ensure_branch_note_file(hubworld_project_name_for_notes, project_root, hubworld_config) -- Ensure branch note file for git repos
    end
    require("plugins.hubworld.hubworld").notify("Hubworld: No notes found. Default note structures (like branch_notes.md if git repo) have been ensured if not present. Create collections in the central notes directory for this project manually.", vim.log.levels.INFO, {title = "Hubworld Notes"})
    available_notes = notes_manager.list_available_notes(hubworld_project_name_for_notes, project_root, hubworld_config) -- Re-list
    if #available_notes == 0 then return end -- Still nothing to show
  end

  pickers_lib.new(opts, {
    prompt_title = "Hubworld Notes: " .. current_project_details.name,
    finder = finders_lib.new_table({
      results = available_notes,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display_name,
          ordinal = entry.display_name,
          type = entry.type,
        }
      end,
    }),
    sorter = conf_lib.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions_lib.select_default:replace(function()
        local selection = action_state_lib.get_selected_entry()
        actions_lib.close(prompt_bufnr)

        if selection and selection.value then
          local note_entry = selection.value
          if note_entry.type == "branch_note" then
            local branch_note_path = notes_manager.ensure_branch_note_file(note_entry.hubworld_project_name, note_entry.original_project_root_path, hubworld_config)
            if branch_note_path then
              vim.cmd("edit " .. vim.fn.fnameescape(branch_note_path))
            end
          elseif note_entry.type == "project_notes_root" then
            local base_project_name_for_root_notes = note_entry.hubworld_project_name
            local root_notes_project_name = base_project_name_for_root_notes .. "_ProjectNotesRoot"

            local existing_projects_data_root = config_manager.read_config(hubworld_config.projects_file)
            local found_root_project_config = false
            if existing_projects_data_root and existing_projects_data_root.projects then
              for proj_name, proj_details in pairs(existing_projects_data_root.projects) do
                if proj_details.path == note_entry.collection_path then -- collection_path holds the path to the root notes dir
                  root_notes_project_name = proj_name -- Use existing name
                  found_root_project_config = true
                  break
                end
              end
            end

            if not found_root_project_config then
              project_module.create_project(hubworld_config.projects_file, root_notes_project_name, note_entry.collection_path, false, true)
            end
            project_module.switch_project(hubworld_config.projects_file, root_notes_project_name, hubworld_config.auto_save_session)

          elseif note_entry.type == "project_collection" then
            -- Use the Hubworld project name for better uniqueness if it contains special chars
            -- The sanitize function in notes_manager will handle filesystem safety for dir names
            -- For the Hubworld *project entry name*, we can be a bit more direct.
            local base_project_name_for_collection = note_entry.hubworld_project_name
            local collection_project_name = base_project_name_for_collection .. "_Notes_" .. note_entry.collection_name

            local existing_projects_data = config_manager.read_config(hubworld_config.projects_file)
            local found_project_config = false
            if existing_projects_data and existing_projects_data.projects then
                for proj_name, proj_details in pairs(existing_projects_data.projects) do
                    if proj_details.path == note_entry.collection_path then
                        collection_project_name = proj_name -- Use existing name
                        found_project_config = true
                        break
                    end
                end
            end

            if not found_project_config then
              -- Pass true for non_interactive to create_project
              project_module.create_project(hubworld_config.projects_file, collection_project_name, note_entry.collection_path, false, true)
            end
            project_module.switch_project(hubworld_config.projects_file, collection_project_name, hubworld_config.auto_save_session)
          end
        end
      end)
      -- TODO: Add mapping for deleting notes (<C-d>)
      return true
    end,
  }):find()
end

-- Telescope picker for managing Git worktrees
function M.worktrees_picker(opts, hubworld_config)
  if not M.is_available() then
    require("plugins.hubworld.hubworld").notify("Hubworld: Telescope.nvim is required for worktree management.", vim.log.levels.ERROR)
    return
  end

  opts = opts or {}

  local current_hubworld_config_data = config_manager.read_config(hubworld_config.projects_file)
  if not (current_hubworld_config_data and current_hubworld_config_data.last_project) then
    require("plugins.hubworld.hubworld").notify("Hubworld: No active project selected to manage worktrees for.", vim.log.levels.WARN)
    return
  end

  local current_project_details = current_hubworld_config_data.projects[current_hubworld_config_data.last_project]
  if not current_project_details then
    require("plugins.hubworld.hubworld").notify("Hubworld: Could not retrieve details for the active project: " .. current_hubworld_config_data.last_project, vim.log.levels.ERROR)
    return
  end

  local original_project_root = worktree_manager.get_git_repo_root(current_project_details.path)
  if not original_project_root then
    require("plugins.hubworld.hubworld").notify("Hubworld: Active project '" .. current_project_details.name .. "' at '" .. current_project_details.path .."' is not a Git repository or git command failed.", vim.log.levels.ERROR)
    return
  end

  local worktrees = worktree_manager.list_worktrees(original_project_root)
  local current_cwd = vim.loop.cwd()

  local display_entries = {}
  for _, wt in ipairs(worktrees) do
    local is_current = (vim.fn.simplify(wt.path) == vim.fn.simplify(current_cwd))
    local display_name = string.format("%s%s (%s) - %s",
      is_current and (hubworld_config.list_view.symbols.active or "➜") .. " " or "  ",
      vim.fn.fnamemodify(wt.path, ":t"), -- Show directory name of worktree
      wt.branch,
      wt.path
    )
    table.insert(display_entries, {
      display = display_name,
      value = wt,
      is_current_worktree = is_current,
      path = wt.path,
      branch = wt.branch,
      head = wt.head,
      main_repo_root = original_project_root,
      hubworld_project_name = current_hubworld_config_data.last_project, -- For stashing context
    })
  end

  pickers_lib.new(opts, {
    prompt_title = "Hubworld Worktrees: " .. current_project_details.name,
    finder = finders_lib.new_table({
      results = display_entries,
      entry_maker = function(entry) return entry end, -- Results are already formatted
    }),
    sorter = conf_lib.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      -- Default action: Switch to worktree
      actions_lib.select_default:replace(function()
        local selection = action_state_lib.get_selected_entry()
        actions_lib.close(prompt_bufnr)
        if selection and selection.value and not selection.value.is_current_worktree then
          local target_wt = selection.value

          -- 1. Stash changes in current worktree (if any)
          local stash_prefix_current = nil
          if worktree_manager.has_uncommitted_changes(current_cwd) then
            local current_branch_for_stash = worktree_manager.get_current_branch(current_cwd) or "UNKNOWN_BRANCH"
            stash_prefix_current = worktree_manager.stash_changes(current_cwd, target_wt.hubworld_project_name, current_branch_for_stash)
            if not stash_prefix_current then
              require("plugins.hubworld.hubworld").notify("Hubworld: Failed to stash changes in current worktree. Aborting switch.", vim.log.levels.ERROR)
              return
            end
          end

          -- 2. Switch Hubworld project context (changes CWD)
          -- We need to find or create a Hubworld project entry for this worktree path
          local worktree_hub_project_name = current_project_details.name .. "_WT_" .. vim.fn.fnamemodify(target_wt.path, ":t")
          local existing_projects = config_manager.read_config(hubworld_config.projects_file)
          local found_project = false
          if existing_projects and existing_projects.projects then
            for proj_name, proj_details in pairs(existing_projects.projects) do
              if vim.fn.simplify(proj_details.path) == vim.fn.simplify(target_wt.path) then
                worktree_hub_project_name = proj_name
                found_project = true
                break
              end
            end
          end
          if not found_project then
            project_module.create_project(hubworld_config.projects_file, worktree_hub_project_name, target_wt.path, false, true)
          end
          project_module.switch_project(hubworld_config.projects_file, worktree_hub_project_name, hubworld_config.auto_save_session)
          -- switch_project already changes CWD and fires HubworldProjectSwitched

          -- 3. Pop stash in the new worktree (if one was made for it previously)
          if stash_prefix_current and stash_prefix_current ~= "NO_STASH_NEEDED" then
             -- Construct the stash message prefix that *would have been created* for the target worktree's branch
             local target_branch_for_stash_pop = target_wt.branch ~= "(detached HEAD)" and target_wt.branch or target_wt.head
             local stash_prefix_target = string.format("Hubworld_Auto_Stash__%s__%s", target_wt.hubworld_project_name, target_branch_for_stash_pop)
             worktree_manager.pop_stash_by_message_prefix(target_wt.path, stash_prefix_target)
          end
          require("plugins.hubworld.hubworld").notify("Switched to worktree: " .. target_wt.path, vim.log.levels.INFO)
        end
      end)

      -- New Worktree mapping: <C-n>
      map("i", "<C-n>", function()
        actions_lib.close(prompt_bufnr) -- Close the current picker
        local main_repo_root_for_new = original_project_root -- Captured from picker setup
        local current_hubworld_project_name = current_project_details.name

        vim.ui.input({ prompt = "New branch name for worktree: " }, function(new_branch)
          if not new_branch or new_branch == "" then return end

          local worktree_base_dir = worktree_manager.get_worktrees_base_path(current_hubworld_project_name, hubworld_config)
          local default_worktree_dir_name = new_branch:gsub("[^%w%-]", "_") -- Sanitize branch for dir name

          vim.ui.input({ prompt = "Directory name for new worktree (under .worktrees/): ", default = default_worktree_dir_name }, function(worktree_dir_name)
            if not worktree_dir_name or worktree_dir_name == "" then return end

            local worktree_full_path = vim.fn.simplify(worktree_base_dir .. "/" .. worktree_dir_name)

            if vim.fn.isdirectory(worktree_full_path) == 1 then
              require("plugins.hubworld.hubworld").notify("Hubworld: Worktree directory already exists: " .. worktree_full_path, vim.log.levels.ERROR)
              return
            end

            -- Optional: Prompt for base branch/commit
            local current_branch_in_main = worktree_manager.get_current_branch(main_repo_root_for_new) or "HEAD"
            vim.ui.input({ prompt = "Base branch/commit for new worktree: ", default = current_branch_in_main }, function(base_ref)
              if not base_ref or base_ref == "" then base_ref = current_branch_in_main end

              local success = worktree_manager.create_worktree(main_repo_root_for_new, worktree_full_path, new_branch, base_ref)
              if success then
                require("plugins.hubworld.hubworld").notify("Hubworld: Worktree '" .. worktree_dir_name .. "' created for branch '" .. new_branch .. "'.", vim.log.levels.INFO)
                -- Re-open the worktree picker to see the new entry
                M.worktrees_picker(opts, hubworld_config)
              else
                require("plugins.hubworld.hubworld").notify("Hubworld: Failed to create worktree.", vim.log.levels.ERROR)
              end
            end)
          end)
        end)
      end)

      -- Delete Worktree mapping: <C-d>
      map("i", "<C-d>", function()
        local selection = action_state_lib.get_selected_entry()
        if not selection or not selection.value then return end
        
        local wt_to_delete = selection.value
        if wt_to_delete.is_current_worktree then
          require("plugins.hubworld.hubworld").notify("Hubworld: Cannot delete the current worktree from this picker. Switch to another worktree first.", vim.log.levels.WARN)
          return
        end

        actions_lib.close(prompt_bufnr) -- Close the picker before vim.ui.input

        vim.ui.input({ prompt = string.format("Delete worktree at '%s' (branch '%s')? (y/N): ", wt_to_delete.path, wt_to_delete.branch) }, function(confirm)
          if confirm and confirm:lower() == "y" then
            -- Ask about force delete, especially if it might have changes or is locked.
            -- For simplicity now, we'll try a non-forced delete first. Git usually complains if it's unsafe.
            local force_delete = false 
            -- TODO: Could add another vim.ui.input to ask for force if the first attempt fails or if uncommitted changes are detected.

            local success = worktree_manager.remove_worktree(wt_to_delete.main_repo_root, wt_to_delete.path, force_delete)
            if success then
              require("plugins.hubworld.hubworld").notify("Hubworld: Worktree '" .. wt_to_delete.path .. "' deleted.", vim.log.levels.INFO)
              
              -- Remove Hubworld project entry if it exists for this worktree path
              local existing_projects = config_manager.read_config(hubworld_config.projects_file)
              local project_name_to_remove = nil
              if existing_projects and existing_projects.projects then
                for proj_name, proj_details in pairs(existing_projects.projects) do
                  if vim.fn.simplify(proj_details.path) == vim.fn.simplify(wt_to_delete.path) then
                    project_name_to_remove = proj_name
                    break
                  end
                end
              end
              if project_name_to_remove then
                project_module.delete_project(hubworld_config.projects_file, project_name_to_remove)
                require("plugins.hubworld.hubworld").notify("Hubworld: Removed Hubworld project entry for worktree '" .. project_name_to_remove .. "'.", vim.log.levels.INFO)
              end

              M.worktrees_picker(opts, hubworld_config) -- Re-open picker
            else
              require("plugins.hubworld.hubworld").notify("Hubworld: Failed to delete worktree '" .. wt_to_delete.path .. "'. It might have unsaved changes or be locked. Try with force or check git manually.", vim.log.levels.ERROR)
            end
          end
        end)
      end)
      return true
    end,
  }):find()
end

return M
