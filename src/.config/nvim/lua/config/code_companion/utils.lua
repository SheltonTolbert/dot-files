-- Get current branch commits against main
--  git cherry -v main $\(git branch list --show-current\) | cut -d' ' -f2
---@return string
local get_branch_commit_shas = function()
  local handle = io.popen("git cherry -v main $(git branch --show-current) | cut -d' ' -f2")

  if handle == nil then
    return "Error: Unable to retrieve branch commit SHAs."
  end

  local result = handle:read("*a")
  handle:close()
  return result
end

local get_branch_diff = function()
  local handle = io.popen("git log -p main..$(git branch --show-current) 2>&1")

  if handle == nil then
    return "Error: Unable to retrieve branch diff."
  end

  local result = handle:read("*a")
  handle:close()
  if result == "" then
    return "No differences found or an error occurred."
  end
  return result
end

---@return string
local get_repo_root = function()
  local handle = io.popen("git ref-parse --show-toplevel")

  if handle == nil then
    return "Error: Unable to retrieve repository root."
  end

  local result = handle:read("*a")
  handle:close()
  return result
end

return {
  get_branch_commit_shas = get_branch_commit_shas,
  get_branch_diff = get_branch_diff,
  get_repo_root = get_repo_root,
}
