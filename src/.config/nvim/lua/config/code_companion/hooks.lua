local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

vim.api.nvim_create_autocmd(
    {"User"},
    {
        pattern = "CodeCompanion*",
        group = group,
        callback = function(request)
            if request.match == "CodeCompanionInlineFinished" then
                -- print(request.buf)
                -- vim.cmd("stopinsert")
                vim.cmd("w")
            end
        end
    }
)

local timer = nil
local delay = 500 -- milliseconds

local function save_buffer()
  vim.cmd("silent! write")
  vim.cmd("q")
end

vim.api.nvim_create_autocmd("TextChanged", {
  pattern = "*",
  callback = function()
    if timer then
      timer:stop()
    end
    timer = vim.loop.new_timer()
    timer:start(delay, 0, function()
      vim.schedule(save_buffer)
      timer:stop()
      timer:close()
      timer = nil
    end)
  end,
})

