"===================================================================================="
"System dependencies
"===================================================================================="
"
"brew install lua, ripgrep"
"
"I'm relying on a global installation of prettier here. might want to"
"reconsider this. maybe we can look for local prettier.rc and default to"
"global if needed."
"
"npm install -g prettier"
"
"powerline font:"
"
"brew tap homebrew/cask-fonts &&"
"brew install --cask font-hack-nerd-font"
"
"The Elixir Lsp requires specifying an absolute path. This should "
"be set in the require'lspconfig'.elixirls.setup() call in ./lau/ss_swizzle.lau"
"
"# Lsp dependencies"
"
"npm i -g vscode-langservers-extracted"


lua << EOF

require("ss_swizzle")

EOF
