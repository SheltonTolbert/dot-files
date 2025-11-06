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

