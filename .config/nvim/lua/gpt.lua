-- Define the command function
function execute()
  -- Prompt the user for input
  local currentBuffer = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local bufferContent = table.concat(currentBuffer, "\n")
  local prompt = vim.fn.input("What can I help you with?")
  local complete_prompt = "Given the following code: " .. bufferContent .. "\n\n" .. prompt .. "\n\n" .. "Output should be formatted in markdown"

  -- Execute the command and capture the output
  local shell_command = "gpt dev -p " .. complete_prompt
  print(shell_command)
  -- local handle = io.popen("gpt dev -p " .. complete_prompt)
  -- local output = handle:read("*a")
  -- handle:close()

    -- Display the output in a new vertical split pane
  vim.cmd("vnew")
  vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.split(shell_command, "\n"))
  vim.cmd("setlocal buftype=nofile")
  vim.cmd("setlocal bufhidden=wipe")
  vim.cmd("setlocal wrap")
  vim.cmd("setlocal filetype=markdown")
end

-- Register the command
vim.cmd([[command! -nargs=0 GPT lua execute()]])

