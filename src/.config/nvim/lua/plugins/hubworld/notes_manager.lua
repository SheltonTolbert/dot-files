-- lua/plugins/hubworld/notes_manager.lua
-- Manages notes for Hubworld projects

local project_utils = require("plugins.hubworld.project") -- For is_git_repo

local M = {}

local function ensure_dir_exists(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p") -- Create parent directories as needed
  end
end

-- Sanitize a project name to be filesystem-friendly for directory names
local function sanitize_project_name_for_fs(project_name)
  if not project_name or project_name == "" then return "default_project" end
  local sanitized = project_name
  sanitized = sanitized:gsub("[^%w_%.%-]", "_") -- Replace non-alphanumeric, underscore, dot, hyphen with underscore
  sanitized = sanitized:gsub("__+", "_")      -- Replace multiple underscores with one
  if sanitized == "" then sanitized = "project" end -- Ensure not empty
  return sanitized

end

-- Get the root directory for a specific project's notes within the central notes location
function M.get_project_notes_root(hubworld_project_name, hubworld_config)
  local notes_cfg = hubworld_config.notes or { central_notes_root = vim.fn.stdpath("state") .. "/hubworld/notes" }
  local central_root = vim.fn.expand(notes_cfg.central_notes_root) -- Expand to make absolute
  ensure_dir_exists(central_root) -- Ensure the base central directory exists

  local sanitized_name = sanitize_project_name_for_fs(hubworld_project_name)
  local project_specific_notes_path = vim.fn.simplify(central_root .. "/" .. sanitized_name)
  ensure_dir_exists(project_specific_notes_path)
  return project_specific_notes_path
end

-- Get the full path to the branch_notes.md file
function M.get_branch_note_path(hubworld_project_name, hubworld_config)
  local project_notes_dir = M.get_project_notes_root(hubworld_project_name, hubworld_config)
  local notes_cfg = hubworld_config.notes or { branch_note_filename = "branch_notes.md" }
  return vim.fn.simplify(project_notes_dir .. "/" .. notes_cfg.branch_note_filename)
end

-- Ensure the branch_notes.md file and its parent directories exist
function M.ensure_branch_note_file(hubworld_project_name, original_project_root_path_for_display, hubworld_config)
  -- The project_notes_dir is already ensured by get_branch_note_path calling get_project_notes_root
  local branch_note_file_path = M.get_branch_note_path(hubworld_project_name, hubworld_config)
  if vim.fn.filereadable(branch_note_file_path) == 0 then
    local file = io.open(branch_note_file_path, "w")
    if file then
      file:write("# Branch Notes for Hubworld Project: " .. hubworld_project_name .. "\n")
      file:write("#(Original Project Path: " .. original_project_root_path_for_display .. ")\n\n")
      file:close()
    else
      require("plugins.hubworld.hubworld").notify("Hubworld: Could not create branch notes file: " .. branch_note_file_path, vim.log.levels.ERROR)
      return nil
    end
  end
  return branch_note_file_path
end

-- Get the path to the project_notes (collections) directory
function M.get_project_collections_path(hubworld_project_name, hubworld_config)
  local project_notes_dir = M.get_project_notes_root(hubworld_project_name, hubworld_config)
  local notes_cfg = hubworld_config.notes or { project_collections_dirname = "project_notes" }
  return vim.fn.simplify(project_notes_dir .. "/" .. notes_cfg.project_collections_dirname)
end

-- Ensure the project_notes (collections) directory and its parent .hubworld exist
function M.ensure_project_collections_dir(hubworld_project_name, hubworld_config)
  -- The project_notes_dir is already ensured by get_project_collections_path calling get_project_notes_root
  local collections_path = M.get_project_collections_path(hubworld_project_name, hubworld_config)
  ensure_dir_exists(collections_path)
  return collections_path
end

-- List available notes for a given project
function M.list_available_notes(hubworld_project_name, original_project_root_path, hubworld_config)
  local notes_list = {}
  local notes_cfg = hubworld_config.notes

  -- 1. Branch Note (if applicable)
  if project_utils.is_git_repo(original_project_root_path) then
    -- We don't check for file existence here; ensure_branch_note_file will create it on demand.
    -- The Telescope action will call ensure_branch_note_file before opening.
    table.insert(notes_list, {
      display_name = "Current Branch Notes",
      type = "branch_note",
      hubworld_project_name = hubworld_project_name, -- Name of the Hubworld project these notes are for
      original_project_root_path = original_project_root_path, -- Actual root of the original project
      full_path = M.get_branch_note_path(hubworld_project_name, hubworld_config),
      filename = notes_cfg.branch_note_filename,
    })
  end

  -- 2. Project Note Collections Root (always offer this option)
  local collections_base_path = M.ensure_project_collections_dir(hubworld_project_name, hubworld_config)
  table.insert(notes_list, {
    display_name = "View/Manage Project Notes Root",
    type = "project_notes_root", -- New type
    hubworld_project_name = hubworld_project_name,
    original_project_root_path = original_project_root_path,
    collection_path = collections_base_path, -- Path to the 'project_notes' dir itself
  })

  -- 3. Individual Project Note Collections (sub-directories)
  if vim.fn.isdirectory(collections_base_path) == 1 then -- Should always be true due to ensure_project_collections_dir above
    local files = vim.fn.readdir(collections_base_path)
    if files then
      for _, item_name in ipairs(files) do
        if item_name ~= "." and item_name ~= ".." then
          local item_full_path = vim.fn.simplify(collections_base_path .. "/" .. item_name)
          if vim.fn.isdirectory(item_full_path) == 1 then
            table.insert(notes_list, {
              display_name = "Project Collection: " .. item_name,
              type = "project_collection",
              hubworld_project_name = hubworld_project_name, -- Name of the parent Hubworld project
              original_project_root_path = original_project_root_path, -- Actual root of the parent project
              collection_name = item_name,
              collection_path = item_full_path,
            })
          end
        end
      end
    end
  end
  
  return notes_list
end

return M
