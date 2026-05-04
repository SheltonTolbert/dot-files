local M = {}
  function M.BranchIssue()
  local output = vim.fn.system("zsh -i -c 'issue'")
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, vim.split(output, "\n"))

  -- Configure floating window options
  local opts = {
    relative = 'editor',
    width = math.min(80, vim.o.columns - 4),
    height = math.min(20, vim.o.lines - 4),
    col = (vim.o.columns - math.min(80, vim.o.columns - 4)) / 2,
    row = (vim.o.lines - math.min(20, vim.o.lines - 4)) / 2,
    style = 'minimal'
  }

  -- Open the floating window with the buffer
  vim.api.nvim_open_win(buf, true, opts)
  end

  function M.get_file(file_string)
    -- if file string starts with './'
    if string.find(file_string, '^./') then
      -- remove './'
      return vim.fn.findfile(string.gsub(file_string, './', ''), ".;")
    end
    return vim.fn.findfile(file_string)
  end

  function M.better_gf()
    -- Get the file string under the cursor and expand it to get the full path. strip the file string of quotes y semicolons
    local file_string = vim.fn.expand("<cWORD>"):gsub("'", ""):gsub('"', ""):gsub(";", "")

    -- get the absolute path of the file string under the cursor using finddir
    local path = vim.fn.finddir(file_string)

    -- use getfile to get the full path of the file, if there is one
    local file = M.get_file(file_string)

    -- get list of all files in path, filter out files that do not contain path as a substring
    local dir_files = vim.fn.globpath(path, "**/*", true, true)

    -- if there is a file, open it in the current buffer
    if file ~= "" then
      vim.cmd("e " .. file)
    elseif #dir_files > 0 then
      require("telescope.builtin").find_files({cwd = path})
    end

  end

function M.custom_diagnostics()
    local border_opts = {
        border = {
            { " ", "FloatBorder" },
            { " ", "FloatBorder" },
            { " ", "FloatBorder" },
            { " ", "FloatBorder" },
            { " ", "FloatBorder" },
            { " ", "FloatBorder" },
            { " ", "FloatBorder" },
            { " ", "FloatBorder" },
        },
    }

    -- Open the floating window with custom options
    vim.diagnostic.open_float(nil, {
        header = "Diagnostic Information",
        focusable = true,
        style = "minimal",
        border = border_opts.border,
        source = "always",
        prefix = "",
        scope = "line",
    })
end

function M.git_log_list()
    -- Get the visual selection range
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local range = start_line .. "," .. end_line

    -- Get the current file name
    local file_name = vim.fn.expand("%")

    -- Construct the git log command
    local command = "git log -L" .. range .. ":" .. file_name

    -- Execute the command and capture the output
    local output = vim.fn.systemlist(command)

    -- Create a floating window for displaying the git log output
    local bufnr = vim.api.nvim_create_buf(false, true)  -- Create a new buffer

    -- Set buffer filetype to git
    vim.bo[bufnr].filetype = 'diff'

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)  -- Set the buffer content
    local width = vim.o.columns * 0.8  -- Width of the floating window
    local height = vim.o.lines * 0.6   -- Height of the floating window
    local row = vim.o.lines * 0.2      -- Row position of the floating window
    local col = vim.o.columns * 0.1    -- Column position of the floating window

    -- Define the options for the floating window
    local opts = {
        relative = 'editor',
        width = math.ceil(width),
        height = math.ceil(height),
        row = math.ceil(row),
        col = math.ceil(col),
        style = 'minimal'
    }

    -- Create the floating window
    local win_id = vim.api.nvim_open_win(bufnr, true, opts)

    -- Set mappings to close the floating window with 'q'
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<Cmd>q!<CR>', { noremap = true, silent = true })

    -- Focus the floating window
    vim.api.nvim_set_current_win(win_id)
end

function M.source_vimrc()
    local myvimrc = vim.fn.expand('$MYVIMRC')
    vim.cmd("source " .. myvimrc)
end

function M.pretty_diagnostics()
  local line_number = vim.fn.line(".")

  -- Get the diagnostics for the current line_number
  local diagnostics = vim.diagnostic.get(0, { lnum = line_number })

  -- Open diagnostics in a floating window
  local keys = ''
  local values = ''
  for k,v in pairs(diagnostics) do
    print(v.lnum, v.message)
  end
   -- vim.lsp.util.open_floating_preview(diagnostics[1], "auto")
end

-- Marking files in telescope
MARKED_FILES = MARKED_FILES or {}
-- set default marked buffer list key to 'default'
MARKED_FILES['default'] = MARKED_FILES['default'] or {}
MARKED_FILES['test'] = MARKED_FILES['test'] or {}
CURRENT_MARKED_GROUP = CURRENT_MARKED_GROUP or 'default'

local function view_mark_groups_selector()
  -- selecting a marked group sets the CURRENT_MARKED_GROUP
  mark_group_keys = vim.tbl_keys(MARKED_FILES)

  -- open a window to select a marked group
  -- selecting a marked group sets the CURRENT_MARKED_GROUP
  require('telescope.builtin').marks({
    prompt_title = "Mark Groups",
    marks = mark_group_keys,
    attach_mappings = function(_, map)
      map('i', '<CR>', function(bufnr)
        local entry = require('telescope.actions.state').get_selected_entry()
        change_mark_group(entry.value)
        require('telescope.actions').close(bufnr)
      end)
      return true
    end
  })
end

local function change_mark_group(group)
  if MARKED_FILES[group] == nil then
    MARKED_FILES[group] = {}
  end
  CURRENT_MARKED_GROUP = group
  print("Changed marked group to: " .. group)
end

local function mark_current_file()
  local file = vim.fn.expand("%:p")
  mark_file(file)
end

local function mark_file(file)
  if MARKED_FILES[CURRENT_MARKED_GROUP] == nil then
    MARKED_FILES[CURRENT_MARKED_GROUP] = {}
  end

  if vim.tbl_contains(MARKED_FILES[CURRENT_MARKED_GROUP], file) then
    print("File already marked: " .. file)
    return
  end

  table.insert(MARKED_FILES[CURRENT_MARKED_GROUP], file)
  print("Marked file: " .. file .. " in group: " .. CURRENT_MARKED_GROUP)
end

local function unmark_current_file()
  local file = vim.fn.expand("%:p")
  unmark_file(file)
end

local function unmark_file(file)
  if #MARKED_FILES[CURRENT_MARKED_GROUP] == 0 then
    print("No marked files in group: " .. CURRENT_MARKED_GROUP)
    return
  end
  
  for i, f in ipairs(MARKED_FILES[CURRENT_MARKED_GROUP]) do
    if f == file then
      table.remove(MARKED_FILES[CURRENT_MARKED_GROUP], i)
      print("Unmarked file: " .. file)
      return
    end
  end
end

local function list_marked_files()
  if #MARKED_FILES[CURRENT_MARKED_GROUP] == 0 then
    print("No marked files")
    return
  end

  require('telescope.builtin').find_files({
    prompt_title = "Marked Files",
    cwd = vim.fn.getcwd(),
    --find_command = { "echo", table.concat(MARKED_FILES, "\n") }
    find_command = { "echo", table.concat(MARKED_FILES[CURRENT_MARKED_GROUP], "\n") }
  })
end




_G.view_mark_groups_selector = view_mark_groups_selector
_G.change_mark_group = change_mark_group
_G.unmark_current_file = unmark_current_file
_G.unmark_file = unmark_file
_G.mark_current_file = mark_current_file
_G.mark_file = mark_file
_G.list_marked_files = list_marked_files
_G.better_gf = M.better_gf
_G.custom_diagnostics = M.custom_diagnostics
_G.get_file = M.get_file
_G.git_log_list = M.git_log_list
_G.pretty_diagnostics = M.pretty_diagnostics
_G.source_vimrc = M.source_vimrc

return M

