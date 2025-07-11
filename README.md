# 🏠 Dotfiles

A comprehensive, AI-enhanced development environment designed for polyglot developers working with multiple projects simultaneously.

## ✨ Features

- **🧠 AI-First Development**: Deep integration with Claude, GitHub Copilot, and multiple LLM providers
- **🚀 Project Management**: Custom Hubworld system for seamless project switching with worktree management
- **⚡ Automation**: Extensive shell functions and scripts for common development workflows
- **🎨 Unified Theming**: Gruvbox/Gruvbox Material theme across all tools
- **🔧 Modern Toolchain**: Neovim, Tmux, Zsh, Raycast, and cutting-edge development tools
- **📱 macOS Integration**: Custom Raycast extensions and native macOS workflow optimization

## 🛠️ Core Tools

### Development Environment
- **[Neovim](https://neovim.io/)** - Highly customized editor with extensive plugin ecosystem
- **[Zed Editor](https://zed.dev/)** - Modern editor with AI integration and custom MCP servers
- **[Tmux](https://github.com/tmux/tmux)** - Terminal multiplexer with session management via Tmuxinator
- **[Zsh](https://www.zsh.org/)** - Enhanced shell with Oh My Zsh and custom functions

### AI & Language Models
- **[Claude](https://claude.ai/)** - AI assistant with custom hooks and review workflows
- **[GitHub Copilot](https://github.com/features/copilot)** - AI coding assistant
- **[Code Companion](https://github.com/olimorris/codecompanion.nvim)** - Neovim LLM integration
- **[LLM CLI](https://llm.datasette.io/)** - Command-line interface for various language models

### macOS Integration
- **[Raycast](https://raycast.com/)** - Productivity launcher with custom extensions
- **[Aerospace](https://github.com/nikitabobko/AeroSpace)** - Tiling window manager
- **[SketchyBar](https://github.com/FelixKratz/SketchyBar)** - Custom menu bar

### Terminal & Shell Enhancement
- **[Starship](https://starship.rs/)** - Modern shell prompt with Gruvbox theme
- **[Ghostty](https://ghostty.org/)** - Terminal emulator with custom theming
- **[Btop](https://github.com/aristocratos/btop)** - System resource monitor

## 🚀 Installation

### Prerequisites
- macOS (primary target)
- Xcode Command Line Tools
- [Homebrew](https://brew.sh/)

### Quick Start
```bash
# Clone the repository
git clone https://github.com/SheltonTolbert/dot-files.git ~/.dotfiles

# Install dependencies and create symlinks
~/.dotfiles/install
```

The install script will:
- Install Xcode Command Line Tools
- Install Homebrew packages and casks
- Download and install Nerd Fonts
- Set up Oh My Zsh
- Install Tmux Plugin Manager
- Install Vim-Plug for Neovim
- Create symbolic links for all configuration files

### Manual Steps
After installation, you'll need to:
1. Set your terminal font to "Hack Nerd Font" or similar
2. Install Tmux plugins: `prefix + I` in Tmux
3. Install Neovim plugins: `:PlugInstall` in Neovim
4. Configure your API keys in `~/.zsh_api_keys`

## 🔄 Updating

```bash
# Update symlinks without reinstalling dependencies
~/.dotfiles/update
```

## 🏗️ Configuration Structure

```
src/
├── .config/
│   ├── nvim/              # Neovim configuration
│   │   ├── lua/
│   │   │   ├── config/    # Core configurations
│   │   │   ├── lsp/       # Language server configs
│   │   │   └── plugins/   # Plugin configurations
│   │   └── init.vim       # Entry point
│   ├── zsh/               # Zsh configuration
│   │   ├── .zsh_config    # Oh My Zsh setup
│   │   ├── .zsh_aliases   # Custom aliases
│   │   └── .zsh_functions # Advanced functions
│   ├── tmuxinator/        # Tmux session templates
│   ├── raycast/           # Custom Raycast extensions
│   ├── hubworld/          # Project management system
│   └── worktree/          # Git worktree management
├── .zshrc                 # Shell configuration
├── .tmux.conf             # Tmux configuration
├── .aerospace.toml        # Window manager config
├── .gitconfig             # Git configuration
└── .gitignore             # Global Git ignore
```

## 🎯 Key Features

### Hubworld Project Management
Custom Neovim plugin for managing multiple projects:
- **Project Switching**: Seamless navigation between projects with state preservation
- **Git Worktree Integration**: Automatic worktree management for parallel development
- **Notes System**: Branch-specific note-taking with automatic organization
- **Telescope Integration**: Fuzzy finding across projects and notes

### AI-Enhanced Workflows
- **Code Review**: Automated Claude-powered code review with custom hooks
- **Commit Messages**: AI-generated commit messages based on diff analysis
- **Documentation**: Automated documentation generation and updates
- **Debugging**: AI-assisted debugging and error resolution

### Advanced Shell Functions
- **Jira Integration**: Create branches from tickets, manage sprint issues
- **Worktree Management**: Register, create, and navigate git worktrees
- **Project Automation**: Automated project setup and configuration
- **Development Workflows**: Streamlined testing, building, and deployment

### Custom Raycast Extensions
- **Spotify Control**: Full Spotify integration with playback control
- **Aerospace Window Management**: Custom window switching and management
- **Slack Integration**: Message search and management
- **System Monitoring**: Process management and system utilities

## ⌨️ Key Bindings

### Aerospace (Window Management)
- `Alt + H/J/K/L` - Navigate windows
- `Alt + Shift + H/J/K/L` - Move windows
- `Alt + /` - Toggle horizontal/vertical layout
- `Alt + ,` - Toggle accordion layout
- `Alt + Shift + ;` - Enter service mode

### Tmux
- `Prefix + H/J/K/L` - Navigate panes
- `Prefix + C-H/J/K/L` - Navigate with vim awareness
- `Prefix + F` - FZF session switcher
- `Prefix + U` - URL opener
- `Prefix + B` - Session switcher

### Neovim (Custom Mappings)
- `<Leader>ff` - Find files with Telescope
- `<Leader>fg` - Live grep with Telescope
- `<Leader>fb` - Buffer switcher
- `<Leader>fh` - Help tags
- `<Leader>pp` - Project switcher (Hubworld)
- `<Leader>pn` - Project notes (Hubworld)

## 🔧 Language Support

### Language Servers
- **TypeScript/JavaScript**: `typescript-language-server`
- **Python**: `pyright`
- **Go**: `gopls`
- **Elixir**: `lexical`
- **Rust**: `rust-analyzer`
- **Lua**: `lua-language-server`
- **JSON/CSS/HTML**: `vscode-langservers-extracted`

### Development Tools
- **Testing**: Neotest framework with language-specific adapters
- **Formatting**: Prettier, Black, gofmt, mix format
- **Linting**: ESLint, Credo, golangci-lint
- **Debugging**: DAP (Debug Adapter Protocol) support

## 📦 Dependencies

### Homebrew Packages
```bash
brew install lua ripgrep btop git-delta tmux nvim node
brew install --cask raycast font-hack-nerd-font nikitabobko/tap/aerospace
```

### Node.js Packages
```bash
npm install -g vscode-langservers-extracted typescript typescript-language-server
```

### Additional Tools
- **[xh](https://github.com/ducaale/xh)** - Modern curl replacement
- **[Starship](https://starship.rs/)** - Shell prompt
- **[Oh My Zsh](https://ohmyz.sh/)** - Zsh framework

## 🎨 Theming

The entire environment uses a cohesive **Gruvbox/Gruvbox Material** theme:
- **Terminal**: Ghostty with Gruvbox Material Dark
- **Editor**: Neovim with gruvbox-material
- **Shell**: Starship with custom Gruvbox prompt
- **System Monitor**: Btop with Gruvbox theme
- **UI**: Consistent color scheme across all tools

## 🤝 Contributing

This is primarily a personal dotfiles repository, but contributions are welcome:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

MIT License - feel free to use and modify as needed.

## 🙏 Acknowledgments

- Built with [Dotbot](https://github.com/anishathalye/dotbot) for configuration management
- Inspired by the Unix philosophy and modern development practices
- Special thanks to the open-source community for the amazing tools