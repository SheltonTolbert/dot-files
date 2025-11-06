require'lspconfig'.basedpyright.setup{
  cmd = { "uv", "run", "basedpyright-langserver", "--stdio" },
  root_dir = require('lspconfig.util').root_pattern("pyproject.toml", "pyrightconfig.json", ".git"),
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
}
