-- lua/plugins/hubworld/integrations/nvimtree.lua
-- Handles NvimTree integration for Hubworld

local M = {}

function M.setup(hubworld_config)
  local nvimtree_config = hubworld_config.integrations and hubworld_config.integrations.nvimtree
  
  if not (nvimtree_config and nvimtree_config.enabled) then
    return -- Integration is not enabled
  end

  -- Check if NvimTree API is available
  local nvim_tree_ok, nvim_tree_api = pcall(require, "nvim-tree.api")
  if not nvim_tree_ok then
    vim.notify("Hubworld: NvimTree integration enabled, but 'nvim-tree.api' could not be required. Is NvimTree installed and loaded?", vim.log.levels.WARN)
    return
  end

  if not (nvim_tree_api and nvim_tree_api.tree and nvim_tree_api.tree.change_root) then
    vim.notify("Hubworld: NvimTree API is available, but 'nvim_tree_api.tree.change_root' function is missing.", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "HubworldProjectSwitched",
    group = vim.api.nvim_create_augroup("HubworldNvimTreeIntegration", { clear = true }),
    callback = function()
      local current_cwd = vim.loop.cwd()
      local success = false
      local err_msg = nil

      if nvimtree_config.auto_change_root then
        success, err_msg = pcall(nvim_tree_api.tree.change_root, current_cwd)
        if success then
          vim.notify("Hubworld: NvimTree root updated to " .. current_cwd, vim.log.levels.INFO)
        else
          vim.notify("Hubworld: Failed to update NvimTree root: " .. tostring(err_msg), vim.log.levels.ERROR)
        end
      end

      if nvimtree_config.auto_reload and (success or not nvimtree_config.auto_change_root) then -- Reload if root changed or if only reload is on
        if nvim_tree_api.tree.reload then
            local reload_success, reload_err = pcall(nvim_tree_api.tree.reload)
            if not reload_success then
                vim.notify("Hubworld: Failed to reload NvimTree: " .. tostring(reload_err), vim.log.levels.WARN)
            end
        else
            vim.notify("Hubworld: NvimTree 'reload' API not found.", vim.log.levels.WARN)
        end
      end

      if nvimtree_config.auto_focus then
        if nvim_tree_api.tree.focus then
            local focus_success, focus_err = pcall(nvim_tree_api.tree.focus)
            if not focus_success then
                vim.notify("Hubworld: Failed to focus NvimTree: " .. tostring(focus_err), vim.log.levels.WARN)
            end
        elseif nvim_tree_api.commands and nvim_tree_api.commands.Toggle then -- Fallback to Toggle if focus is not direct
            local toggle_success, toggle_err = pcall(nvim_tree_api.commands.Toggle, {focus = true, find_file = true})
             if not toggle_success then
                vim.notify("Hubworld: Failed to toggle/focus NvimTree: " .. tostring(toggle_err), vim.log.levels.WARN)
            end
        else
            vim.notify("Hubworld: NvimTree 'focus' or 'Toggle' API not found for auto-focus.", vim.log.levels.WARN)
        end
      end
    end,
  })

  vim.notify("Hubworld: NvimTree integration enabled and configured.", vim.log.levels.INFO)
end

return M
