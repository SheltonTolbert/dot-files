local function root_dir(fname)
  return vim.fs.root(fname, { "pyproject.toml", "pyrightconfig.json", ".git" })
end

vim.lsp.config('basedpyright', {
  cmd = { "uv", "run", "basedpyright-langserver", "--stdio" },
  root_dir = root_dir,
  settings = {
    basedpyright = {
      analysis = {
        -- Performance settings
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,

        -- Import and completion enhancements
        autoImportCompletions = true,

        -- Type checking mode from pyproject.toml (basic)
        typeCheckingMode = "basic",

        -- Developer experience features
        autoFormatStrings = true,  -- Auto-insert 'f' when typing '{' in strings

        -- Inlay hints (basedpyright exclusive features)
        inlayHints = {
          variableTypes = true,           -- Show inferred types on variables
          callArgumentNames = true,       -- Show parameter names in function calls
          functionReturnTypes = true,     -- Show inferred return types
          genericTypes = true,           -- Show resolved generic types
        }
      }
    }
  }
})
vim.lsp.enable('basedpyright')
