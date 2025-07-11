-- lua/plugins/hubworld/worktree_manager.lua
-- Manages Git worktrees for Hubworld projects

local notes_manager = require("plugins.hubworld.notes_manager") -- To get project's specific notes/state dir
local hubworld_notify -- Lazily loaded from main module to use its wrapper

local M = {}

-- Helper to run shell commands and return output lines and exit code
local function run_shell_command(cmd, cwd)
  hubworld_notify = hubworld_notify or require("plugins.hubworld.hubworld").notify
  local command_to_run = cmd
  if cwd then
    command_to_run = "cd " .. vim.fn.shellescape(cwd) .. " && " .. cmd
  end
  -- hubworld_notify("Running: " .. command_to_run, vim.log.levels.INFO) -- For debugging
  local output = vim.fn.systemlist(command_to_run)
  local exit_code = vim.v.shell_error
  return output, exit_code
end

-- Get the base path for storing worktree directories for a given Hubworld project
function M.get_worktrees_base_path(hubworld_project_name, hubworld_config)
  -- Worktrees will be stored alongside notes, in a dedicated subdirectory
  local project_state_root = notes_manager.get_project_notes_root(hubworld_project_name, hubworld_config)
  local worktrees_cfg = hubworld_config.worktrees or { worktrees_dirname = ".worktrees" }
  local path = vim.fn.simplify(project_state_root .. "/" .. worktrees_cfg.worktrees_dirname)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end
  return path
end

-- Get the absolute path to the root of the main Git repository
function M.get_git_repo_root(path_within_repo)
  local output, exit_code = run_shell_command("git rev-parse --show-toplevel", path_within_repo)
  if exit_code == 0 and output and #output > 0 then
    return vim.fn.trim(output[1])
  end
  return nil
end

-- List worktrees for a given main Git repository path
-- Returns a table: { {path="/path/to/worktree", head="sha", branch="[branch_name]" or "(detached HEAD)"}, ... }
function M.list_worktrees(main_git_repo_path)
  hubworld_notify = hubworld_notify or require("plugins.hubworld.hubworld").notify
  local output, exit_code = run_shell_command("git worktree list --porcelain", main_git_repo_path)
  local worktrees = {}
  if exit_code == 0 then
    local current_worktree = {}
    for _, line in ipairs(output) do
      if line == "" then -- Empty line separates worktree entries
        if current_worktree.path then table.insert(worktrees, current_worktree) end
        current_worktree = {}
      else
        local key, value = line:match("^([^%s]+)%s+(.+)$")
        if key == "worktree" then
          current_worktree.path = value
        elseif key == "HEAD" then
          current_worktree.head = value
        elseif key == "branch" then
          current_worktree.branch = value:gsub("^refs/heads/", "") -- Clean up branch name
        elseif key == "detached" then -- Indicates detached HEAD
            current_worktree.branch = "(detached HEAD)"
        end
      end
    end
    if current_worktree.path then table.insert(worktrees, current_worktree) end -- Add last one
  else
    hubworld_notify("Hubworld: Failed to list git worktrees. Exit code: " .. exit_code, vim.log.levels.ERROR)
  end
  return worktrees
end

function M.get_current_branch(path_within_repo)
  local output, exit_code = run_shell_command("git rev-parse --abbrev-ref HEAD", path_within_repo)
  if exit_code == 0 and output and #output > 0 then
    return vim.fn.trim(output[1])
  end
  return nil
end

function M.has_uncommitted_changes(path_within_repo)
  local output, exit_code = run_shell_command("git status --porcelain", path_within_repo)
  return exit_code == 0 and #output > 0
end

-- Stashes changes with a specific message prefix for Hubworld
-- Returns the full stash message if successful, otherwise nil
function M.stash_changes(path_within_repo, hubworld_project_name, current_branch_name)
  hubworld_notify = hubworld_notify or require("plugins.hubworld.hubworld").notify
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local stash_message = string.format("Hubworld_Auto_Stash__%s__%s__%s", hubworld_project_name, current_branch_name, timestamp)
  
  local _, exit_code = run_shell_command(
    string.format("git stash push -u -m %s", vim.fn.shellescape(stash_message)),
    path_within_repo
  )
  
  if exit_code == 0 then
    hubworld_notify("Hubworld: Stashed changes with message: " .. stash_message, vim.log.levels.INFO)
    return stash_message
  else
    -- Check if stash failed because there was nothing to stash
    local output_nothing_to_stash, _ = run_shell_command("git status --porcelain", path_within_repo)
    if #output_nothing_to_stash == 0 then
        hubworld_notify("Hubworld: No changes to stash.", vim.log.levels.INFO)
        return "NO_STASH_NEEDED" -- Special value to indicate nothing needed stashing
    end
    hubworld_notify("Hubworld: Failed to stash changes. Exit code: " .. exit_code, vim.log.levels.ERROR)
    return nil
  end
end

-- Pops the most recent stash matching a specific message prefix
-- Returns true if successful, false otherwise
function M.pop_stash_by_message_prefix(path_within_repo, stash_message_prefix)
  hubworld_notify = hubworld_notify or require("plugins.hubworld.hubworld").notify
  local stashes_output, exit_code = run_shell_command(
    string.format("git stash list --grep=%s", vim.fn.shellescape(stash_message_prefix)),
    path_within_repo
  )

  if exit_code ~= 0 or #stashes_output == 0 then
    hubworld_notify("Hubworld: No matching Hubworld stash found to pop with prefix: " .. stash_message_prefix, vim.log.levels.INFO)
    return false -- No matching stash found
  end

  -- The list is usually newest first. Get the ID of the first one (e.g., stash@{0})
  local stash_id = stashes_output[1]:match("^([^:]+):")
  if not stash_id then
    hubworld_notify("Hubworld: Could not parse stash ID from: " .. stashes_output[1], vim.log.levels.ERROR)
    return false
  end

  local _, pop_exit_code = run_shell_command(string.format("git stash pop %s", stash_id), path_within_repo)
  if pop_exit_code == 0 then
    hubworld_notify("Hubworld: Successfully popped stash: " .. stash_id .. " (" .. stash_message_prefix .. "...)", vim.log.levels.INFO)
    return true
  else
    hubworld_notify("Hubworld: Failed to pop stash " .. stash_id .. ". Manual merge may be required. Exit code: " .. pop_exit_code, vim.log.levels.ERROR)
    -- Attempt to apply instead if pop failed due to conflicts
    local _, apply_exit_code = run_shell_command(string.format("git stash apply %s", stash_id), path_within_repo)
    if apply_exit_code == 0 then
        hubworld_notify("Hubworld: Pop failed, but successfully applied stash: " .. stash_id .. ". Stash not dropped. Conflicts may exist.", vim.log.levels.WARN)
        return true -- Considered success in terms of getting changes back, but with a warning
    else
        hubworld_notify("Hubworld: Failed to apply stash " .. stash_id .. " after pop failed. Exit code: " .. apply_exit_code, vim.log.levels.ERROR)
    end
    return false
  end
end

-- Creates a new worktree
function M.create_worktree(main_git_repo_path, worktree_fs_path, new_branch_name, base_branch_or_commit)
  hubworld_notify = hubworld_notify or require("plugins.hubworld.hubworld").notify
  local cmd = string.format("git worktree add -b %s %s %s",
    vim.fn.shellescape(new_branch_name),
    vim.fn.shellescape(worktree_fs_path),
    vim.fn.shellescape(base_branch_or_commit)
  )
  local _, exit_code = run_shell_command(cmd, main_git_repo_path)
  if exit_code == 0 then
    hubworld_notify("Hubworld: Worktree created at " .. worktree_fs_path .. " on new branch " .. new_branch_name, vim.log.levels.INFO)
    return true
  else
    hubworld_notify("Hubworld: Failed to create worktree. Exit code: " .. exit_code, vim.log.levels.ERROR)
    return false
  end
end

-- Removes a worktree
function M.remove_worktree(main_git_repo_path, worktree_fs_path, force)
  hubworld_notify = hubworld_notify or require("plugins.hubworld.hubworld").notify
  local force_flag = force and " --force" or ""
  local cmd = string.format("git worktree remove %s%s", vim.fn.shellescape(worktree_fs_path), force_flag)
  
  -- First, ensure the worktree isn't locked (e.g., .git file exists)
  -- This might require more complex logic if just removing the dir isn't enough
  -- For now, rely on `git worktree remove` to handle this.

  local output, exit_code = run_shell_command(cmd, main_git_repo_path)
  if exit_code == 0 then
    hubworld_notify("Hubworld: Worktree at " .. worktree_fs_path .. " removed.", vim.log.levels.INFO)
    -- Git should clean up the directory. If not, we might need: vim.fn.delete(worktree_fs_path, "rf")
    return true
  else
    hubworld_notify("Hubworld: Failed to remove worktree " .. worktree_fs_path .. ". Output: " .. table.concat(output, "\n") .. " Exit code: " .. exit_code, vim.log.levels.ERROR)
    return false
  end
end

-- Gets the branch associated with a given worktree path by inspecting its .git file
-- This is more reliable than assuming the current branch if CWD isn't exactly the worktree root.
function M.get_branch_for_worktree_path(worktree_path)
    local gitfile_path = worktree_path .. "/.git"
    if vim.fn.filereadable(gitfile_path) == 1 then
        local content = vim.fn.readfile(gitfile_path)
        if content and #content > 0 then
            local branch_path = content[1]:match("gitdir: .*/refs/heads/(.+)$") -- Path relative to common .git/worktrees/name/
            if branch_path then return branch_path end
            
            -- Fallback for main worktree or if format is different
            local head_ref_line = content[1]:match("ref: refs/heads/(.+)$")
            if head_ref_line then return head_ref_line end
        end
    end
    -- If .git is a directory (main worktree), get current branch directly
    if vim.fn.isdirectory(gitfile_path) == 1 then
        return M.get_current_branch(worktree_path)
    end
    return nil
end

return M
